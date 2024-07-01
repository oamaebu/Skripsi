class Tema {
  int? id;
  String namaTema;
  int idGambar;

  Tema({
    this.id,
    required this.idGambar
    ,
    required this.namaTema
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_gambar': idGambar,
      'namaTema': namaTema,
    };
  }

  static Tema fromMap(Map<String, dynamic> map) {
    return Tema(
      id: map['id'],
      idGambar: map['id_gambar'],
      namaTema: map['namaTema'],
    );
  }
}
