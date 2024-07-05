import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:app/models/isi_gambar.dart';
import 'package:app/provider/gambar_provider.dart';

class Skema1 extends StatefulWidget {
  final int idTema;

  const Skema1({Key? key, required this.idTema}) : super(key: key);

  @override
  _Skema1State createState() => _Skema1State();
}

class _Skema1State extends State<Skema1> {
  late AudioPlayer _player;
  bool _isPlayerInitialized = false;
  List<IsiGambar> _currentIsiGambarList = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initPlayer();

    final isiGambarProvider =
        Provider.of<IsiGambarProvider>(context, listen: false);
    isiGambarProvider.fetchIsiGambarList().then((_) {
      _currentIsiGambarList = isiGambarProvider.getGambarByTema(widget.idTema);
      if (_currentIsiGambarList.isNotEmpty) {
        _currentIndex = 0; // Start from the first item
        _initPlayer();
      }
      setState(() {}); // Refresh UI after fetching data
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
    super.dispose();
  }

  void _navigateToLevel(int index) {
    setState(() {
      _currentIndex = index;
    });
    _initPlayer();
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
                            fontSize: MediaQuery.of(context).size.width * 0.1,
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
    List<String> images = [];
    if (isiGambar.gambar1.isNotEmpty) images.add(isiGambar.gambar1);
    if (isiGambar.gambar2.isNotEmpty) images.add(isiGambar.gambar2);
    if (isiGambar.gambar3.isNotEmpty) images.add(isiGambar.gambar3);

    return Column(
      children: [
        if (images.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.file(
              File(images[0]),
              fit: BoxFit.contain,
              width: MediaQuery.of(context).size.width *
                  0.4, // Use full width of the screen
              height: MediaQuery.of(context).size.width *
                  0.4, // Maintain aspect ratio
            ),
          ),
        if (images.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Image.file(
                    File(images[1]),
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width *
                        0.4, // Adjust width as needed
                    height: MediaQuery.of(context).size.width *
                        0.4, // Adjust height as needed
                  ),
                ),
              ),
              if (images.length > 2)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Image.file(
                      File(images[2]),
                      fit: BoxFit.contain,
                      width: MediaQuery.of(context).size.width *
                          0.4, // Adjust width as needed
                      height: MediaQuery.of(context).size.width *
                          0.4, // Adjust height as needed
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    final double iconSize = MediaQuery.of(context).size.width * 0.15;

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
            iconSize: iconSize,
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
            iconSize: iconSize,
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
