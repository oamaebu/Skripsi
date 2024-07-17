import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/models/isi_gambar.dart';
import 'package:app/provider/gambar_provider.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:audioplayers/audioplayers.dart';

class GridPage extends StatefulWidget {
  final int idTema;

  const GridPage({Key? key, required this.idTema}) : super(key: key);

  @override
  _GridPageState createState() => _GridPageState();
}

class _GridPageState extends State<GridPage>
    with SingleTickerProviderStateMixin {
  List<String> _images = [];
  List<String> uniqueImages = [];
  List<String> _correctImages = [];
  List<String> _wrongImages = [];
  int grid = 6;
  int gridColumns = 3;
  int gridRows = 2;
  List<String> defaultImages = [
    'assets/images/maskot.png',
    'assets/images/maskot.png',
    'assets/images/maskot.png'
  ];
  late String label = '';
  List<bool> _clicked = List.generate(6, (index) => false);
  List<IsiGambar> allImages = [];
  int currentLevel = 1;
  int totalLevels = 3;
  late AnimationController _animationController;
  List<bool> _showRedMark = List.generate(6, (index) => false);
  final AudioPlayer _audioPlayer = AudioPlayer();

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
    _audioPlayer.dispose();
    super.dispose();
  }

  void _goToNextLevel() {
    if (currentLevel < totalLevels) {
      setState(() {
        currentLevel++;
        // Adjust grid size based on the level
        if (currentLevel == 2) {
          gridColumns = 3;
          gridRows = 3;
        } else if (currentLevel == 3) {
          gridColumns = 4;
          gridRows = 3;
        }
      });
      _setupCurrentLevel(); // Call this to set up the new level
    } else {
      _showGameCompletionDialog();
    }
  }

  void _showLevelCompletionDialog(VoidCallback onContinue) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: 'Level Complete!',
      desc: 'You have completed level $currentLevel!',
      btnOkText: 'Next Level',
      btnOkOnPress: () {
        onContinue();
      },
      autoHide: Duration(seconds: 2), // Auto-hide after 2 seconds
    )..show();
  }

  void _goToPreviousLevel() {
    if (currentLevel > 1) {
      setState(() {
        currentLevel--;
        // Adjust grid size based on the level
        if (currentLevel == 1) {
          gridColumns = 3;
          gridRows = 2;
        } else if (currentLevel == 2) {
          gridColumns = 3;
          gridRows = 3;
        }
      });
      _setupCurrentLevel(); // Call this to set up the new level
    }
  }

  void _showGameCompletionDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: 'Congratulations!',
      desc: 'You have completed all levels!',
      btnOkText: 'Finish',
      btnOkOnPress: () {
        Navigator.of(context).pop(); // Return to the previous screen
      },
    )..show();
  }

  Future<void> _fetchImages() async {
    final provider = Provider.of<IsiGambarProvider>(context, listen: false);
    await provider.fetchIsiGambarList();

    allImages = provider.getGambarByTema(widget.idTema);

    print('Total levels: $totalLevels');

    _setupCurrentLevel();
  }

  void _setupCurrentLevel() {
    // Determine the number of images needed for the current level
    int imagesNeeded = gridColumns * gridRows;

    // Reset _images
    _images = [];

    // Use available unique images first
    int uniqueImagesAvailable =
        allImages.length * 3; // Each allImages entry has 3 images
    int uniqueImagesToUse = min(uniqueImagesAvailable, imagesNeeded);

    for (int i = 0; i < uniqueImagesToUse; i++) {
      int imageSetIndex = i ~/ 3;
      int imageIndex = i % 3;
      String imagePath;
      switch (imageIndex) {
        case 0:
          imagePath = allImages[imageSetIndex].gambar1;
          break;
        case 1:
          imagePath = allImages[imageSetIndex].gambar2;
          break;
        case 2:
          imagePath = allImages[imageSetIndex].gambar3;
          break;
        default:
          imagePath = defaultImages[0];
      }
      _images.add(imagePath);
    }

    // Fill the rest with default images
    while (_images.length < imagesNeeded) {
      _images.add(defaultImages[_images.length % defaultImages.length]);
    }

    // Shuffle images
    _images.shuffle();

    // Set correct images and label for the current level
    if (allImages.length >= currentLevel) {
      int index = currentLevel - 1;
      _correctImages = [
        allImages[index].gambar1,
        allImages[index].gambar2,
        allImages[index].gambar3,
      ];
      label = allImages[index].label;
    } else {
      // If no unique images available for this level, use default images and label
      _correctImages = defaultImages.take(3).toList();
      label = 'Default Label for Level $currentLevel';
    }

    // Initialize clicked and showRedMark lists
    _clicked = List.generate(_images.length, (index) => false);
    _showRedMark = List.generate(_images.length, (index) => false);

    // Trigger UI update
    setState(() {});
  }

  void _checkIfCorrectImagesSelected() {
    // Get indices of clicked correct images
    List<int> correctIndices = _images
        .asMap()
        .entries
        .where((entry) {
          int index = entry.key;
          String image = entry.value;
          return _correctImages.contains(image) && _clicked[index];
        })
        .map((entry) => entry.key)
        .toList();

    // Check if exactly three correct images are selected
    bool allCorrectSelected = correctIndices.length == 3;

    if (allCorrectSelected) {
      _goToNextLevel();
    } else {
      // If any wrong image is selected, show red marks
      bool anyWrongSelected = _clicked.asMap().entries.any((entry) {
        int index = entry.key;
        bool isSelected = entry.value;
        return isSelected && !_correctImages.contains(_images[index]);
      });

      if (anyWrongSelected) {
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
    int asd = _images.length;
    print(_images);
    final animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0.05, 0),
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_animationController);

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
                  'Pilih Gambar', // Display the fixed text at the top
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label ?? '', // Display isiGambar.label if not null
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  iconSize: 40,
                  color: Colors.white,
                  onPressed: currentLevel > 1 ? _goToPreviousLevel : null,
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  iconSize: 40,
                  color: Colors.white,
                  onPressed: currentLevel < totalLevels ? _goToNextLevel : null,
                ),
              ],
            ),
          ],
        ),
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
      return AssetImage('assets/images/maskot.png');
    }
  }
}
