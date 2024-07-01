import 'package:app/provider/game_state_provider.dart';
import 'package:app/screens/children/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';

class LineDrawingGamePage extends StatefulWidget {
  final String childId;

  LineDrawingGamePage({Key? key, required this.childId}) : super(key: key);

  @override
  _LineDrawingGamePageState createState() => _LineDrawingGamePageState();
}

class _LineDrawingGamePageState extends State<LineDrawingGamePage> {
  late Stopwatch _stopwatch;
  List<List<Offset>> _drawings = [];
  List<Offset> _currentDrawing = [];
  final Path _path = Path();
  bool _isPathCompleted = false;
  late GameStateProvider _gameStateProvider;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _gameStateProvider = Provider.of<GameStateProvider>(context, listen: false);
    // Define the path to be followed (example: a simple zigzag line)
    _path.moveTo(50, 100);
    _path.lineTo(100, 200);
    _path.lineTo(150, 100);
    _path.lineTo(200, 200);
    _path.lineTo(250, 100);
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _currentDrawing.clear();
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      RenderBox renderBox = context.findRenderObject() as RenderBox;
      Offset localPosition = renderBox.globalToLocal(details.globalPosition);
      Offset rawPosition = details.localPosition;
      _currentDrawing.add(rawPosition);
      if (_path.contains(rawPosition)) {
        _isPathCompleted = true;
      } else {
        _isPathCompleted = false;
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _drawings.add(_currentDrawing.toList());
      if (_isPathCompleted) {
        _showCompletionDialog();
      }
    });
  }

  void _showCompletionDialog() {
    _stopwatch.stop();
    final elapsedTime = _stopwatch.elapsed;
    final formattedTime = _formatTime(elapsedTime);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Congratulations!'),
        content: Text('You followed the path correctly in $formattedTime'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _drawings.clear();
                _currentDrawing.clear();
                _isPathCompleted = false;
                _stopwatch.reset();
                _stopwatch.start(); // Start the stopwatch again
              });
            },
            child: Text('Play Again'),
          ),
        ],
      ),
    );
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  void _saveGameState(String time) {
    final now = DateTime.now();
    final date = '${now.year}-${now.month}-${now.day}'; // Format: YYYY-MM-DD

    final gameState = {
      'id': null, // Set to null for auto-increment
      'id_game': 1, // Set a default value for id_game
      'waktu': time,
      'id_anak': widget.childId, // Set a default value for id_anak
      'tanggal': date, // Add the date to the gameState
    };
    _gameStateProvider.addGameState(gameState);
  }

  void _finishGame() {
    _saveGameState(_formatTime(_stopwatch.elapsed)); // Save the game state
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('Follow the Line'),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.lightBlueAccent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Follow the line with your finger',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            SizedBox(height: 20),
            TimerDisplay(stopwatch: _stopwatch),
            SizedBox(height: 20),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double canvasWidth =
                      isTablet ? screenWidth * 0.8 : screenWidth * 0.9;
                  final double canvasHeight =
                      isTablet ? screenHeight * 0.6 : screenHeight * 0.5;

                  return Center(
                    child: Container(
                      width: canvasWidth,
                      height: canvasHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onPanStart: _onPanStart,
                        onPanUpdate: _onPanUpdate,
                        onPanEnd: _onPanEnd,
                        child: CustomPaint(
                          painter:
                              LinePainter(_drawings, _currentDrawing, _path),
                          size: Size(canvasWidth, canvasHeight),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _drawings.clear();
                      _currentDrawing.clear();
                      _isPathCompleted = false;
                    });
                  },
                  child: Text('Clear'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: Size(100, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _finishGame,
                  child: Text('Finish'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: Size(100, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final List<List<Offset>> drawings;
  final List<Offset> currentDrawing;
  final Path path;

  LinePainter(this.drawings, this.currentDrawing, this.path);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    final pathPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final completedPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawPath(path, pathPaint);

    for (List<Offset> drawing in drawings) {
      for (int i = 0; i < drawing.length - 1; i++) {
        canvas.drawLine(drawing[i], drawing[i + 1], paint);
      }
    }

    // Draw the current drawing segment
    for (int i = 0; i < currentDrawing.length - 1; i++) {
      canvas.drawLine(currentDrawing[i], currentDrawing[i + 1], paint);
    }

    if (drawings.isNotEmpty && path.contains(drawings.last.last)) {
      canvas.drawPath(path, completedPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class TimerDisplay extends StatefulWidget {
  final Stopwatch stopwatch;

  TimerDisplay({required this.stopwatch});

  @override
  _TimerDisplayState createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<TimerDisplay> {
  late Stopwatch _stopwatch;
  late Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _stopwatch = widget.stopwatch;
    _ticker = Ticker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatTime(_stopwatch.elapsed),
      style: TextStyle(fontSize: 48, color: Colors.white),
    );
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }
}
