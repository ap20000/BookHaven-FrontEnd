import 'dart:convert';
import 'package:book_frontend/model/book.dart';
import 'package:http/http.dart' as http;

class BookService {
  // Base URL for the API
  final String baseUrl = 'http://localhost:5062/api/book/';

  // Get all books
  Future<List<Book>> getAllBooks() async {
    try {
      final response = await http.get(Uri.parse(baseUrl + 'getAllBook'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching books: $e');
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

  //   // Search books
  //   Future<List<dynamic>> searchBooks(String query) async {
  //     try {
  //       final response = await http.get(
  //         Uri.parse('$baseUrl/books/search?q=$query'),
  //         headers: _headers,
  //       );

  //       if (response.statusCode == 200) {
  //         return json.decode(response.body);
  //       } else {
  //         throw Exception('Failed to search books: ${response.statusCode}');
  //       }
  //     } catch (e) {
  //       throw Exception('Error searching books: $e');
  //     }
  //   }

  //   // Get book details
  //   Future<Map<String, dynamic>> getBookDetails(String bookId) async {
  //     try {
  //       final response = await http.get(
  //         Uri.parse('$baseUrl/books/$bookId'),
  //         headers: _headers,
  //       );

  //       if (response.statusCode == 200) {
  //         return json.decode(response.body);
  //       } else {
  //         throw Exception('Failed to load book details: ${response.statusCode}');
  //       }
  //     } catch (e) {
  //       throw Exception('Error fetching book details: $e');
  //     }
  //   }

  //   // Get featured books
  //   Future<List<dynamic>> getFeaturedBooks() async {
  //     try {
  //       final response = await http.get(
  //         Uri.parse('$baseUrl/books/featured'),
  //         headers: _headers,
  //       );

  //       if (response.statusCode == 200) {
  //         return json.decode(response.body);
  //       } else {
  //         throw Exception(
  //           'Failed to load featured books: ${response.statusCode}',
  //         );
  //       }
  //     } catch (e) {
  //       throw Exception('Error fetching featured books: $e');
  //     }
  //   }

  //   // Add a new book
  //   Future<Map<String, dynamic>> addBook(Map<String, dynamic> bookData) async {
  //     try {
  //       final response = await http.post(
  //         Uri.parse('$baseUrl/books'),
  //         headers: _headers,
  //         body: json.encode(bookData),
  //       );

  //       if (response.statusCode == 201) {
  //         return json.decode(response.body);
  //       } else {
  //         throw Exception('Failed to add book: ${response.statusCode}');
  //       }
  //     } catch (e) {
  //       throw Exception('Error adding book: $e');
  //     }
  //   }

  //   // Update a book
  //   Future<Map<String, dynamic>> updateBook(
  //     String bookId,
  //     Map<String, dynamic> bookData,
  //   ) async {
  //     try {
  //       final response = await http.put(
  //         Uri.parse('$baseUrl/books/$bookId'),
  //         headers: _headers,
  //         body: json.encode(bookData),
  //       );

  //       if (response.statusCode == 200) {
  //         return json.decode(response.body);
  //       } else {
  //         throw Exception('Failed to update book: ${response.statusCode}');
  //       }
  //     } catch (e) {
  //       throw Exception('Error updating book: $e');
  //     }
  //   }

  //   // Delete a book
  //   Future<bool> deleteBook(String bookId) async {
  //     try {
  //       final response = await http.delete(
  //         Uri.parse('$baseUrl/books/$bookId'),
  //         headers: _headers,
  //       );

  //       return response.statusCode == 204;
  //     } catch (e) {
  //       throw Exception('Error deleting book: $e');
  //     }
  //   }
}
