class IsiGambar {
  int? id;
  String label;
  String tingkatKesulitan;
  String gambar1;
  String gambar2;
  String gambar3;
  String? suara;
  bool statusSkema1;
  bool statusSkema2;
  bool statusSkema3;

  IsiGambar({
    this.id,
    this.suara,
    required this.label,
    required this.tingkatKesulitan,
    required this.gambar1,
    required this.gambar2,
    required this.gambar3,
    this.statusSkema1 = false,
    this.statusSkema2 = false,
    this.statusSkema3 = false,
  });

  factory IsiGambar.fromMap(Map<String, dynamic> map) {
    return IsiGambar(
      id: map['id'],
      label: map['label'],
      tingkatKesulitan: map['TingkatKesulitan'],
      gambar1: map['Gambar1'],
      gambar2: map['Gambar2'],
      gambar3: map['Gambar3'],
      suara: map['suara'],
      statusSkema1: map['StatusSkema1'] == 1,
      statusSkema2: map['StatusSkema2'] == 1,
      statusSkema3: map['StatusSkema3'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'TingkatKesulitan': tingkatKesulitan,
      'Gambar1': gambar1,
      'Gambar2': gambar2,
      'Gambar3': gambar3,
      'suara': suara,
      'StatusSkema1': statusSkema1 ? 1 : 0,
      'StatusSkema2': statusSkema2 ? 1 : 0,
      'StatusSkema3': statusSkema3 ? 1 : 0,
    };
  }
}
