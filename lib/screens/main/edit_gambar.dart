import 'dart:io';
import 'package:app/models/isi_gambar.dart';
import 'package:app/models/tema.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/gambar_provider.dart';
import 'package:app/provider/tema_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class EditIsiGambarPage extends StatefulWidget {
  final IsiGambar isiGambar;

  EditIsiGambarPage({Key? key, required this.isiGambar}) : super(key: key);

  @override
  _EditIsiGambarPageState createState() => _EditIsiGambarPageState();
}

class _EditIsiGambarPageState extends State<EditIsiGambarPage> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _suaraController = TextEditingController();
  String? _selectedTingkatKesulitan;
  Tema? _selectedTema;
  File? _gambar1;
  File? _gambar2;
  File? _gambar3;
  File? _suaraFile;
  bool _status = false;

  List<Tema> _temas = [];
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  String? _recordedFilePath;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _initRecorder();
    _fetchTemas();

    // Load initial data
    _labelController.text = widget.isiGambar.label;
    _selectedTingkatKesulitan = widget.isiGambar.tingkatKesulitan;
    _gambar1 = widget.isiGambar.gambar1.isNotEmpty
        ? File(widget.isiGambar.gambar1)
        : null;
    _gambar2 = widget.isiGambar.gambar2.isNotEmpty
        ? File(widget.isiGambar.gambar2)
        : null;
    _gambar3 = widget.isiGambar.gambar3.isNotEmpty
        ? File(widget.isiGambar.gambar3)
        : null;
    _suaraController.text = widget.isiGambar.suara ?? '';
    _status = widget.isiGambar.status;
  }

  Future<void> _initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    await _recorder!.openRecorder();
  }

  Future<void> _startRecording() async {
    Directory tempDir = await getTemporaryDirectory();
    String fileName =
        'recorded_audio_${DateTime.now().millisecondsSinceEpoch}.aac';
    String path = '${tempDir.path}/$fileName';
    await _recorder!.startRecorder(toFile: path);
    setState(() {
      _isRecording = true;
      _recordedFilePath = path;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    setState(() {
      _isRecording = false;
      _suaraFile = File(_recordedFilePath!);
    });
  }

  Future<void> _pickAndCropImage(ImageSource source, int imageType) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            minimumAspectRatio: 1.0,
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          if (imageType == 1) {
            _gambar1 = File(croppedFile.path);
          } else if (imageType == 2) {
            _gambar2 = File(croppedFile.path);
          } else if (imageType == 3) {
            _gambar3 = File(croppedFile.path);
          }
        });
      }
    }
  }

  Future<void> _pickSoundFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null && result.files.single.path != null) {
      setState(() {
        _suaraFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _fetchTemas() async {
    await Provider.of<TemaProvider>(context, listen: false).fetchTemas();
    setState(() {
      _temas = Provider.of<TemaProvider>(context, listen: false).temas;
      _selectedTema =
          _temas.firstWhere((tema) => tema.id == widget.isiGambar.idtema);
    });
  }

  void _updateIsiGambar() {
    if (_formKey.currentState!.validate()) {
      final updatedIsiGambar = IsiGambar(
        id: widget.isiGambar.id,
        label: _labelController.text,
        tingkatKesulitan: _selectedTingkatKesulitan ?? 'mudah',
        idtema: _selectedTema?.id,
        gambar1: _gambar1?.path ?? widget.isiGambar.gambar1,
        gambar2: _gambar2?.path ?? widget.isiGambar.gambar2,
        gambar3: _gambar3?.path ?? widget.isiGambar.gambar3,
        suara: _recordedFilePath ?? _suaraFile?.path ?? _suaraController.text,
        status: _status,
      );

      Provider.of<IsiGambarProvider>(context, listen: false)
          .updateIsiGambar(updatedIsiGambar);

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Isi Gambar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<Tema>(
                value: _selectedTema,
                onChanged: (newValue) {
                  setState(() {
                    _selectedTema = newValue;
                  });
                },
                decoration: InputDecoration(labelText: 'Tema'),
                items: _temas.map((tema) {
                  return DropdownMenuItem<Tema>(
                    value: tema,
                    child: Text(tema.namaTema),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a tema';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _labelController,
                decoration: InputDecoration(labelText: 'Label'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a label';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedTingkatKesulitan,
                onChanged: (newValue) {
                  setState(() {
                    _selectedTingkatKesulitan = newValue;
                  });
                },
                decoration: InputDecoration(labelText: 'Tingkat Kesulitan'),
                items: ['mudah', 'sedang', 'sulit'].map((tingkat) {
                  return DropdownMenuItem<String>(
                    value: tingkat,
                    child: Text(tingkat),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a tingkat kesulitan';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              Text('Gambar 1:'),
              _gambar1 == null
                  ? ElevatedButton(
                      onPressed: () =>
                          _pickAndCropImage(ImageSource.gallery, 1),
                      child: Text('Pick Image'),
                    )
                  : Column(
                      children: [
                        Image.file(_gambar1!),
                        ElevatedButton(
                          onPressed: () =>
                              _pickAndCropImage(ImageSource.gallery, 1),
                          child: Text('Change Image'),
                        ),
                      ],
                    ),
              SizedBox(height: 16.0),
              Text('Gambar 2:'),
              _gambar2 == null
                  ? ElevatedButton(
                      onPressed: () =>
                          _pickAndCropImage(ImageSource.gallery, 2),
                      child: Text('Pick Image'),
                    )
                  : Column(
                      children: [
                        Image.file(_gambar2!),
                        ElevatedButton(
                          onPressed: () =>
                              _pickAndCropImage(ImageSource.gallery, 2),
                          child: Text('Change Image'),
                        ),
                      ],
                    ),
              SizedBox(height: 16.0),
              Text('Gambar 3:'),
              _gambar3 == null
                  ? ElevatedButton(
                      onPressed: () =>
                          _pickAndCropImage(ImageSource.gallery, 3),
                      child: Text('Pick Image'),
                    )
                  : Column(
                      children: [
                        Image.file(_gambar3!),
                        ElevatedButton(
                          onPressed: () =>
                              _pickAndCropImage(ImageSource.gallery, 3),
                          child: Text('Change Image'),
                        ),
                      ],
                    ),
              SizedBox(height: 16.0),
              Text('Suara:'),
              _suaraFile == null
                  ? Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _pickSoundFile();
                          },
                          child: Text('Pick Sound File'),
                        ),
                        ElevatedButton(
                          onPressed:
                              _isRecording ? _stopRecording : _startRecording,
                          child: Text(_isRecording
                              ? 'Stop Recording'
                              : 'Start Recording'),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Text('Selected Sound File: ${_suaraFile!.path}'),
                        ElevatedButton(
                          onPressed: () {
                            _pickSoundFile();
                          },
                          child: Text('Change Sound File'),
                        ),
                        ElevatedButton(
                          onPressed:
                              _isRecording ? _stopRecording : _startRecording,
                          child: Text(_isRecording
                              ? 'Stop Recording'
                              : 'Start Recording'),
                        ),
                      ],
                    ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _updateIsiGambar,
                child: Text('Update Isi Gambar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    _labelController.dispose();
    _suaraController.dispose();
    super.dispose();
  }
}
