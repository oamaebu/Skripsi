import 'package:flutter/material.dart';
import 'package:app/database/database_service.dart';

class GameStateProvider with ChangeNotifier {
  DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _gameStates = [];

  List<Map<String, dynamic>> get gameStates => _gameStates;

  GameStateProvider() {
    _fetchGameStates();
  }

  Future<void> _fetchGameStates() async {
    final gameStateList = await _databaseHelper.getGameStateMapList();
    _gameStates = gameStateList;
    notifyListeners();
  }

  Future<void> addGameState(Map<String, dynamic> gameState) async {
    await _databaseHelper.insertGameState(gameState);
    _fetchGameStates();
  }

  Future<void> updateGameState(Map<String, dynamic> gameState) async {
    await _databaseHelper.updateGameState(gameState);
    _fetchGameStates();
  }

  Future<void> deleteGameState(int id) async {
    await _databaseHelper.deleteGameState(id);
    _fetchGameStates();
  }
}
