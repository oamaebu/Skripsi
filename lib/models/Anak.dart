class Anak {
  int? id;
  String nama;
  int umur;
  String kelas;
  String kelamin;

  Anak({
    this.id,
    required this.nama,
    required this.umur,
    required this.kelas,
    required this.kelamin,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'umur': umur,
      'kelas': kelas,
      'kelamin': kelamin,
    };
  }

  static Anak fromMap(Map<String, dynamic> map) {
    return Anak(
      id: map['id'] ?? 0,
      nama: map['nama'],
      umur: map['umur'],
      kelas: map['kelas'],
      kelamin: map['kelamin'], // Align with database column name
    );
  }
}
