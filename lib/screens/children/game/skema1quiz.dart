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
  int BenarMudah = 0;
  int BenarSedang = 0;
  int BenarSulit = 0;
  int poin = 0;
  List<IsiGambar> _currentIsiGambarList = [];
  int _currentIndex = 0;
  int benar = 0;

  late GameStateProvider _gameStateProvider;
  final player = AudioPlayer();

  late Stopwatch _stopwatch;
  final GlobalKey<ShakeTransitionState> _wrongImageKey1 =
      GlobalKey<ShakeTransitionState>();
  final GlobalKey<ShakeTransitionState> _wrongImageKey2 =
      GlobalKey<ShakeTransitionState>();

  int _wrongChoices = 0;

  List<String> _shuffledImagePaths = [];

  bool _isTimeUp = false;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _gameStateProvider = Provider.of<GameStateProvider>(context, listen: false);

    final isiGambarProvider =
        Provider.of<IsiGambarProvider>(context, listen: false);
    isiGambarProvider.fetchIsiGambarList().then((_) {
      setState(() {
        _currentIsiGambarList =
            isiGambarProvider.getGambarByTema(widget.idTema);
        if (_currentIsiGambarList.isNotEmpty) {
          _currentIndex = 0;
          _shuffledImagePaths = _shuffleImagePaths(_currentIndex);
          _initPlayer();
        }
      });
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

  void _saveGameState(String time, int anakId, int BenarMudah,int BenarSedang,int BenarSulit) {
    final now = DateTime.now();
    final date = '${now.year}-${now.month}-${now.day}';

    final gameState = {
      'id': null,
      'waktu': time,
      'id_anak': anakId,
      'tanggal': date,
      'BenarMudah': BenarMudah,
      'BenarSedang': BenarSedang,
      'BenarSulit': BenarSulit,
      'skema': 1
    };
    _gameStateProvider.addGameState(gameState);
  }

  void _navigateToLevel(int index) {
    benar = 0;
    if (index >= 0 && index < _currentIsiGambarList.length) {
      setState(() {
        _currentIndex = index;
        _shuffledImagePaths = _shuffleImagePaths(_currentIndex);
      });
      _initPlayer();
    } else if (index >= _currentIsiGambarList.length) {
      _showCompletionDialog();
    }
  }

  void _completeLevel(int? anakId) {
    benar++;
    player.play(AssetSource('sound/ceting.mp3'));
    if (benar == 2) {
      switch (_currentIsiGambarList[_currentIndex].tingkatKesulitan) {
        case 'mudah':
          BenarMudah = BenarMudah + 1;
        case 'sedang':
          BenarMudah = BenarSedang + 1;
        case 'sulit':
          BenarSulit = BenarSulit + 1;
      }
      player.play(AssetSource('sound/correct.mp3'));
      if (_currentIndex == _currentIsiGambarList.length - 1) {
        _saveGameState(_formatTime(_stopwatch.elapsed), anakId!, BenarMudah,BenarMudah,BenarSulit);
        _showCompletionDialog();
      } else {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.bottomSlide,
          title: 'Hebat!',
          desc: 'Kamu berhasil menyelesaikan puzzle ini!',
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
            _navigateToLevel(_currentIndex + 1);
          },
        ).show();
      }
    }
  }

  void _showCompletionDialog() {
    _stopwatch.stop();
    String finalTime = _formatTime(_stopwatch.elapsed);
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: 'Hebat!',
      desc:
          'Kamu telah menyelesaikan semua level!',
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
    ).show();
  }

  void _shakeWrongImage(GlobalKey<ShakeTransitionState> key) {
    setState(() {
      _wrongChoices++;
    });
    player.play(AssetSource('sound/wrong.mp3'));
    key.currentState?.shake();
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
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
          width: MediaQuery.of(context).size.height * 0.2,
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

  void _onTimeUp() {
    if (!_isTimeUp) {
      _isTimeUp = true;
      _stopwatch.stop();
      AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        animType: AnimType.rightSlide,
        title: 'Waktu Habis!',
        desc: 'Kamu hebat! kerja yang bagus',
        btnOkText: 'OK',
        btnOkOnPress: () {
          Navigator.of(context).pop();
        },
      )..show();
    }
  }

  @override
  Widget build(BuildContext context) {
    final anakProvider = Provider.of<AnakProvider>(context);
    final currentAnak = anakProvider.currentAnak;

    // Check if _currentIsiGambarList is empty
    if (_currentIsiGambarList.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.blue,
        appBar: AppBar(
          title: Text('Level ${widget.level}'),
          backgroundColor: Colors.blue,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final label = _currentIsiGambarList[_currentIndex].label;

    return Scaffold(
      appBar: AppBar(
        actions: [
          TimerDisplay(stopwatch: _stopwatch, onTimeUp: _onTimeUp),
        ],
        title: Text(
          'Level ${widget.level} (${_currentIsiGambarList[_currentIndex].tingkatKesulitan})',
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
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Pasangkan Gambar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize:
                                MediaQuery.of(context).size.height * 0.033,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '$label',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
                    height: MediaQuery.of(context).size.height * 0.4,
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
  final VoidCallback onTimeUp;

  TimerDisplay({required this.stopwatch, required this.onTimeUp});

  @override
  _TimerDisplayState createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<TimerDisplay> {
  late Timer _timer;
  final int _timeLimit = 5 * 60; // 5 minutes in seconds

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (widget.stopwatch.isRunning) {
        setState(() {
          if (widget.stopwatch.elapsed.inSeconds >= _timeLimit) {
            widget.stopwatch.stop();
            widget.onTimeUp();
          }
        });
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
    final remaining = _timeLimit - widget.stopwatch.elapsed.inSeconds;
    final minutes = (remaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (remaining % 60).toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        '$minutes:$seconds',
        style: TextStyle(
          fontSize: 24,
          color: Colors.white,
        ),
      ),
    );
  }
}
