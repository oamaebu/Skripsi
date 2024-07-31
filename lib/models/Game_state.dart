class GameState {
  int? id;
  String waktu; // Use String to store time in 'HH:MM:SS' format
  int id_anak;
  String tanggal;
  int BenarMudah;
  int BenarSedang;
  int BenarSulit;
  int skema;

  GameState(
      {this.id,
      required this.waktu, // Required field for time
      required this.id_anak,
      required this.tanggal,
      this.BenarMudah  = 0,
      this.BenarSedang  = 0,
      this.BenarSulit  = 0,
      required this.skema});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'waktu': waktu, // Align with database column name
      'id_anak': id_anak,
      'tanggal': tanggal,
      'BenarMudah': BenarMudah,
      'BenarSedang': BenarSedang,
      'BenarSulit': BenarSulit,
      'skema': skema,

      // Align with database column name
    };
  }

  static GameState fromMap(Map<String, dynamic> map) {
    return GameState(
      id: map['id'],
      waktu: map['waktu'],
      id_anak: map['id_anak'],
      tanggal: map['tanggal'],
      BenarMudah: map['BenarMudah'],
      BenarSedang: map['BenarSedang'],
      BenarSulit: map['BenarSulit'],
      skema: map['skema'],
      // Align with database column name
    );
  }
}
