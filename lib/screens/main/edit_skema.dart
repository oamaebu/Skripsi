import 'dart:io';

import 'package:app/provider/gambar_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app/models/isi_gambar.dart';

class UbahStatusSkemaPage extends StatefulWidget {
  final String skema;

  UbahStatusSkemaPage({Key? key, required this.skema}) : super(key: key);
  @override
  _UbahStatusSkemaPageState createState() => _UbahStatusSkemaPageState();
}

class _UbahStatusSkemaPageState extends State<UbahStatusSkemaPage> {
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
                          trailing: Switch(
                            value: getStatusSkemaValue(isiGambar),
                            onChanged: (value) {
                              setState(() {
                                switch (widget.skema) {
                                  case 'statusSkema1':
                                    isiGambar.statusSkema1 = value;
                                    break;
                                  case 'statusSkema2':
                                    isiGambar.statusSkema2 = value;
                                    break;
                                  case 'statusSkema3':
                                    isiGambar.statusSkema3 = value;
                                    break;
                                  default:
                                    break;
                                }
                              });
                              provider.updateIsiGambar(isiGambar);
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

  bool getStatusSkemaValue(IsiGambar isiGambar) {
    switch (widget.skema) {
      case 'statusSkema1':
        return isiGambar.statusSkema1;
      case 'statusSkema2':
        return isiGambar.statusSkema2;
      case 'statusSkema3':
        return isiGambar.statusSkema3;
      default:
        return false;
    }
  }
}
