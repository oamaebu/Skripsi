import 'package:app/constants.dart';
import 'package:app/models/Anak.dart';
import 'package:app/provider/anak_provider.dart'; // Ensure this is the correct import for AnakProvider
import 'package:app/screens/children/homepage.dart';
import 'package:app/screens/main/data_anak.dart'; // Ensure this is the correct import for DetailPage
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class ListAnak extends StatefulWidget {
  const ListAnak({Key? key}) : super(key: key);

  @override
  ListAnakState createState() => ListAnakState();
}

class ListAnakState extends State<ListAnak> {
  @override
  Widget build(BuildContext context) {
    final anakProvider = Provider.of<AnakProvider>(context);
    final List<Anak> anakList = anakProvider.anaks;

    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "List Anak",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: defaultPadding,
              columns: [
                DataColumn(label: Text("Nama")),
                DataColumn(label: Text("Kelas")),
                DataColumn(label: Text("bermain")),
              ],
              rows: List.generate(
                anakList.length,
                (index) {
                  final anak = anakList[index];
                  return DataRow(
                    cells: [
                      DataCell(
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPage(
                                  childId: anak.id!,
                                ),
                              ),
                            );
                            anakProvider.setCurrentAnak(anak);
                          },
                          child: Text(anak.nama),
                        ),
                      ),
                      DataCell(Text(anak.id.toString())),
                      DataCell(
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(quiz: false),
                              ),
                            );
                            anakProvider.setCurrentAnak(anak);
                          },
                          child: Text('Main Sekarang'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) {
      return Icon(Icons.broken_image, size: 50);
    }
    if (path.startsWith('http') || path.startsWith('https')) {
      return Image.network(
        path,
        height: 50,
        width: 50,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.broken_image, size: 50),
      );
    } else {
      return Image.file(
        File(path),
        height: 50,
        width: 50,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.broken_image, size: 50),
      );
    }
  }
}
