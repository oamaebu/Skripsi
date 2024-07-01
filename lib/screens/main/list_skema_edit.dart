import 'dart:io';

import 'package:app/provider/gambar_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app/models/isi_gambar.dart';

class ListSkemaPage extends StatefulWidget {
  @override
  _ListSkemaPageState createState() => _ListSkemaPageState();
}

class _ListSkemaPageState extends State<ListSkemaPage> {
  String? _selectedTingkatKesulitan;

  @override
  Widget build(BuildContext context) {
    final isiGambarProvider = Provider.of<IsiGambarProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ubah Status Skema'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedTingkatKesulitan,
              onChanged: (newValue) {
                setState(() {
                  _selectedTingkatKesulitan = newValue;
                });
                if (newValue != null) {
                  isiGambarProvider.fetchIsiGambarByTingkatKesulitan(newValue);
                } else {
                  isiGambarProvider.fetchIsiGambarList();
                }
              },
              decoration: InputDecoration(labelText: 'Tingkat Kesulitan'),
              items: ['mudah', 'sedang', 'sulit'].map((tingkat) {
                return DropdownMenuItem<String>(
                  value: tingkat,
                  child: Text(tingkat),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: Consumer<IsiGambarProvider>(
                builder: (context, provider, _) {
                  return ListView.builder(
                    itemCount: provider.isiGambarList.length,
                    itemBuilder: (context, index) {
                      final isiGambar = provider.isiGambarList[index];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ListTile(
                          leading: Image.file(File(isiGambar.gambar1)),
                          title: Text(isiGambar.label),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Delete Confirmation'),
                                    content: Text(
                                        'Are you sure you want to delete this item?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await isiGambarProvider
                                              .deleteIsiGambar(isiGambar.id);
                                          Navigator.pop(context);
                                        },
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
