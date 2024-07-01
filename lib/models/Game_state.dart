class GameState {
  int? id;
  int id_game;
  String waktu; // Use String to store time in 'HH:MM:SS' format
  int id_anak;
  String tanggal;
  int jumlah_salah;

  GameState({
    this.id,
    required this.id_game,
    required this.waktu, // Required field for time
    required this.id_anak,
    required this.tanggal,
    required this.jumlah_salah,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_game': id_game,
      'waktu': waktu, // Align with database column name
      'id_anak': id_anak,
      'tanggal': tanggal,
      'jumlah_salah': jumlah_salah,

      // Align with database column name
    };
  }

  static GameState fromMap(Map<String, dynamic> map) {
    return GameState(
      id: map['id'],
      id_game: map['id_game'],
      waktu: map['waktu'],
      id_anak: map['id_anak'],
      tanggal: map['tanggal'],
      jumlah_salah: map['jumlah_salah'],
      // Align with database column name
    );
  }
}
