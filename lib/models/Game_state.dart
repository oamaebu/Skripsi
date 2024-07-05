class GameState {
  int? id;
  int id_gambar;
  String waktu; // Use String to store time in 'HH:MM:SS' format
  int id_anak;
  String tanggal;
  int jumlah_salah;
  int skema;

  GameState(
      {this.id,
      required this.id_gambar,
      required this.waktu, // Required field for time
      required this.id_anak,
      required this.tanggal,
      required this.jumlah_salah,
      required this.skema});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_gambar': id_gambar,
      'waktu': waktu, // Align with database column name
      'id_anak': id_anak,
      'tanggal': tanggal,
      'jumlah_salah': jumlah_salah,
      'skema': skema,

      // Align with database column name
    };
  }

  static GameState fromMap(Map<String, dynamic> map) {
    return GameState(
      id: map['id'],
      id_gambar: map['id_game'],
      waktu: map['waktu'],
      id_anak: map['id_anak'],
      tanggal: map['tanggal'],
      jumlah_salah: map['jumlah_salah'],
      skema: map['skema'],
      // Align with database column name
    );
  }
}
