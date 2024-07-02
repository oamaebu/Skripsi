import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:app/models/isi_gambar.dart';
import 'package:app/provider/anak_provider.dart';
import 'package:app/provider/gambar_provider.dart';
import 'package:app/provider/game_state_provider.dart';
import 'package:app/widget/shake_transition.dart';

class LevelPagetest extends StatefulWidget {
  final int level;
  final String childId;
  final int idTema;

  LevelPagetest(
      {required this.level, required this.childId, required this.idTema});

  @override
  _LevelPagetestState createState() => _LevelPagetestState();
}

class _LevelPagetestState extends State<LevelPagetest> {
  List<IsiGambar> _currentIsiGambarList = [];
  int _currentIndex = 0;
  late GameStateProvider _gameStateProvider;
  final player = AudioPlayer();

  late Stopwatch _stopwatch;
  final GlobalKey<ShakeTransitionState> _wrongImageKey1 =
      GlobalKey<ShakeTransitionState>();
  final GlobalKey<ShakeTransitionState> _wrongImageKey2 =
      GlobalKey<ShakeTransitionState>();

  int _wrongChoices = 0;

  List<String> _shuffledImagePaths = [];

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _gameStateProvider = Provider.of<GameStateProvider>(context, listen: false);

    final isiGambarProvider =
        Provider.of<IsiGambarProvider>(context, listen: false);
    isiGambarProvider.fetchIsiGambarList().then((_) {
      _currentIsiGambarList = isiGambarProvider.getGambarBySkema(widget.idTema);
      if (_currentIsiGambarList.isNotEmpty) {
        _currentIndex = 0;
        _shuffledImagePaths = _shuffleImagePaths(_currentIndex);
        _initPlayer();
      }
      setState(() {});
    });
  }

  Future<void> _initPlayer() async {
    if (_currentIsiGambarList.isNotEmpty &&
        _currentIndex >= 0 &&
        _currentIndex < _currentIsiGambarList.length) {
      final isiGambar = _currentIsiGambarList[_currentIndex];
      if (isiGambar.suara != null && isiGambar.suara!.isNotEmpty) {
        await player.play(DeviceFileSource(isiGambar.suara!));
      }
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void _saveGameState(String time, int anakId) {
    final now = DateTime.now();
    final date = '${now.year}-${now.month}-${now.day}';

    final gameState = {
      'id': null,
      'id_game': 1,
      'waktu': time,
      'id_anak': anakId,
      'tanggal': date,
      'jumlah_salah': _wrongChoices,
    };
    _gameStateProvider.addGameState(gameState);
    print('jumlah_salah: ${gameState['jumlah_salah']}');
  }

  void _navigateToLevel(int index) {
    if (index >= 0 && index < _currentIsiGambarList.length) {
      setState(() {
        _currentIndex = index;
        _shuffledImagePaths = _shuffleImagePaths(_currentIndex);
        _stopwatch.reset();
        _stopwatch.start();
      });
      _initPlayer();
    }
  }

  void _completeLevel(int? anakId) {
    _stopwatch.stop();
    player.play(AssetSource('sound/correct.mp3'));
    _saveGameState(_formatTime(_stopwatch.elapsed), anakId!);
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.rightSlide,
      title: 'Congratulations!',
      desc: 'You have completed the level.',
      btnOkOnPress: () {},
    )..show();
  }

  void _shakeWrongImage(GlobalKey<ShakeTransitionState> key) {
    setState(() {
      _wrongChoices++;
      print('Wrong choices: $_wrongChoices');
    });
    player.play(AssetSource('sound/wrong.mp3'));
    key.currentState?.shake();
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  List<String> _shuffleImagePaths(int index) {
    if (index >= 0 && index < _currentIsiGambarList.length) {
      List<String> imagePaths = [
        _currentIsiGambarList[index].gambar1,
        _currentIsiGambarList[index].gambar2,
        _currentIsiGambarList[index].gambar3,
      ].where((path) => path.isNotEmpty).toList();

      if (imagePaths.isEmpty) {
        return [];
      }

      while (imagePaths.length < 3) {
        imagePaths.add(imagePaths[Random().nextInt(imagePaths.length)]);
      }

      imagePaths.shuffle();
      return imagePaths;
    }
    return [];
  }

  Widget _buildDraggableImage(
      String imagePath, GlobalKey<ShakeTransitionState> key) {
    if (imagePath.isEmpty) {
      return Container();
    }

    return Container(
      color: Colors.white,
      child: Draggable<PuzzlePiece>(
        data: PuzzlePiece(imagePath: imagePath),
        child: Image.file(
          File(imagePath),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.error);
          },
        ),
        feedback: Image.file(
          File(imagePath),
          fit: BoxFit.contain,
          width: 150,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.error, size: 150);
          },
        ),
        childWhenDragging: Container(),
        onDragEnd: (dragDetails) {
          if (!dragDetails.wasAccepted) {
            _shakeWrongImage(key);
          }
        },
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              width: 3,
              color: _currentIndex > 0 ? Colors.white : Colors.grey,
            ),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back),
            iconSize: 48,
            color: _currentIndex > 0 ? Colors.white : Colors.grey,
            onPressed: (_currentIndex > 0)
                ? () => _navigateToLevel(_currentIndex - 1)
                : null,
            tooltip: 'Previous Level',
          ),
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              width: 3,
              color: _currentIndex < _currentIsiGambarList.length - 1
                  ? Colors.white
                  : Colors.grey,
            ),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_forward),
            iconSize: 48,
            color: _currentIndex < _currentIsiGambarList.length - 1
                ? Colors.white
                : Colors.grey,
            onPressed: (_currentIndex < _currentIsiGambarList.length - 1)
                ? () => _navigateToLevel(_currentIndex + 1)
                : null,
            tooltip: 'Next Level',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final anakProvider = Provider.of<AnakProvider>(context);
    final currentAnak = anakProvider.currentAnak;

    return Scaffold(
      appBar: AppBar(
        actions: [
          TimerDisplay(stopwatch: _stopwatch),
        ],
        title: Text(
          'Level ${widget.level}',
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
        child: Consumer<IsiGambarProvider>(
          builder: (context, isiGambarProvider, child) {
            if (_currentIsiGambarList.isEmpty ||
                _currentIndex >= _currentIsiGambarList.length) {
              return Center(
                child: Text(
                  'No images found for the current level',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              );
            }

            final isiGambar = _currentIsiGambarList[_currentIndex];
            String imagePath = _shuffledImagePaths.isNotEmpty
                ? _shuffledImagePaths[
                    Random().nextInt(_shuffledImagePaths.length)]
                : '';

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Pilih Gambar Yang Sama!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    height: 200,
                    child: ShakeTransition(
                      key: _wrongImageKey1,
                      child: DragTarget<PuzzlePiece>(
                        onAccept: (piece) {
                          if (piece.imagePath == imagePath) {
                            _completeLevel(currentAnak?.id);
                          } else {
                            _shakeWrongImage(_wrongImageKey1);
                          }
                        },
                        builder: (context, accepted, rejected) {
                          return imagePath.isNotEmpty
                              ? Image.file(File(imagePath), fit: BoxFit.contain)
                              : Container();
                        },
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children:
                          _shuffledImagePaths.asMap().entries.map((entry) {
                        int index = entry.key;
                        String path = entry.value;
                        return Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: _buildDraggableImage(
                              path,
                              index == 0 ? _wrongImageKey1 : _wrongImageKey2,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildNavigationButtons(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class PuzzlePiece {
  final String imagePath;

  PuzzlePiece({required this.imagePath});
}

class TimerDisplay extends StatefulWidget {
  final Stopwatch stopwatch;

  TimerDisplay({required this.stopwatch});

  @override
  _TimerDisplayState createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<TimerDisplay> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (widget.stopwatch.isRunning) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = widget.stopwatch.elapsed;
    final hours = elapsed.inHours.toString().padLeft(2, '0');
    final minutes = (elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        '$hours:$minutes:$seconds',
        style: TextStyle(
          fontSize: 24,
          color: Colors.white,
        ),
      ),
    );
  }
}
