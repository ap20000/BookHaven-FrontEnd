import 'dart:convert';
import 'package:book_frontend/model/bookmark.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  final String baseUrl = 'http://localhost:5062/api/user-actions/bookmark';

  Future<void> addBookmark(int bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId');

    if (token == null || userId == null) {
      throw Exception('User not authenticated.');
    }

    final url = Uri.parse('$baseUrl/$userId/$bookId');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'userId': userId, 'bookId': bookId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add bookmark: ${response.body}');
    }
  }

  Future<void> removeBookmark(int bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId');

    if (token == null || userId == null) {
      throw Exception('User not authenticated.');
    }

    final url = Uri.parse('$baseUrl/$userId/$bookId');

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove bookmark: ${response.body}');
    }
  }

  Future<List<Bookmark>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId');

    if (token == null || userId == null) {
      throw Exception('User not authenticated.');
    }

    final url = Uri.parse('$baseUrl/getBookmarks/$userId');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Bookmark.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load bookmarks: ${response.body}');
    }
  }
}
