import 'package:flutter/material.dart';
import 'package:app/database/database_service.dart';
import 'package:app/models/tema.dart';

class TemaProvider with ChangeNotifier {
  DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<Tema> _temas = [];
  Tema? _currentTema;

  List<Tema> get temas => _temas;
  Tema? get currentTema => _currentTema;

  TemaProvider() {
    fetchTemas();
  }

  Future<void> fetchTemas() async {
    final db = await _databaseHelper.db;
    final List<Map<String, dynamic>> temaMapList = await db.query('tema');
    _temas = temaMapList.map((map) => Tema.fromMap(map)).toList();
    notifyListeners();
  }

  Future<Tema?> fetchTemaById(int id) async {
    _currentTema = await _databaseHelper.getTemaById(id);
    notifyListeners();
    return _currentTema;
  }

  void setCurrentTema(Tema tema) {
    _currentTema = tema;
    notifyListeners();
  }

  Future<void> addTema(Tema tema) async {
    await _databaseHelper.insertTema(tema);
    fetchTemas();
  }

  Future<void> updateTema(Tema tema) async {
    await _databaseHelper.updateTema(tema);
    fetchTemas();
  }

  Future<void> deleteTema(int id) async {
    await _databaseHelper.deleteTema(id);
    fetchTemas();
  }

  void updateTemaStatus(int id, bool status) {
    for (var tema in _temas) {
      tema.status = false;
    }
    final index = _temas.indexWhere((tema) => tema.id == id);
    if (index != -1) {
      _temas[index].status = status;
    }
    notifyListeners();
  }

  void setAllTemasToFalseExcept(int? exceptId) {
    for (var tema in _temas) {
      if (tema.id != exceptId) {
        tema.status = false;
      }
    }
    notifyListeners();
  }

  int? getActiveTemaId() {
    final activeTema = _temas.firstWhere(
      (tema) => tema.status == true,
      orElse: () => Tema(id: null, namaTema: '', status: false),
    );
    return activeTema.id;
  }
}
