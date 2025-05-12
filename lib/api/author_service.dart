import 'dart:convert';
import 'package:book_frontend/model/author.dart';
import 'package:http/http.dart' as http;

class AuthorService {
  final String baseUrl = 'http://localhost:5062/api/author';

  Future<List<Author>> getAllAuthors() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Author.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load authors');
    }
  }

  Future<Author> getAuthorById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return Author.fromJson(json.decode(response.body));
    } else {
      throw Exception('Author not found');
    }
  }

  Future<void> createAuthor(String name) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create author');
    }
  }

  Future<void> updateAuthor(int id, String name) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name}),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to update author');
    }
  }

  Future<void> deleteAuthor(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete author');
    }
  }
}
