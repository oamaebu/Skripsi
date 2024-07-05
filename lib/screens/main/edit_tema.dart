import 'dart:io';

import 'package:app/provider/gambar_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app/models/isi_gambar.dart';

class UbahStatusTemaPage extends StatefulWidget {
  final int idtema;

  UbahStatusTemaPage({Key? key, required this.idtema}) : super(key: key);

  @override
  _UbahStatusTemaPageState createState() => _UbahStatusTemaPageState();
}

class _UbahStatusTemaPageState extends State<UbahStatusTemaPage> {
  String? _selectedTingkatKesulitan;
  bool _isAllChecked = false;

  @override
  Widget build(BuildContext context) {
    final isiGambarProvider = Provider.of<IsiGambarProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ubah Status Tema'),
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
                  _isAllChecked = false; // Reset the check all status
                });
                if (newValue != null) {
                  isiGambarProvider.fetchIsiGambarByTingkatKesulitan(newValue);
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
                  // Filter the isiGambarList based on idtema
                  final filteredList = provider.isiGambarList
                      .where((isiGambar) => isiGambar.idtema == widget.idtema)
                      .toList();

                  return Column(
                    children: [
                      CheckboxListTile(
                        title: Text('Aktifkan Semua'),
                        value: _isAllChecked,
                        onChanged: (value) {
                          setState(() {
                            _isAllChecked = value!;
                          });
                          provider.updateAllStatuses(
                              filteredList, _isAllChecked);
                        },
                      ),
                      SizedBox(height: 16.0),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final isiGambar = filteredList[index];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: ListTile(
                                leading: Image.file(File(isiGambar.gambar1)),
                                title: Text(isiGambar.label),
                                trailing: Switch(
                                  value:
                                      isiGambar.status, // Use the status field
                                  onChanged: (value) {
                                    setState(() {
                                      isiGambar.status =
                                          value; // Update the status
                                    });
                                    provider.updateIsiGambar(isiGambar);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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
