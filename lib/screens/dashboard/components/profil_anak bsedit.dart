import 'package:app/auth/auth_service.dart';
import 'package:app/models/Anak.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../constants.dart';

import 'storage_info_card.dart';
import 'package:app/provider/anak_provider.dart';
import 'package:app/screens/children/homepage.dart';

class StorageDetails extends StatefulWidget {
  final File? _photo;

  const StorageDetails({Key? key, File? photo})
      : _photo = photo,
        super(key: key);

  @override
  _StorageDetailsState createState() => _StorageDetailsState();
}

class _StorageDetailsState extends State<StorageDetails> {
  late TextEditingController _namaController;
  late TextEditingController _kelasController;
  late TextEditingController _umurController;
  late TextEditingController _kelaminController;

  @override
  void initState() {
    super.initState();
    checkAnakWithIdZero();
    _namaController = TextEditingController();
    _kelasController = TextEditingController();
    _umurController = TextEditingController();
    _kelaminController = TextEditingController();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kelasController.dispose();
    _umurController.dispose();
    _kelaminController.dispose();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    final _authService = AuthService();
    await _authService.logout();
    Navigator.pushReplacementNamed(context, '/Login');
  }

  void checkAnakWithIdZero() async {
    final anakProvider = Provider.of<AnakProvider>(context, listen: false);
    await anakProvider.getAnak();
    anakProvider.setCurrentAnak(anakProvider.getAnakByIdZero());
  }

  Widget _buildEditableField(
      String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final anakProvider = Provider.of<AnakProvider>(context);
    final currentAnak = anakProvider.currentAnak;

    if (currentAnak != null) {
      _namaController.text = currentAnak.nama;
      _kelasController.text = currentAnak.kelas;
      _umurController.text = currentAnak.id.toString();
      _kelaminController.text = currentAnak.kelamin.toString();
    }

    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Detail Anak",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: defaultPadding),
            CircleAvatar(
              radius: 100,
              backgroundColor: Colors.grey.shade200,
              child: widget._photo == null
                  ? Icon(
                      Icons.person,
                      size: 75,
                      color: Colors.grey,
                    )
                  : null,
            ),
            SizedBox(height: defaultPadding),
            if (currentAnak != null) ...[
              _buildEditableField("Nama", _namaController, Icons.person),
              _buildEditableField("Kelas", _kelasController, Icons.school),
              _buildEditableField("Umur", _umurController, Icons.accessibility),
              _buildEditableField("Kelamin", _kelaminController, Icons.wc),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement save functionality
                  // Update the currentAnak object with new values
                  // Call anakProvider.updateAnak(currentAnak) or similar method
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Changes saved!')),
                  );
                },
                child: Text('Save Changes'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(
                        quiz: false,
                      ),
                    ),
                  );
                },
                child: Text('Main Sekarang'),
              ),
            ] else ...[
              Text(
                'No data available for the selected child.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              )
            ],
          ],
        ),
      ),
    );
  }
}
