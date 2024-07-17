import 'package:app/screens/dashboard/components/Tambah_anak.dart';

import 'package:app/screens/main/add_gambar_tema.dart';
import 'package:app/screens/main/list_level.dart';
import 'package:app/screens/main/list_skema_edit.dart';

import 'package:app/screens/main/tambah_level.dart';
import 'package:flutter/material.dart';

import 'package:app/responsive.dart';
import '../../../constants.dart';
import 'file_info_card.dart';

class MyFiles extends StatelessWidget {
  const MyFiles({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;

    void _showAddChildDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width: _size.width * 0.8,
              height: _size.height * 0.8,
              child: AddAnakForm(),
            ),
          );
        },
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Dashboard Guru",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.bold, // Change the color to your desired color
                  fontSize: 20, // Change the font size to your desired size
                  // You can also specify other properties like fontWeight, fontStyle, etc.
                ),
              ),
            ),
            ElevatedButton.icon(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: defaultPadding * 1.5,
                  vertical:
                      defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
                ),
              ),
              onPressed: () => _showAddChildDialog(context),
              icon: Icon(Icons.add),
              label: Text("Add New"),
            ),
          ],
        ),
        SizedBox(height: defaultPadding),
        Responsive(
          mobile: FileInfoCardGridView(
            crossAxisCount: _size.width < 650 ? 2 : 4,
            childAspectRatio: _size.width < 650 && _size.width > 350 ? 1.3 : 1,
          ),
          tablet: FileInfoCardGridView(),
          desktop: FileInfoCardGridView(
            childAspectRatio: _size.width < 1400 ? 1.1 : 1.4,
          ),
        ),
      ],
    );
  }
}

class FileInfoCardGridView extends StatelessWidget {
  const FileInfoCardGridView({
    Key? key,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1,
  }) : super(key: key);

  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 2, // We have two cards to display
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) {
        if (index == 0) {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddIsiGambarPagetema()),
              );
            },
            child: FileInfoCard(
              title: 'Masukkan Gambar',
              icon: Icons.image,
              color: Colors.blue,
            ),
          );
        } else {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ListSkemaPage()), // Replace with your ListLevelPage
              );
            },
            child: FileInfoCard(
              title: 'Lihat List Gambar',
              icon: Icons.list,
              color: Colors.green,
            ),
          );
        }
      },
    );
  }
}
