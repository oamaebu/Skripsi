import 'package:app/provider/gambar_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/models/isi_gambar.dart';


class EditIsiGambarPage extends StatefulWidget {
  final IsiGambar isiGambar;

  EditIsiGambarPage({required this.isiGambar});

  @override
  _EditIsiGambarPageState createState() => _EditIsiGambarPageState();
}

class _EditIsiGambarPageState extends State<EditIsiGambarPage> {
  late TextEditingController _labelController;
  late TextEditingController _gambar1Controller;
  late TextEditingController _gambar2Controller;
  late TextEditingController _gambar3Controller;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.isiGambar.label);
    _gambar1Controller = TextEditingController(text: widget.isiGambar.gambar1);
    _gambar2Controller = TextEditingController(text: widget.isiGambar.gambar2);
    _gambar3Controller = TextEditingController(text: widget.isiGambar.gambar3);
  }

  @override
  void dispose() {
    _labelController.dispose();
    _gambar1Controller.dispose();
    _gambar2Controller.dispose();
    _gambar3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isiGambarProvider = Provider.of<IsiGambarProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Isi Gambar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _labelController,
              decoration: InputDecoration(labelText: 'Label'),
              onChanged: (value) {
                widget.isiGambar.label = value;
              },
            ),
            TextField(
              controller: _gambar1Controller,
              decoration: InputDecoration(labelText: 'Gambar 1'),
              onChanged: (value) {
                widget.isiGambar.gambar1 = value;
              },
            ),
            TextField(
              controller: _gambar2Controller,
              decoration: InputDecoration(labelText: 'Gambar 2'),
              onChanged: (value) {
                widget.isiGambar.gambar2 = value;
              },
            ),
            TextField(
              controller: _gambar3Controller,
              decoration: InputDecoration(labelText: 'Gambar 3'),
              onChanged: (value) {
                widget.isiGambar.gambar3 = value;
              },
            ),
            // Add more fields for other properties as needed
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await isiGambarProvider.updateIsiGambar(widget.isiGambar);
                    Navigator.pop(context);
                  },
                  child: Text('Save'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await isiGambarProvider.deleteIsiGambar(widget.isiGambar.id);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                 // Red color for delete button
                  ),
                  child: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
