import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:app/models/isi_gambar.dart';
import 'package:app/provider/gambar_provider.dart';

class GridPage extends StatefulWidget {
  final int idTema;

  const GridPage({Key? key, required this.idTema}) : super(key: key);

  @override
  _GridPageState createState() => _GridPageState();
}

class _GridPageState extends State<GridPage> {
  List<String> _images = [];
  List<String> _correctImages = [];
  List<String> _wrongImages = [];
  List<bool> _clicked = List.generate(6, (index) => false);
  List<IsiGambar> allImages = [];
  int currentLevel = 1;
  int totalLevels = 0;

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    final provider = Provider.of<IsiGambarProvider>(context, listen: false);
    await provider.fetchIsiGambarList();

    allImages = provider.getGambarByTema(widget.idTema);
    totalLevels = allImages.length ~/ 2; // Integer division by 2
    print('Total levels: $totalLevels');

    if (allImages.length < 2) {
      showNotEnoughImagesDialog();
      return;
    }

    _setupCurrentLevel();
  }

  void _setupCurrentLevel() {
    allImages.shuffle();

    _correctImages = [
      allImages[0].gambar1,
      allImages[0].gambar2,
      allImages[0].gambar3,
    ];
    allImages.removeAt(0);

    _wrongImages = [
      allImages[0].gambar1,
      allImages[0].gambar2,
      allImages[0].gambar3,
    ];
    allImages.removeAt(0);

    _images = List.from(_correctImages)..addAll(_wrongImages);
    _images.shuffle();
    setState(() {});
  }

  void _goToNextLevel() {
    print('Current level: $currentLevel, Total levels: $totalLevels');
    if (currentLevel < totalLevels) {
      currentLevel++;
      _clicked = List.generate(6, (index) => false);
      _setupCurrentLevel();
    } else {
      showNotEnoughImagesDialog();
    }
  }

  void showNotEnoughImagesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Game Over'),
        content: Text('You have completed all available levels.'),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Captcha-like Grid of Clickable Images'),
      ),
      body: Center(
        child: _images.isEmpty
            ? CircularProgressIndicator()
            : Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.all(8.0),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                  children: List.generate(6, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _clicked[index] = !_clicked[index];
                        });
                      },
                      child: Stack(
                        children: [
                          AnimatedOpacity(
                            opacity: _clicked[index] ? 0.3 : 1.0,
                            duration: Duration(milliseconds: 500),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                image: DecorationImage(
                                  image: _getImageProvider(_images[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          if (_clicked[index])
                            Center(
                              child: Icon(
                                _correctImages.contains(_images[index])
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: _correctImages.contains(_images[index])
                                    ? Colors.green
                                    : Colors.red,
                                size: 50.0,
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToNextLevel,
        child: Icon(Icons.navigate_next),
      ),
    );
  }

  ImageProvider _getImageProvider(String imageUrl) {
    if (imageUrl.isEmpty) {
      return AssetImage('assets/images/maskot.png');
    } else if (imageUrl.startsWith('http')) {
      return NetworkImage(imageUrl);
    } else if (imageUrl.startsWith('/data/user/0/com.example.app/cache/')) {
      return FileImage(File(imageUrl));
    } else {
      // Default to AssetImage if none of the above conditions are met
      return AssetImage('assets/images/maskot.png');
    }
  }
}
