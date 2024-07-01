import 'package:flutter/material.dart';
import 'package:app/database/database_service.dart';

class GameProvider with ChangeNotifier {
  DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _games = [];

  List<Map<String, dynamic>> get games => _games;

  GameProvider() {
    _fetchGames();
  }

  Future<void> _fetchGames() async {
    final gameList = await _databaseHelper.getGameMapList();
    _games = gameList;
    notifyListeners();
  }

  Future<void> addGame(Map<String, dynamic> game) async {
    await _databaseHelper.insertGame(game);
    _fetchGames();
  }

  Future<void> updateGame(Map<String, dynamic> game) async {
    await _databaseHelper.updateGame(game);
    _fetchGames();
  }

  Future<void> deleteGame(int id) async {
    await _databaseHelper.deleteGame(id);
    _fetchGames();
  }
}
