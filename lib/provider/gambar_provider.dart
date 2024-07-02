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

  List<IsiGambar> getGambarBySkema(int idTema) {
    // Define the custom order
    final List<String> difficultyOrder = ['mudah', 'sedang', 'sulit'];

    // Filter and sort the list
    List<IsiGambar> filteredList = _isiGambarList
        .where((isiGambar) =>
            isiGambar.idtema == idTema && isiGambar.status == true)
        .toList();

    // Sort the list by the custom order
    filteredList.sort((a, b) {
      return difficultyOrder
          .indexOf(a.tingkatKesulitan)
          .compareTo(difficultyOrder.indexOf(b.tingkatKesulitan));
    });

    return filteredList;
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
