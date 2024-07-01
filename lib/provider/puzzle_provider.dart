import 'package:app/models/puzzle.dart';
import 'package:flutter/material.dart';
import 'package:app/database/database_service.dart';

class PuzzleProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<puzzle> _puzzleList = [];

  List<puzzle> get puzzles => _puzzleList;

  PuzzleProvider() {
    _fetchPuzzles();
  }

  puzzle? getPuzzle(int level) {
    try {
      return puzzles.firstWhere((puzzle) => puzzle.level == level);
    } catch (e) {
      print('No puzzle found for level $level');
      return null;
    }
  }

  List<puzzle> getPuzzlesByKelas(String kelas) {
    return puzzles.where((puzzle) => puzzle.kelas == kelas).toList();
  }

  Future<void> _fetchPuzzles() async {
    final puzzleListMap = await _databaseHelper.getPuzzleMapList();
    _puzzleList =
        puzzleListMap.map((puzzleMap) => puzzle.fromMap(puzzleMap)).toList();
    notifyListeners();
  }

  Future<void> addPuzzle(puzzle newPuzzle) async {
    await _databaseHelper.insertPuzzle(newPuzzle.toMap());
    _fetchPuzzles();
  }

  Future<void> updatePuzzle(puzzle updatedPuzzle) async {
    await _databaseHelper.updatePuzzle(updatedPuzzle.toMap());
    _fetchPuzzles();
  }

  Future<void> deletePuzzle(int id) async {
    await _databaseHelper.deletePuzzle(id);
    _fetchPuzzles();
  }
}
