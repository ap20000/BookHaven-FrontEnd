import 'dart:convert';
import 'package:book_frontend/model/genre.dart';
import 'package:http/http.dart' as http;

class GenreService {
  final String baseUrl = 'http://localhost:5062/api/genre';

  Future<List<Genre>> getAllGenres() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Genre.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load genres');
    }
  }

  Future<Genre> getGenreById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return Genre.fromJson(json.decode(response.body));
    } else {
      throw Exception('Genre not found');
    }
  }

  Future<void> createGenre(String name) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create genre');
    }
  }

  Future<void> updateGenre(int id, String name) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name}),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to update genre');
    }
  }

  Future<void> deleteGenre(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete genre');
    }
  }
}
