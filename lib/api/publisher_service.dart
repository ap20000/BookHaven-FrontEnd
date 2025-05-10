import 'dart:convert';
import 'package:book_frontend/model/publisher.dart';
import 'package:http/http.dart' as http;

class PublisherService {
  final String baseUrl = 'http://localhost:5062/api/publisher';

  // Get all publishers
  Future<List<Publisher>> getAllPublishers() async {
    final response = await http.get(Uri.parse('$baseUrl/getAll'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((e) => Publisher.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load publishers');
    }
  }

  // Add a publisher
  Future<void> addPublisher(String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/addPublisher'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add publisher');
    }
  }

  // Delete a publisher
  Future<void> deletePublisher(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/delete/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete publisher');
    }
  }
}
