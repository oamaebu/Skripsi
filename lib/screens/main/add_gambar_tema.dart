import 'dart:io';
import 'package:app/models/isi_gambar.dart';
import 'package:app/models/tema.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/gambar_provider.dart';
import 'package:app/provider/tema_provider.dart'; // Assuming you have a provider for Tema
import 'package:file_picker/file_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class AddIsiGambarPagetema extends StatefulWidget {
  @override
  _AddIsiGambarPageState createState() => _AddIsiGambarPageState();
}

class _AddIsiGambarPageState extends State<AddIsiGambarPagetema> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _suaraController = TextEditingController();
  String? _selectedTingkatKesulitan;
  Tema? _selectedTema; // Changed to Tema type
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
  }

  Future<void> _initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    await _recorder!.openRecorder();
  }

  Future<void> _startRecording() async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      String path = '${tempDir.path}/recorded_audio.aac';
      await _recorder!.startRecorder(toFile: path);
      setState(() {
        _isRecording = true;
        _recordedFilePath = path;
      });
    } catch (e) {
      print('Error starting recording: $e');
      // You can also show a Snackbar or a dialog to inform the user
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _recorder!.stopRecorder();
      setState(() {
        _isRecording = false;
        _suaraFile = File(_recordedFilePath!);
      });
    } catch (e) {
      print('Error stopping recording: $e');
      // You can also show a Snackbar or a dialog to inform the user
    }
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
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            

          ),
          IOSUiSettings(
            minimumAspectRatio: 1.0,
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
    });
  }

  void _addIsiGambar() {
    if (_formKey.currentState!.validate()) {
      final newIsiGambar = IsiGambar(
        id: null,
        label: _labelController.text,
        tingkatKesulitan: _selectedTingkatKesulitan ?? 'mudah',
        idtema: _selectedTema?.id as int?, // Assigning tema id
        gambar1: _gambar1?.path ?? '',
        gambar2: _gambar2?.path ?? '',
        gambar3: _gambar3?.path ?? '',
        suara: _suaraFile?.path ?? _suaraController.text,
        status: _status,
      );

      Provider.of<IsiGambarProvider>(context, listen: false)
          .addIsiGambar(newIsiGambar);

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Isi Gambar'),
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
                  : Image.file(_gambar1!),
              SizedBox(height: 16.0),
              Text('Gambar 2:'),
              _gambar2 == null
                  ? ElevatedButton(
                      onPressed: () =>
                          _pickAndCropImage(ImageSource.gallery, 2),
                      child: Text('Pick Image'),
                    )
                  : Image.file(_gambar2!),
              SizedBox(height: 16.0),
              Text('Gambar 3:'),
              _gambar3 == null
                  ? ElevatedButton(
                      onPressed: () =>
                          _pickAndCropImage(ImageSource.gallery, 3),
                      child: Text('Pick Image'),
                    )
                  : Image.file(_gambar3!),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _suaraController,
                decoration: InputDecoration(labelText: 'Suara URL'),
              ),
              SizedBox(height: 16.0),
              _suaraFile == null
                  ? ElevatedButton(
                      onPressed: _pickSoundFile,
                      child: Text('Pick Sound File'),
                    )
                  : Text(
                      'Selected sound file: ${_suaraFile!.path.split('/').last}'),
              SizedBox(height: 16.0),
              _isRecording
                  ? ElevatedButton(
                      onPressed: _stopRecording,
                      child: Text('Stop Recording'),
                    )
                  : ElevatedButton(
                      onPressed: _startRecording,
                      child: Text('Start Recording'),
                    ),
              SizedBox(height: 16.0),
              SwitchListTile(
                title: Text('Status Skema 1'),
                value: _status,
                onChanged: (value) {
                  setState(() {
                    _status = value;
                  });
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _addIsiGambar,
                child: Text('Add Isi Gambar'),
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
