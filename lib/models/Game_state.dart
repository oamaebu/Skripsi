class GameState {
  int? id;
  String waktu; // Use String to store time in 'HH:MM:SS' format
  int id_anak;
  String tanggal;
  int poin;
  int skema;

  GameState(
      {this.id,
      required this.waktu, // Required field for time
      required this.id_anak,
      required this.tanggal,
      required this.poin,
      required this.skema});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'waktu': waktu, // Align with database column name
      'id_anak': id_anak,
      'tanggal': tanggal,
      'poin': poin,
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
      poin: map['poin'],
      skema: map['skema'],
      // Align with database column name
    );
  }
}
