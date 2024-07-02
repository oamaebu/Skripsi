class Tema {
  int? id;
  String namaTema;
  bool status;

  Tema({required this.id, required this.namaTema, required this.status});

  factory Tema.fromMap(Map<String, dynamic> map) {
    return Tema(
      id: map['id'],
      namaTema: map['namaTema'],
      status: map['status'] == 1, // Convert 1 to true and 0 to false
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'namaTema': namaTema,
      'status': status ? 1 : 0, // Convert true to 1 and false to 0
    };
  }
}
