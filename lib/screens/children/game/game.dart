import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/models/isi_gambar.dart';
import 'package:app/provider/gambar_provider.dart';
import 'package:app/screens/children/game/skema1.dart';
import 'package:app/screens/login.dart';

class GamePage extends StatelessWidget {
  final String childId;

  GamePage({required this.childId});

  @override
  Widget build(BuildContext context) {
    final isiGambarProvider = Provider.of<IsiGambarProvider>(context);

    isiGambarProvider.fetchIsiGambarList();
    final List<IsiGambar> currentIsiGambarList =
        isiGambarProvider.getGambarByTema(1);
    print(currentIsiGambarList);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Puzzle Game',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: currentIsiGambarList.isEmpty
            ? Center(child: Text('No puzzles found'))
            : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: currentIsiGambarList.length,
                itemBuilder: (context, index) {
                  final isiGambar = currentIsiGambarList[index];

                  return GestureDetector(
                    onTap: () {
                     
                    },
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 10),
                      elevation: 5,
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            isiGambar.label,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          'Difficulty: ${isiGambar.tingkatKesulitan}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
