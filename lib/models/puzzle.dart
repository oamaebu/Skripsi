class puzzle {
  final int? id;
  final int level;
  final String kelas;
  final String? GambarSalah1;
  final String? GambarSalah2;
  final String GambarBenar;
  final int idGame;

  puzzle({
    required this.id,
    required this.level,
    required this.kelas,
    required this.GambarSalah1,
    required this.GambarSalah2,
    required this.GambarBenar,
    required this.idGame,
  });

  factory puzzle.fromMap(Map<String, dynamic> map) {
    return puzzle(
      id: map['id'],
      level: map['level'],
      kelas: map['kelas'],
      GambarSalah1: map['GambarSalah1'],
      GambarSalah2: map['GambarSalah2'],
      GambarBenar: map['GambarBenar'],
      idGame: map['id_game'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'level': level,
      'kelas': kelas,
      'GambarSalah1': GambarSalah1,
      'GambarSalah2': GambarSalah2,
      'GambarBenar': GambarBenar,
      'id_game': idGame,
    };
  }
}
