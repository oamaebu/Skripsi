import 'package:app/database/database_service.dart';
import 'package:app/models/tema.dart';
import 'package:flutter/material.dart';


class TemaProvider with ChangeNotifier {
  List<Tema> _temas = [];

  List<Tema> get temas => _temas;

  Future<void> fetchTemas() async {
    final db = await DatabaseHelper.instance.db;
    final List<Map<String, dynamic>> temaMapList = await db.query(DatabaseHelper.instance.TemaTable);
    _temas = temaMapList.map((map) => Tema.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> addTema(Tema tema) async {
    final db = await DatabaseHelper.instance.db;
    await db.insert(DatabaseHelper.instance.TemaTable, tema.toMap());
    _temas.add(tema);
    notifyListeners();
  }

  Future<void> updateTema(Tema tema) async {
    final db = await DatabaseHelper.instance.db;
    await db.update(
      DatabaseHelper.instance.TemaTable,
      tema.toMap(),
      where: '${DatabaseHelper.instance.TemaColId} = ?',
      whereArgs: [tema.id],
    );
    final index = _temas.indexWhere((t) => t.id == tema.id);
    if (index != -1) {
      _temas[index] = tema;
      notifyListeners();
    }
  }

  Future<void> deleteTema(int id) async {
    final db = await DatabaseHelper.instance.db;
    await db.delete(
      DatabaseHelper.instance.TemaTable,
      where: '${DatabaseHelper.instance.TemaColId} = ?',
      whereArgs: [id],
    );
    _temas.removeWhere((tema) => tema.id == id);
    notifyListeners();
  }
}
