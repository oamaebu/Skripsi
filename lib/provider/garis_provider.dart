import 'package:flutter/material.dart';
import 'package:app/database/database_service.dart';

class GarisProvider with ChangeNotifier {
  DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _garisList = [];

  List<Map<String, dynamic>> get garisList => _garisList;

  GarisProvider() {
    _fetchGaris();
  }

  Future<void> _fetchGaris() async {
    final garisList = await _databaseHelper.getGarisMapList();
    _garisList = garisList;
    notifyListeners();
  }

  Future<void> addGaris(Map<String, dynamic> garis) async {
    await _databaseHelper.insertGaris(garis);
    _fetchGaris();
  }

  Future<void> updateGaris(Map<String, dynamic> garis) async {
    await _databaseHelper.updateGaris(garis);
    _fetchGaris();
  }

  Future<void> deleteGaris(int id) async {
    await _databaseHelper.deleteGaris(id);
    _fetchGaris();
  }
}
