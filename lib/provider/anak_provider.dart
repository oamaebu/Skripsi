import 'package:flutter/material.dart';
import 'package:app/database/database_service.dart';
import 'package:app/models/Anak.dart';

class AnakProvider with ChangeNotifier {
  DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<Anak> _anaks = [];
  Anak? _currentAnak;

  List<Anak> get anaks => _anaks;
  Anak? get currentAnak => _currentAnak;

  AnakProvider() {
    getAnak();
  }

  Future<void> getAnak() async {
    _anaks = await DatabaseHelper.instance.getAnakMapList();
    notifyListeners();
  }

  Future<Anak?> fetchAnakById(int id) async {
    _currentAnak = await DatabaseHelper.instance.getAnakById(id);
    notifyListeners();
    return _currentAnak;
  }

  void setCurrentAnak(Anak anak) {
    _currentAnak = anak;
    notifyListeners();
  }

  Future<void> addAnak(Anak anak) async {
    await DatabaseHelper.instance.insertAnak(anak);
    getAnak();
  }

  Anak getAnakByIdZero() {
    return _anaks.firstWhere((anak) => anak.id == 0);
  }

  Future<void> updateAnak(Anak anak) async {
    await _databaseHelper.updateAnak(anak);
    getAnak();
  }

  bool profileExists() {
    return _currentAnak != null;
  }

  Future<void> deleteAnak(int id) async {
    await _databaseHelper.deleteAnak(id);
    getAnak();
  }

  Anak? get getFirstAnak => _anaks.isNotEmpty ? _anaks.first : null;
}
