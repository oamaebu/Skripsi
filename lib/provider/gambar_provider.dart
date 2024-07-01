import 'package:flutter/material.dart';
import 'package:app/models/isi_gambar.dart';
import 'package:app/database/database_service.dart';

class IsiGambarProvider with ChangeNotifier {
  List<IsiGambar> _isiGambarList = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<IsiGambar> get isiGambarList => _isiGambarList;

  Future<void> fetchIsiGambarList() async {
    _isiGambarList = await _dbHelper.getIsiGambarList();
    notifyListeners();
  }

  List<IsiGambar> getGambarBySkema() {
    return _isiGambarList.where((isiGambar) => isiGambar.statusSkema1).toList();
  }

  Future<void> fetchIsiGambarByTingkatKesulitan(String tingkatKesulitan) async {
    _isiGambarList =
        await _dbHelper.getIsiGambarByTingkatKesulitan(tingkatKesulitan);
    notifyListeners();
  }

  Future<void> fetchIsiGambarById(int id) async {
    final isiGambar = await _dbHelper.getIsiGambarById(id);
    if (isiGambar != null) {
      _isiGambarList = [isiGambar]; // Store the single isiGambar in a list
    } else {
      _isiGambarList = []; // Handle empty case if needed
    }
    notifyListeners();
  }

  IsiGambar? getIsiGambarById(int id) {
    return _isiGambarList.firstWhere((isiGambar) => isiGambar.id == id,
        orElse: () => null!);
  }

  Future<void> addIsiGambar(IsiGambar isiGambar) async {
    await _dbHelper.insertIsiGambar(isiGambar);
    await fetchIsiGambarList();
  }

  Future<void> updateIsiGambar(IsiGambar isiGambar) async {
    await _dbHelper.updateIsiGambar(isiGambar);
    await fetchIsiGambarList();
  } 

  Future<void> deleteIsiGambar(int? id) async {
    await _dbHelper.deleteIsiGambar(id!);
    await fetchIsiGambarList();
  }
}
