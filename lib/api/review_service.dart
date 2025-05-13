import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:book_frontend/model/review.dart';

class ReviewService {
  final String baseUrl = 'http://yourapiurl/api/reviews/submit';

  Future<void> submitReview(Review review) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(review.toJson()),
      );

      if (response.statusCode == 200) {
        print('Review submitted successfully!');
      } else {
        throw Exception('Failed to submit review');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
