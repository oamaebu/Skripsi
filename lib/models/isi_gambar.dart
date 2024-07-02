class IsiGambar {
  int? id;
  int? idtema;
  String label;
  String tingkatKesulitan;
  String gambar1;
  String gambar2;
  String gambar3;
  String? suara;
  bool status;

  IsiGambar(
      {this.id,
      this.suara,
      this.idtema,
      required this.label,
      required this.tingkatKesulitan,
      required this.gambar1,
      required this.gambar2,
      required this.gambar3,
      this.status = false});

  factory IsiGambar.fromMap(Map<String, dynamic> map) {
    return IsiGambar(
      id: map['id'],
      label: map['label'],
      idtema: map['id_tema'],
      tingkatKesulitan: map['TingkatKesulitan'],
      gambar1: map['Gambar1'],
      gambar2: map['Gambar2'],
      gambar3: map['Gambar3'],
      suara: map['suara'],
      status: map['Status'] == 1,

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'id_tema': idtema,
      'TingkatKesulitan': tingkatKesulitan,
      'Gambar1': gambar1,
      'Gambar2': gambar2,
      'Gambar3': gambar3,
      'suara': suara,
      'Status': status ? 1 : 0,
     
    };
  }
}
