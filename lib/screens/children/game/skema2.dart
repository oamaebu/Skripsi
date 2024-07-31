import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:app/provider/anak_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/models/isi_gambar.dart';
import 'package:app/provider/gambar_provider.dart';
import 'package:app/provider/game_state_provider.dart';
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
  late AudioPlayer _player;
  bool _isPlayerInitialized = false;
  List<String> _images = [];
  List<String> _correctImages = [];
  int gridColumns = 3;
  int gridRows = 2;
  List<String> defaultImages = [
    'assets/images/maskot.png',
    'assets/images/maskot.png',
    'assets/images/maskot.png'
  ];
  late String label = '';
  late String suara = '';
  late List<bool> _clicked;
  List<IsiGambar> allImages = [];
  int currentLevel = 1;
  int totalLevels = 3;
  late AnimationController _animationController;
  late List<bool> _showRedMark;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Timer? _timer;
  int _remainingTime = 300; // 5 minutes in seconds

  late GameStateProvider _gameStateProvider;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initPlayer();

    _fetchImages();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _gameStateProvider = Provider.of<GameStateProvider>(context, listen: false);
  }

  Future<void> _initPlayer() async {
    if (suara.isNotEmpty) {
      await _player.play(DeviceFileSource(suara));
      setState(() {
        _isPlayerInitialized = true;
      });
    } else {
      print('Error: Sound file path is empty.');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    _player.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer?.cancel();
        _showTimeUpDialog();
      }
    });
  }

  void _resetLevel() {
    setState(() {
      _remainingTime = 300; // Reset time to 5 minutes
      _clicked = List.generate(_images.length, (index) => false);
      _showRedMark = List.generate(_images.length, (index) => false);
    });
    _startTimer();
  }

  void _goToNextLevel() {
    _timer?.cancel();
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
      _startTimer(); // Restart the timer for the new level
    } else {
      _showGameCompletionDialog();
    }
  }

  void _goToPreviousLevel() {
    if (currentLevel > 1) {
      _timer?.cancel();
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
      _startTimer(); // Restart the timer for the new level
    }
  }

  void _showTimeUpDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      title: 'Time\'s Up!',
      desc: 'You have run out of time.',
      btnOkText: 'Try Again',
      btnOkOnPress: () {
        _resetLevel();
      },
    )..show();
  }

  void _showLevelCompletionDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: 'Hebat!',
      desc: 'Kamu berhasil menyelesaikan level ini!',
      btnOkText: 'Lanjut',
      btnOkColor: Colors.blue,
      titleTextStyle: TextStyle(
        color: Colors.blue[800],
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      descTextStyle: TextStyle(
        color: Colors.blue[600],
        fontSize: 18,
      ),
      dialogBackgroundColor: Colors.lightBlue[50],
      borderSide: BorderSide(color: Colors.blue, width: 2),
      width: 400,
      buttonsBorderRadius: BorderRadius.circular(20),
      barrierColor: Colors.black45,
      dismissOnTouchOutside: false,
      headerAnimationLoop: false,
      buttonsTextStyle: TextStyle(color: Colors.white, fontSize: 18),
      showCloseIcon: false,
      btnOkOnPress: () {
        _goToNextLevel();
      },
    )..show();
  }

  void _showGameCompletionDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: 'Selamat!',
      desc:
          'Kamu telah menyelesaikan semua level!\n\nWaktu kamu: ${_formatTime(_remainingTime)}',
      btnOkText: 'Selesai',
      btnOkColor: Colors.blue,
      titleTextStyle: TextStyle(
        color: Colors.blue[800],
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
      descTextStyle: TextStyle(
        color: Colors.blue[600],
        fontSize: 20,
      ),
      dialogBackgroundColor: Colors.lightBlue[50],
      borderSide: BorderSide(color: Colors.blue, width: 3),
      width: 420,
      buttonsBorderRadius: BorderRadius.circular(20),
      barrierColor: Colors.black54,
      dismissOnTouchOutside: false,
      headerAnimationLoop: false,
      buttonsTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      showCloseIcon: false,
      btnOkOnPress: () {
        Navigator.of(context).pop();
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
      suara = allImages[index].suara ?? '';
    } else {
      // If no unique images available for this level, use default images and label
      _correctImages = defaultImages.take(3).toList();
      label = 'Kucing ';
    }

    // Initialize clicked and showRedMark lists
    _clicked = List.generate(_images.length, (index) => false);
    _showRedMark = List.generate(_images.length, (index) => false);

    // Trigger UI update
    _initPlayer();
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
      _showLevelCompletionDialog();
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

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2 , '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final anakProvider = Provider.of<AnakProvider>(context);
    final currentAnak = anakProvider.currentAnak;
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
                if (_isPlayerInitialized) {
                  _initPlayer();
                  print('Sound icon tapped');
                }
              },
              child: Icon(
                Icons.volume_up,
                size: 36.0,
                color: Colors.white,
              ),
            ),
          ),
        ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Level $currentLevel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
                  label,
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
