import 'package:app/constants.dart';
import 'package:app/models/Anak.dart';
import 'package:app/models/user.dart';
import 'package:app/provider/anak_provider.dart';
import 'package:app/screens/main/main_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/constants.dart';
import 'package:app/models/Anak.dart';
import 'package:app/provider/anak_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuatProfilAnak extends StatelessWidget {
  const BuatProfilAnak({super.key});

  @override
  Widget build(BuildContext context) {
    final anaksProvider = Provider.of<AnakProvider>(context, listen: false);

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Text(
                    'Buat Data Anak',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: MyForm(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _umurController = TextEditingController();
  final _kelasController = TextEditingController();
  final ValueNotifier<String?> _jenisKelaminController =
      ValueNotifier<String?>(null);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            TextFormField(
              controller: _namaController,
              decoration: InputDecoration(
                labelText: 'Nama',
                labelStyle: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukan Nama Anak';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _umurController,
              decoration: InputDecoration(
                labelText: 'Umur',
                labelStyle: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukan Umur Anak';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _kelasController,
              decoration: InputDecoration(
                labelText: 'Kelas',
                labelStyle: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukan Kelas Anak';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            ValueListenableBuilder<String?>(
              valueListenable: _jenisKelaminController,
              builder: (context, value, child) {
                return DropdownButtonFormField<String>(
                  value: value,
                  decoration: InputDecoration(
                    labelText: 'Jenis Kelamin',
                    labelStyle: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  items: <String>['Laki-Laki', 'Perempuan'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    _jenisKelaminController.value = newValue;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pilih Gender Anak';
                    }
                    return null;
                  },
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Processing Data')),
                  );

                  // Create the new Anak instance
                  Anak newAnak = Anak(
                    id: 0,
                    nama: _namaController.text,
                    umur: int.parse(_umurController.text),
                    kelas: _kelasController.text,
                    kelamin: _jenisKelaminController.value!,
                  );

                  // Insert data into the database
                  final anakProvider =
                      Provider.of<AnakProvider>(context, listen: false);
                  anakProvider.addAnak(newAnak);

                  // Set the current anak
                  anakProvider.setCurrentAnak(newAnak);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Data Anak Berhasil Ditambahkan')),
                  );

                  // Navigate to MainScreen using MaterialPageRoute
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainScreen(),
                    ),
                  );
                }
              },
              child: Text('Submit'),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _umurController.dispose();
    _kelasController.dispose();
    _jenisKelaminController.dispose();
    super.dispose();
  }
}
