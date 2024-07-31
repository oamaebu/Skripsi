import 'dart:io' as io;
import 'dart:io';
import 'package:app/models/isi_gambar.dart';
import 'package:app/provider/anak_provider.dart';
import 'package:app/provider/gambar_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/game_state_provider.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class JigsawPuzzleScreenSkema3 extends StatefulWidget {
  final int idTema;
  const JigsawPuzzleScreenSkema3({Key? key, required this.idTema})
      : super(key: key);
  @override
  _JigsawPuzzleScreenState createState() => _JigsawPuzzleScreenState();
}

class _JigsawPuzzleScreenState extends State<JigsawPuzzleScreenSkema3> {
  bool _isTimeUp = false;
  String imagePath = '';
  int point = 0;
  late Stopwatch _stopwatch;
  late GameStateProvider _gameStateProvider;
  bool isPreviousPiecePlaced = true;
  int lockedPieceCount = 0;
  final int rows = 2;
  final int cols = 2;
  List<Piece> pieces = [];
  List<Piece> displayedPieces = [];
  ui.Image? fullImage;
  double screenWidth = 0;
  double screenHeight = 0;
  int _currentIndex = 0;
  List<IsiGambar> _currentIsiGambarList = [];
  late AudioPlayer _player;
  bool _isPlayerInitialized = false;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _gameStateProvider = Provider.of<GameStateProvider>(context, listen: false);
    _player = AudioPlayer();
    _initPlayer();

    final isiGambarProvider =
        Provider.of<IsiGambarProvider>(context, listen: false);
    isiGambarProvider.fetchIsiGambarList().then((_) {
      setState(() {
        _currentIsiGambarList =
            isiGambarProvider.getGambarByTema(widget.idTema);
        if (_currentIsiGambarList.isNotEmpty) {
          _currentIndex = 0;
          _loadCurrentLevel();
        }
      });
    });
  }

  void _onTimeUp() {
    if (!_isTimeUp) {
      _isTimeUp = true;
      _stopwatch.stop();
      AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        animType: AnimType.rightSlide,
        title: 'Time\'s Up!',
        desc: 'You\'ve reached the 5-minute time limit.',
        btnOkText: 'OK',
        btnOkOnPress: () {
          Navigator.of(context).pop();
        },
      )..show();
    }
  }

  matTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  void _completeLevel(int idAnak) {
    _player.play(AssetSource('sound/correct.mp3'));
    final idGambar = _currentIsiGambarList[_currentIndex].id;
  }

  Future<void> _initPlayer() async {
    setState(() {
      _isPlayerInitialized = true;
    });

    if (_currentIsiGambarList.isNotEmpty &&
        _currentIndex >= 0 &&
        _currentIndex < _currentIsiGambarList.length) {
      final isiGambar = _currentIsiGambarList[_currentIndex];
      if (isiGambar.suara != null && isiGambar.suara!.isNotEmpty) {
        await _player.play(DeviceFileSource(isiGambar.suara!));
      }
    }
  }

  bool _isLoading = false;

  void _loadCurrentLevel() {
    if (_isLoading) return;
    _isLoading = true;

    if (_currentIsiGambarList.isNotEmpty &&
        _currentIndex >= 0 &&
        _currentIndex < _currentIsiGambarList.length) {
      imagePath = getStatusSkemaValue();
      _loadImage1(imagePath).then((image) {
        setState(() {
          fullImage = image;
          pieces = _generatePuzzlePieces(image);
          displayedPieces.clear();
          lockedPieceCount = 0;

          _isLoading = false;
        });
      });
    } else {
      _isLoading = false;
    }
  }

  String getStatusSkemaValue() {
    if (_currentIndex >= 0 && _currentIndex < _currentIsiGambarList.length) {
      final random = Random();
      int randomNumber = random.nextInt(3) + 1;

      switch (randomNumber) {
        case 1:
          return _currentIsiGambarList[_currentIndex].gambar1;
        case 2:
          return _currentIsiGambarList[_currentIndex].gambar2;
        case 3:
          return _currentIsiGambarList[_currentIndex].gambar3;
        default:
          return _currentIsiGambarList[_currentIndex].gambar1;
      }
    }
    return ''; // Return an empty string or a default image path if the index is out of range
  }

  Future<ui.Image> _loadImage1(String asset) async {
    io.File file = io.File(asset);
    final Uint8List bytes = await file.readAsBytes();
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }

  void _addPiece() {
    setState(() {
      if (pieces.isNotEmpty && displayedPieces.length < rows * cols) {
        displayedPieces.add(pieces.removeAt(0));
      }
    });
  }

  void _resetStopwatch() {
    _stopwatch.reset();
    _stopwatch.start();
  }

  Future<ui.Image> _loadImage(String asset) async {
    final data = await rootBundle.load(asset);
    final list = data.buffer.asUint8List();
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(list, completer.complete);
    return completer.future;
  }

  String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  List<Piece> _generatePuzzlePieces(ui.Image image) {
    final pieceWidth = image.width / cols;
    final pieceHeight = image.height / rows;
    List<Piece> pieceWidgets = [];

    final random = Random();
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        pieceWidgets.add(Piece(
          image: image,
          srcRect: Rect.fromLTWH(
            j * pieceWidth,
            i * pieceHeight,
            pieceWidth,
            pieceHeight,
          ),
          position: Offset(
            random.nextDouble() * (image.width - pieceWidth),
            random.nextDouble() * (image.height - pieceHeight),
          ),
          correctPosition: Offset(j * pieceWidth, i * pieceHeight),
          size: Size(pieceWidth, pieceHeight),
          onLocked: () {
            // Add a 1-second delay before calling _addPiece
            Future.delayed(Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _addPiece();
                });
              }
            });
          },
        ));
      }
    }

    pieceWidgets.shuffle(random);
    return pieceWidgets;
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    final anakProvider = Provider.of<AnakProvider>(context);
    final currentAnak = anakProvider.currentAnak;

    if (_currentIsiGambarList.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.blue,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    // Check if fullImage is null (level is still loading)
    if (fullImage == null) {
      return Scaffold(
        backgroundColor: Colors.blue,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final label = _currentIsiGambarList[_currentIndex].label;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIsiGambarList[_currentIndex].tingkatKesulitan,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: fullImage == null
          ? Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.lightBlueAccent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: MediaQuery.of(context).size.height *
                                0.1, // 20% of the screen height
                            width: MediaQuery.of(context).size.width *
                                0.1, // 20% of the screen width
                            child: Image.file(
                              File(imagePath),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: Text(
                              toTitleCase('$label'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: Icon(
                                Icons.volume_up,
                                size: MediaQuery.of(context).size.width * 0.12,
                                color: const Color.fromARGB(255, 255, 255, 255),
                              ),
                              onPressed: _initPlayer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 12,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: AspectRatio(
                            aspectRatio: fullImage!.width / fullImage!.height,
                            child: Container(
                              color: Color.fromARGB(255, 255, 255, 255),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final scaleX =
                                      constraints.maxWidth / fullImage!.width;
                                  final scaleY =
                                      constraints.maxHeight / fullImage!.height;
                                  final scale = min(scaleX, scaleY);

                                  return Stack(
                                    children: [
                                      CustomPaint(
                                        size: Size(
                                          fullImage!.width * scale,
                                          fullImage!.height * scale,
                                        ),
                                        painter: TransparentBackgroundPainter(
                                          fullImage!,
                                          Rect.fromLTRB(
                                            0,
                                            0,
                                            fullImage!.width.toDouble(),
                                            fullImage!.height.toDouble(),
                                          ),
                                          0.3,
                                        ),
                                      ),
                                      _buildGridLines(
                                        scale,
                                        fullImage!.width,
                                        fullImage!.height,
                                      ),
                                      for (var piece in displayedPieces)
                                        DraggablePiece(
                                          piece: piece,
                                          onPieceMoved: _onPieceMoved,
                                          scale: scale,
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(child: _buildNavigationButtonsleft(context)),
                        Expanded(child: _buildNavigationButtonsright(context)),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      color: Colors.lightBlueAccent,
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                              flex: 2,
                              child: Container(
                                width: MediaQuery.of(context).size.width *
                                    0.15, // 15% of the screen width
                                height: MediaQuery.of(context).size.width *
                                    0.15, // Ensure the container is square
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.12, // Adjust inner container width
                                    height: MediaQuery.of(context).size.width *
                                        0.12, // Adjust inner container height
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.refresh,
                                        color: Colors.white,
                                        size: MediaQuery.of(context)
                                                .size
                                                .width *
                                            0.08, // Adjust icon size based on screen width
                                      ),
                                      onPressed: _resetPuzzle,
                                      tooltip: 'Ulang',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 3,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.blue),
                                  minimumSize: MaterialStateProperty.all<Size>(
                                      Size(double.infinity,
                                          60)), // Set minimum button size
                                  padding: MaterialStateProperty
                                      .all<EdgeInsetsGeometry>(EdgeInsets.all(
                                          16)), // Adjust padding for larger button
                                ),
                                onPressed: pieces.isNotEmpty ? _addPiece : null,
                                child: Text(
                                  'Main Sekarang',
                                  style: TextStyle(
                                    fontSize:
                                        14, // Adjust font size for better visibility
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: Container(
                                width: MediaQuery.of(context).size.width *
                                    0.15, // 20% of the screen width
                                height: MediaQuery.of(context).size.width *
                                    0.15, // Ensure the container is square
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue,
                                ),
                                child: Center(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.18, // Adjust inner container width
                                    height: MediaQuery.of(context).size.width *
                                        0.18, // Adjust inner container height
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        width: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: MediaQuery.of(context)
                                                .size
                                                .width *
                                            0.08, // Adjust icon size based on screen width
                                      ),
                                      onPressed: () => _checkCompletion1(
                                          currentAnak?.id ?? 0),
                                      tooltip: 'Selesai',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _navigateToLevel(int index) {
    if (index >= 0 && index < _currentIsiGambarList.length) {
      setState(() {
        displayedPieces.clear();
        lockedPieceCount = 0;
        _currentIndex = index;
        _loadCurrentLevel();
      });

      _initPlayer();
    }
  }

  Widget _buildNavigationButtonsleft(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          width: MediaQuery.of(context).size.width *
              0.18, // 10% of the screen width
          height: MediaQuery.of(context).size.width *
              0.18, // 10% of the screen width
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              width: 3,
              color: _currentIndex > 0
                  ? const Color.fromARGB(255, 255, 255, 255)
                  : Colors.grey,
            ),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back,
                size: MediaQuery.of(context).size.width *
                    0.1), // Adjust icon size
            color: _currentIndex > 0
                ? const Color.fromARGB(255, 255, 255, 255)
                : Colors.grey,
            onPressed: (_currentIndex > 0)
                ? () => _navigateToLevel(_currentIndex - 1)
                : null,
            tooltip: 'Previous Level',
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtonsright(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          width: MediaQuery.of(context).size.width *
              0.18, // 10% of the screen width
          height: MediaQuery.of(context).size.width *
              0.18, // 10% of the screen width
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              width: 3,
              color: _currentIndex < _currentIsiGambarList.length - 1
                  ? Color.fromARGB(255, 255, 255, 255)
                  : Colors.grey,
            ),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_forward,
                size: MediaQuery.of(context).size.width *
                    0.1), // Adjust icon size
            color: _currentIndex < _currentIsiGambarList.length - 1
                ? const Color.fromARGB(255, 255, 255, 255)
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

  void _checkCompletion1(int idAnak) {
    bool allCorrect = true;
    int angka = _currentIsiGambarList.length;
    bool sas = _currentIndex == _currentIsiGambarList.length - 1;
    print(sas);

    // Check if all pieces are placed correctly
    for (var piece in displayedPieces) {
      if (!piece.isCorrect) {
        allCorrect = false;
        break;
      }
    }

    if (pieces.isEmpty && displayedPieces.length == rows * cols) {
      // Check if puzzle is completed and all pieces are correctly placed
      if (allCorrect) {
        switch (_currentIsiGambarList[_currentIndex].tingkatKesulitan) {
          case 'mudah':
            point = point + 1;
          case 'sedang':
            point = point + 2;
          case 'sulit':
            point = point + 3;
        }
        if (_currentIndex == _currentIsiGambarList.length - 1) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.scale,
            title: 'Selamat!',
            desc: 'Kamu telah menyelesaikan semua level!',
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
          _completeLevel(idAnak);
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
              _loadNextLevel();
            },
          ).show();
        }
      } else {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.info,
          animType: AnimType.scale,
          title: 'Belum Tepat',
          desc: 'Ayo coba lagi! Kamu pasti bisa.',
          btnOkText: 'OK!',
          btnOkColor: Colors.lightBlueAccent,
          titleTextStyle: TextStyle(
            color: Colors.blue[800],
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          descTextStyle: TextStyle(
            color: Colors.blue[600],
            fontSize: 18,
          ),
          dialogBackgroundColor: Colors.white,
          borderSide: BorderSide(color: Colors.lightBlueAccent, width: 3),
          buttonsBorderRadius: BorderRadius.circular(20),
          barrierColor: Colors.black54,
          dismissOnTouchOutside: false,
          headerAnimationLoop: false,
          buttonsTextStyle: TextStyle(color: Colors.white, fontSize: 18),
          showCloseIcon: true,
          closeIcon: Icon(Icons.close_rounded, color: Colors.blue[800]),
          btnOkOnPress: () {},
        ).show();
      }
    }
  }

  void _showCompletionDialog() {}

  void _loadNextLevel() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _currentIsiGambarList.length;
      fullImage = null;
      pieces.clear();
      displayedPieces.clear();
      lockedPieceCount = 0;
      _loadCurrentLevel();
    });
  }

  Widget _buildGridLines(double scale, int width, int height) {
    final List<Widget> gridLines = [];
    final pieceWidth = width.toDouble() / cols * scale;
    final pieceHeight = height.toDouble() / rows * scale;

    // Draw horizontal lines
    for (int i = 0; i <= rows; i++) {
      gridLines.add(Positioned(
        top: i * pieceHeight,
        left: 0,
        child: Container(
          width: width.toDouble() * scale,
          height: 1,
          color: Colors.black, // Adjust color for visibility
        ),
      ));
    }

    // Draw vertical lines
    for (int j = 0; j <= cols; j++) {
      gridLines.add(Positioned(
        top: 0,
        left: j * pieceWidth,
        child: Container(
          width: 1,
          height: height.toDouble() * scale,
          color: Colors.black, // Adjust color for visibility
        ),
      ));
    }

    return Stack(
      children: gridLines,
      clipBehavior: Clip.none, // Ensure widgets can paint outside their bounds
    );
  }

  Widget _buildNextPiecePreview() {
    if (pieces.isNotEmpty) {
      // If there are remaining pieces, display the next one as a small preview
      return Container(
        color: const Color.fromARGB(255, 0, 0, 0),
        child: CustomPaint(
          size: Size(100, 100), // Adjust the size of the preview
          painter: PuzzlePiecePainter(
            pieces[0].image, // Display the image of the next piece
            pieces[0].srcRect, // Use the source rectangle of the next piece
          ),
        ),
      );
    } else {
      // If there are no remaining pieces, display an empty container
      return Container();
    }
  }

  void _resetPuzzle() {
    setState(() {
      // Update the imagePath
      imagePath = getStatusSkemaValue();

      // Reset the puzzle pieces for the current level
      _loadImage1(imagePath).then((image) {
        setState(() {
          fullImage = image;
          pieces = _generatePuzzlePieces(image);
          displayedPieces.clear(); // Clear all displayed pieces
          lockedPieceCount = 0;

          // Don't add any pieces to displayedPieces
          // The user will need to click "Main Sekarang" to start
        });
      });
    });

    // Replay the audio for the current level
    _initPlayer();
  }

  void _onPieceMoved(Piece piece, Offset newPosition) {
    setState(() {
      piece.position = newPosition;

      // Check if the piece is near a slot (correct or incorrect)
      for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
          final slotPosition =
              Offset(j * piece.size.width, i * piece.size.height);
          if ((piece.position - slotPosition).distance < 10) {
            piece.position = slotPosition;
            piece.isCorrect = slotPosition == piece.correctPosition;

            // Lock the piece and call the callback only once
            if (!piece.isLocked) {
              piece.isLocked = true; // Lock the piece
              lockedPieceCount++;
            }

            // Check for completion after locking the piece if all pieces are locked

            return;
          }
        }
      }
    });
  }
}

class Piece {
  final ui.Image image;
  final Rect srcRect;
  Offset position;
  final Offset correctPosition;
  final Size size;
  bool isCorrect = false;
  bool _isLocked = false;
  ui.VoidCallback onLocked; // Define isLocked variable

  bool get isLocked => _isLocked; // Getter for isLocked

  set isLocked(bool value) {
    _isLocked = value; // Setter for isLocked
    if (_isLocked) {
      print('Puzzle terkunci');
      onLocked(); // Call the callback function
    }
  }

  Piece({
    required this.image,
    required this.srcRect,
    required this.position,
    required this.correctPosition,
    required this.size,
    required this.onLocked,
  });
}

class DraggablePiece extends StatefulWidget {
  final Piece piece;
  final Function(Piece, Offset) onPieceMoved;
  final double scale;

  DraggablePiece({
    required this.piece,
    required this.onPieceMoved,
    required this.scale,
  });

  @override
  _DraggablePieceState createState() => _DraggablePieceState();
}

class _DraggablePieceState extends State<DraggablePiece> {
  double top = 0.0;
  double left = 0.0;

  @override
  void initState() {
    super.initState();
    top = widget.piece.position.dy * widget.scale;
    left = widget.piece.position.dx * widget.scale;
  }

  @override
  Widget build(BuildContext context) {
    final imageWidth = MediaQuery.of(context).size.width;
    final imageHeight = MediaQuery.of(context).size.height;
    final pieceWidth = widget.piece.size.width * widget.scale;
    final pieceHeight = widget.piece.size.height * widget.scale;

    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onPanUpdate: (dragUpdateDetails) {
          setState(() {
            top += dragUpdateDetails.delta.dy;
            left += dragUpdateDetails.delta.dx;

            // Check if the piece is near any possible slot position
            for (int i = 0;
                i < widget.piece.image.height ~/ widget.piece.size.height;
                i++) {
              for (int j = 0;
                  j < widget.piece.image.width ~/ widget.piece.size.width;
                  j++) {
                final potentialPosition =
                    Offset(j * pieceWidth, i * pieceHeight);
                final distance = Offset(
                        left - potentialPosition.dx, top - potentialPosition.dy)
                    .distance;
                final snapThreshold = 22.0;

                if (distance < snapThreshold) {
                  top = potentialPosition.dy;
                  left = potentialPosition.dx;
                  widget.onPieceMoved(
                      widget.piece, potentialPosition / widget.scale);
                  return;
                }
              }
            }

            // If no close slot found, update the piece position
            widget.onPieceMoved(
                widget.piece, Offset(left / widget.scale, top / widget.scale));
          });
        },
        child: CustomPaint(
          painter: PuzzlePiecePainter(widget.piece.image, widget.piece.srcRect),
          child: SizedBox(
            width: pieceWidth,
            height: pieceHeight,
          ),
        ),
      ),
    );
  }
}

class PuzzlePiecePainter extends CustomPainter {
  final ui.Image image;
  final Rect srcRect;

  PuzzlePiecePainter(this.image, this.srcRect);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(image, srcRect, dstRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class TransparentBackgroundPainter extends CustomPainter {
  final ui.Image image;
  final Rect srcRect;
  final double opacity; // Define opacity level as a member variable

  TransparentBackgroundPainter(this.image, this.srcRect, this.opacity);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color =
        Color.fromRGBO(255, 255, 255, opacity); // Set the opacity level
    final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(image, srcRect, dstRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class CorrectPositionPainter extends CustomPainter {
  final List<Piece> pieces;
  final ui.Image fullImage;
  final double scale;

  CorrectPositionPainter(this.pieces, this.fullImage, this.scale);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.transparent;
    final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(
        fullImage,
        Rect.fromLTWH(
            0, 0, fullImage.width.toDouble(), fullImage.height.toDouble()),
        dstRect,
        paint);

    for (var piece in pieces) {
      final srcRect = piece.srcRect;
      final dstRect = Rect.fromLTWH(
        piece.correctPosition.dx * scale,
        piece.correctPosition.dy * scale,
        piece.size.width * scale,
        piece.size.height * scale,
      );

      canvas.saveLayer(
          dstRect, Paint()..color = Colors.transparent.withOpacity(0.5));
      canvas.drawImageRect(fullImage, srcRect, dstRect, Paint());
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
