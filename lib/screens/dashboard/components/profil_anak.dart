import 'package:app/auth/auth_service.dart';
import 'package:app/models/Anak.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../constants.dart';

import 'storage_info_card.dart';
import 'package:app/provider/anak_provider.dart';
import 'package:app/screens/children/homepage.dart';

class profilAnak extends StatefulWidget {
  final File? _photo;

  const profilAnak({Key? key, File? photo})
      : _photo = photo,
        super(key: key);

  @override
  _StorageDetailsState createState() => _StorageDetailsState();
}

class _StorageDetailsState extends State<profilAnak> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _logout(BuildContext context) async {
    final _authService = AuthService();
    await _authService.logout();
    Navigator.pushReplacementNamed(context, '/Login');
  }

  @override
  Widget build(BuildContext context) {
    final anakProvider = Provider.of<AnakProvider>(context);
    final currentAnak = anakProvider.currentAnak;

    // Define constant IconData values for each card
    IconData namaIcon = Icons.person;
    IconData kelasIcon = Icons.school;
    IconData umurIcon = Icons.accessibility;
    IconData kelaminIcon = Icons.wc;

    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
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
            StorageInfoCard(
              iconData: namaIcon,
              title: "Nama",
              numOfFiles: '${currentAnak.nama}',
            ),
            StorageInfoCard(
              iconData: kelasIcon,
              title: "Kelas",
              numOfFiles: '${currentAnak.kelas}',
            ),
            StorageInfoCard(
              iconData: umurIcon,
              title: "Umur",
              numOfFiles: '${currentAnak.id.toString()}',
            ),
            StorageInfoCard(
              iconData: kelaminIcon,
              title: "Kelamin",
              numOfFiles: '${currentAnak.kelamin.toString()}',
            ),
            SizedBox(height: 10),
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
    );
  }
}
