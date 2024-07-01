import 'dart:io';
import 'package:app/models/puzzle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app/provider/puzzle_provider.dart';

class AddPuzzlePage extends StatefulWidget {
  @override
  _AddPuzzlePageState createState() => _AddPuzzlePageState();
}

class _AddPuzzlePageState extends State<AddPuzzlePage> {
  final _formKey = GlobalKey<FormState>();
  final _levelController = TextEditingController();
  String? _selectedKelas;
  File? _gambarSalah1;
  File? _gambarSalah2;
  File? _gambarBenar;

  Future<void> _pickImage(ImageSource source, int imageType) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        if (imageType == 1) {
          _gambarSalah1 = File(pickedFile.path);
        } else if (imageType == 2) {
          _gambarSalah2 = File(pickedFile.path);
        } else if (imageType == 3) {
          _gambarBenar = File(pickedFile.path);
        }
      });
    }
  }

  void _addPuzzle() {
    if (_formKey.currentState!.validate()) {
      final newPuzzle = puzzle(
        id: null,
        level: int.parse(_levelController.text),
        kelas: _selectedKelas ?? '1',
        GambarSalah1: _selectedKelas == '2' ? '' : _gambarSalah1?.path ?? '',
        GambarSalah2: _selectedKelas == '2' ? '' : _gambarSalah2?.path ?? '',
        GambarBenar: _gambarBenar?.path ?? '',
        idGame: 1, // Always set to 1
      );

      Provider.of<PuzzleProvider>(context, listen: false).addPuzzle(newPuzzle);

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Puzzle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedKelas,
                onChanged: (newValue) {
                  setState(() {
                    _selectedKelas = newValue;
                  });
                },
                decoration: InputDecoration(labelText: 'Kelas'),
                items: ['1', '2', '3'].map((kelas) {
                  return DropdownMenuItem<String>(
                    value: kelas,
                    child: Text(kelas),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a kelas';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _levelController,
                decoration: InputDecoration(labelText: 'Level'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter level';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              if (_selectedKelas != '2') ...[
                Text('Gambar Salah 1:'),
                _gambarSalah1 == null
                    ? ElevatedButton(
                        onPressed: () => _pickImage(ImageSource.gallery, 1),
                        child: Text('Pick Image'),
                      )
                    : Image.file(_gambarSalah1!),
                SizedBox(height: 16.0),
                Text('Gambar Salah 2:'),
                _gambarSalah2 == null
                    ? ElevatedButton(
                        onPressed: () => _pickImage(ImageSource.gallery, 2),
                        child: Text('Pick Image'),
                      )
                    : Image.file(_gambarSalah2!),
                SizedBox(height: 16.0),
              ],
              Text('Gambar Benar:'),
              _gambarBenar == null
                  ? ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.gallery, 3),
                      child: Text('Pick Image'),
                    )
                  : Image.file(_gambarBenar!),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _addPuzzle,
                child: Text('Add Puzzle'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _levelController.dispose();
    super.dispose();
  }
}
