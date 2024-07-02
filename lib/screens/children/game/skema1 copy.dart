import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:app/models/isi_gambar.dart';
import 'package:app/provider/gambar_provider.dart';
import 'dart:async';

class Skema1 extends StatefulWidget {
  @override
  final int idTema;

  
  const Skema1({Key? key, required this.idTema}) : super(key: key);
  _Skema1State createState() => _Skema1State();
}

class _Skema1State extends State<Skema1> {
  late AudioPlayer _player;
  bool _isPlayerInitialized = false;
  List<IsiGambar> _currentIsiGambarList = [];
  int _currentIndex = 0;
  late Stopwatch _stopwatch;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _stopwatch = Stopwatch()..start();
    _startTimer();
    _initPlayer();

    final isiGambarProvider =
        Provider.of<IsiGambarProvider>(context, listen: false);
    isiGambarProvider.fetchIsiGambarList().then((_) {
      _currentIsiGambarList = isiGambarProvider.getGambarBySkema(widget.idTema);
      if (_currentIsiGambarList.isNotEmpty) {
        _currentIndex = 0; // Start from the first item
        _initPlayer();
      }
      setState(() {}); // Refresh UI after fetching data
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(
          () {}); // This will rebuild the widget to update the timer display
    });
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

  @override
  void dispose() {
    _player.dispose();
    _stopwatch.stop();
    _timer.cancel();
    super.dispose();
  }

  void _resetStopwatch() {
    _stopwatch.reset();
    _stopwatch.start();
  }

  void _navigateToLevel(int index) {
    setState(() {
      _currentIndex = index;
      _resetStopwatch(); // Reset the timer when changing levels
    });
    _initPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TimerDisplay(stopwatch: _stopwatch),
          Container(
            alignment: AlignmentDirectional.topEnd,
            padding: EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
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
        title: Text(
          'Level ${_currentIndex + 1}',
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Consumer<IsiGambarProvider>(
                builder: (context, isiGambarProvider, child) {
                  if (_currentIsiGambarList.isEmpty ||
                      _currentIndex >= _currentIsiGambarList.length) {
                    return Text(
                      'No images found for the current level',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    );
                  }

                  final isiGambar = _currentIsiGambarList[_currentIndex];

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          isiGambar.label ??
                              '', // Display isiGambar.label if not null
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildImages(isiGambar),
                      SizedBox(height: 20),
                      _buildNavigationButtons(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImages(IsiGambar isiGambar) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.file(
            File(isiGambar.gambar1),
            width: 180,
            height: 180,
            fit: BoxFit.contain,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(
                File(isiGambar.gambar2),
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(
                File(isiGambar.gambar3),
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
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
                color: _currentIndex > 0 ? Colors.white : Colors.grey),
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
                    : Colors.grey),
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
}

class TimerDisplay extends StatelessWidget {
  final Stopwatch stopwatch;

  TimerDisplay({required this.stopwatch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        _formatDuration(stopwatch.elapsed),
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
