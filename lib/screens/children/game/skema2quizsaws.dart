import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/models/isi_gambar.dart';
import 'package:app/provider/gambar_provider.dart';

class GridPage extends StatefulWidget {
  final int idTema;

  const GridPage({Key? key, required this.idTema}) : super(key: key);

  @override
  _GridPageState createState() => _GridPageState();
}

class _GridPageState extends State<GridPage>
    with SingleTickerProviderStateMixin {
  List<String> _images = [];
  List<String> _correctImages = [];
  List<String> _wrongImages = [];
  List<String> usedImages = [];
  List<String> defaultImages = [
    'assets/images/maskot.png',
    'assets/images/maskot.png',
    'assets/images/maskot.png'
  ];
  late String label;
  List<bool> _clicked = [];
  List<IsiGambar> allImages = [];
  int currentLevel = 1;
  final int totalLevels = 3; // Always 3 levels
  late AnimationController _animationController;
  List<bool> _showRedMark = [];

  // Add variables to track grid size
  int gridColumns = 3;
  int gridRows = 2;

  @override
  void initState() {
    super.initState();
    _fetchImages();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchImages() async {
    final provider = Provider.of<IsiGambarProvider>(context, listen: false);
    await provider.fetchIsiGambarList();

    allImages = provider.getGambarByTema(widget.idTema);

    // Duplicate images if we don't have enough for all levels
    int totalImagesNeeded =
        4 * 3 * totalLevels; // Maximum grid size * total levels
    while (allImages.length < totalImagesNeeded) {
      allImages.addAll(List.from(allImages));
    }

    _setupCurrentLevel();
  }

  void _goToNextLevel() {
    if (currentLevel < totalLevels) {
      currentLevel++;
      // Change grid size based on the current level
      if (currentLevel == 2) {
        gridColumns = 3;
        gridRows = 3;
      } else if (currentLevel == 3) {
        gridColumns = 4;
        gridRows = 3;
      }
      _setupCurrentLevel();
    } else {
      showGameCompletedDialog();
    }
  }

  void _setupCurrentLevel() {
    int totalImages = gridColumns * gridRows;
    int correctImagesCount = 3; // Always 3 correct images

    _correctImages = [];
    _wrongImages = [];

    if (currentLevel == 1) {
      // For the first level, use all available images from the database
      for (var isiGambar in allImages) {
        _correctImages.add(isiGambar.gambar1 ?? '');
        _correctImages.add(isiGambar.gambar2 ?? '');
        _correctImages.add(isiGambar.gambar3 ?? '');
      }
      _correctImages.removeWhere((image) => image.isEmpty);
      usedImages = List.from(_correctImages);
    } else {
      // For subsequent levels, use 3 default images and 6 from the previous level
      _correctImages = List.from(defaultImages);
      _correctImages.addAll(usedImages.take(6));
    }

    // Shuffle and take only 3 correct images
    _correctImages.shuffle();
    _correctImages = _correctImages.take(3).toList();

    label = allImages.isNotEmpty ? allImages[0].label : '';
 
    // Fill the rest with wrong images
    _wrongImages = List.from(usedImages)..addAll(defaultImages);
    _wrongImages.removeWhere((image) => _correctImages.contains(image));
    _wrongImages.shuffle();
    _wrongImages = _wrongImages.take(totalImages - 3).toList();

    _images = List.from(_correctImages)..addAll(_wrongImages);
    _images.shuffle();

    // Ensure _images has exactly totalImages elements
    while (_images.length < totalImages) {
      _images.add(defaultImages[0]); // Add default image
    }
    _images = _images.take(totalImages).toList();

    _clicked = List.generate(_images.length, (index) => false);
    _showRedMark = List.generate(_images.length, (index) => false);

    setState(() {});
  }

  void _checkIfCorrectImagesSelected() {
    int selectedCount = _clicked.where((isSelected) => isSelected).length;

    if (selectedCount > 3) {
      // If more than 3 images are selected, do nothing
      return;
    }

    if (selectedCount == 3) {
      bool allCorrect = _clicked.asMap().entries.every((entry) {
        int index = entry.key;
        bool isSelected = entry.value;
        return !isSelected || _correctImages.contains(_images[index]);
      });

      if (allCorrect) {
        _goToNextLevel();
      } else {
        // Show wrong selection feedback
        _animationController.forward(from: 0.0);
        setState(() {
          _showRedMark = List.generate(_images.length, (index) {
            return _clicked[index] && !_correctImages.contains(_images[index]);
          });
        });
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _clicked = List.generate(_images.length, (index) => false);
            _showRedMark = List.generate(_images.length, (index) => false);
          });
        });
      }
    }
  }

  void showGameCompletedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Congratulations!'),
        content: Text('You have completed all 3 levels.'),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              // You might want to navigate back to the main menu or restart the game here
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
        actions: [
          Container(
            alignment: AlignmentDirectional.topEnd,
            padding: EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                // Handle sound icon tap
                print('Sound icon tapped');
              },
              child: Icon(
                Icons.volume_up,
                size: 36.0,
                color: Colors.white,
              ),
            ),
          ),
        ],
        title: Text(
          'Level $currentLevel',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  'Pilih Gambar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label ?? '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width * 0.1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              color: Colors.white,
              child: Center(
                child: _images.isEmpty
                    ? CircularProgressIndicator()
                    : Container(
                        child: GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: gridColumns,
                          children:
                              List.generate(gridColumns * gridRows, (index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _clicked[index] = !_clicked[index];
                                  _checkIfCorrectImagesSelected();
                                });
                              },
                              child: Stack(
                                children: [
                                  AnimatedOpacity(
                                    opacity: _clicked[index] ? 0.3 : 1.0,
                                    duration: Duration(milliseconds: 100),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        image: DecorationImage(
                                          image:
                                              _getImageProvider(_images[index]),
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
                                        color: _correctImages
                                                .contains(_images[index])
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
            ),
            IconButton(
                icon: Icon(Icons.navigate_next),
                iconSize: 20,
                color: Colors.white,
                onPressed: _goToNextLevel)
          ],
        ),
      ),
    );
  }

  ImageProvider _getImageProvider(String imageUrl) {
    if (imageUrl.startsWith('assets/')) {
      return AssetImage(imageUrl);
    } else if (imageUrl.startsWith('http')) {
      return NetworkImage(imageUrl);
    } else if (imageUrl.startsWith('/data/user/0/com.example.app/cache/')) {
      return FileImage(File(imageUrl));
    } else {
      return AssetImage('assets/images/maskot.png');
    }
  }
}
