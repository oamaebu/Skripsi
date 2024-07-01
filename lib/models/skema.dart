import 'package:flutter/foundation.dart';

class Skema {
  final String id;
  final String namaSkema;
  bool? statusSkema; // Nullable boolean for initial null status

  Skema({
    required this.id,
    required this.namaSkema,
    this.statusSkema, // Nullable boolean
  });
}
