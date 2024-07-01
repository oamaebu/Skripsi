import 'package:app/models/skema.dart';
import 'package:flutter/material.dart';

class SkemaProvider with ChangeNotifier {
  List<Skema> _skemaList = [
    Skema(
      id: '0',
      namaSkema: 'skema1',
      statusSkema: true,
    ),
    Skema(
      id: '1',
      namaSkema: 'skema2',
      statusSkema: true,
    ),
    Skema(
      id: '2',
      namaSkema: 'skema3',
      statusSkema: true,
    ),
    // Add more Skema instances as needed
  ];

  List<Skema> get skemaList => _skemaList;

  void updateSkemaStatus(String id, bool newValue) {
    final skema = _skemaList.firstWhere((skema) => skema.id == id);
    skema.statusSkema = newValue;
    notifyListeners();
  }

  bool getSkemaStatus(String id) {
    try {
      final skema = _skemaList.firstWhere((skema) => skema.id == id);
      return skema.statusSkema ?? false;
    } catch (e) {
      return false;
    }
  }
}
