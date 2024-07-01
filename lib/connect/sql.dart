import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/models/Anak.dart';

class ApiService {
  static const String apiUrl = 'http://localhost:3000';

  // CRUD operations for Anak table
  Future<List<Anak>> fetchAnak() async {
    final response = await http.get(Uri.parse('$apiUrl/anak'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Anak> anakList = body.map((dynamic item) => Anak.fromMap(item)).toList();
      return anakList;
    } else {
      throw "Failed to load anak";
    }
  }

  Future<http.Response> createAnak(Anak anak) async {
    final response = await http.post(
      Uri.parse('$apiUrl/anak'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(anak.toMap()),
    );
    return response;
  }

  Future<http.Response> updateAnak(Anak anak) async {
    final response = await http.put(
      Uri.parse('$apiUrl/anak/${anak.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(anak.toMap()),
    );
    return response;
  }

  Future<http.Response> deleteAnak(int id) async {
    final response = await http.delete(Uri.parse('$apiUrl/anak/$id'));
    return response;
  }

  // Repeat similar methods for other tables: game, puzzle, garis, game_state
}
