class Garis {
  final int id;
  final int level;
  final int kelas;
  final String content;
  final int idGame;

  Garis({
    required this.id,
    required this.level,
    required this.kelas,
    required this.content,
    required this.idGame,
  });

  factory Garis.fromMap(Map<String, dynamic> map) {
    return Garis(
      id: map['id'],
      level: map['level'],
      kelas: map['kelas'],
      content: map['content'],
      idGame: map['id_game'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'level': level,
      'kelas': kelas,
      'content': content,
      'id_game': idGame,
    };
  }
}
