import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:book_frontend/model/review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  final String baseUrl = 'http://localhost:5062/api/reviews/submit';

  Future<void> submitReview(Review review) async {
    try {
      // Retrieve the token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token'); // Get token

      print('Token retrieved: $token'); // Debug print for the token

      if (token == null) {
        throw Exception('User not authenticated');
      }

      // Debug print for the review data being sent
      print('Review data: ${json.encode(review.toJson())}');

      // Make the HTTP request
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(review.toJson()),
      );

      // Check response status
      if (response.statusCode == 200) {
        print('Review submitted successfully!');
      } else {
        print('Failed to submit review: ${response.body}');
        throw Exception('Failed to submit review: ${response.body}');
      }
    } catch (e) {
      print('Error occurred during review submission: $e');
    }
  }
}
