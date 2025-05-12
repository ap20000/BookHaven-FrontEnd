import 'dart:convert';
import 'package:book_frontend/model/announcement.dart';
import 'package:http/http.dart' as http;

class AnnouncementService {
  static const String baseUrl = "http://localhost:5062/api/annoucement";

  Future<List<Announcement>> getActiveAnnouncements() async {
    final response = await http.get(Uri.parse("$baseUrl/active"));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Announcement.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load announcements");
    }
  }

  Future<void> createAnnouncement(Announcement announcement) async {
    final response = await http.post(
      Uri.parse("$baseUrl/create"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(announcement.toJson()),
    );

    if (response.statusCode != 201) {
      print("Response Body: ${response.body}");

      throw Exception("Failed to create announcement");
    }
  }

  Future<void> deleteAnnouncement(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));
    if (response.statusCode != 204) {
      throw Exception("Failed to delete announcement");
    }
  }
}
