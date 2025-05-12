import 'dart:convert';
import 'package:book_frontend/model/book.dart';
import 'package:http/http.dart' as http;

class BookService {
  // Base URL for the API
  final String baseUrl = 'http://localhost:5062/api/book/';

  Future<List<Book>> getAllBooks() async {
    final response = await http.get(Uri.parse('${baseUrl}getAllBook'));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch books');
    }
  }

  Future<void> addBook(Map<String, dynamic> bookData) async {
    final response = await http.post(
      Uri.parse('${baseUrl}addBook'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(bookData),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add book: ${response.body}');
    }
  }

  Future<void> deleteBook(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete book: ${response.body}');
    }
  }

  Future<void> updateBook(int id, Map<String, dynamic> bookData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(bookData),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update book: ${response.body}');
    }
  }

  Future<List<Book>> getBooksByCategory(
    String category, {
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${baseUrl}category/$category?pageNumber=$pageNumber&pageSize=$pageSize',
        ),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(response.body);
        final List<dynamic> data = result['items'];
        return data.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load books for category $category: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching category books: $e');
    }
  }

  Future<Book> getBookById(int id) async {
    final response = await http.get(Uri.parse(baseUrl + '$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Book.fromJson(data);
    } else {
      throw Exception('Failed to fetch book with id $id');
    }
  }
}
