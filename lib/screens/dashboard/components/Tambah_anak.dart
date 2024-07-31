import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/anak_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:app/models/Anak.dart';

class AddAnakForm extends StatefulWidget {
  const AddAnakForm({Key? key}) : super(key: key);

  @override
  _AddAnakFormState createState() => _AddAnakFormState();
}

class _AddAnakFormState extends State<AddAnakForm> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController umurController = TextEditingController();
  String? _selectedKelas;
  String? _picturePath;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _picturePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final anakProvider = Provider.of<AnakProvider>(context);
    return AlertDialog(
      title: Text('Tambah Anak'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: namaController,
              decoration: InputDecoration(labelText: 'Nama'),
            ),
            TextFormField(
              controller: umurController,
              decoration: InputDecoration(labelText: 'Umur'),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: _selectedKelas,
              onChanged: (newValue) {
                setState(() {
                  _selectedKelas = newValue;
                });
              },
              decoration: InputDecoration(labelText: 'Kelas'),
              items: ['1', '2', '3']
                  .map((kelas) => DropdownMenuItem<String>(
                        value: kelas,
                        child: Text(kelas),
                      ))
                  .toList(),
            ),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.photo),
              label: Text('Pilih Foto'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            final String nama = namaController.text;
            final int umur = int.parse(umurController.text);
            final String kelas =
                _selectedKelas ?? ''; // Validate if kelas is null
            final Anak newAnak = Anak(
              id: null, // You can set this to 0 or null since it will be auto-generated
              nama: nama,
              umur: umur,
              kelas: kelas,
              kelamin: '-'
            );
            anakProvider.addAnak(newAnak);
            Navigator.of(context).pop();
          },
          child: Text('Simpan'),
        ),
      ],
    );
  }
}
