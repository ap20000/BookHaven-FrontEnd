import 'package:flutter/material.dart';
import 'package:book_frontend/api/review_service.dart'; // Add your ReviewService import
import 'package:book_frontend/model/review.dart'; // Add your Review model import

class AddReviewPage extends StatefulWidget {
  final int bookId; // Pass bookId to this page

  const AddReviewPage({Key? key, required this.bookId}) : super(key: key);

  @override
  _AddReviewPageState createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  final ReviewService _reviewService = ReviewService();
  final TextEditingController _commentController = TextEditingController();
  int _rating = 0; // Default rating

  Future<void> _submitReview() async {
    if (_rating == 0 || _commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating and comment')),
      );
      return;
    }

    final review = Review(
      bookId: widget.bookId,
      rating: _rating,
      comment: _commentController.text,
    );

    try {
      await _reviewService.submitReview(review);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully')),
      );
      // You can optionally navigate back or reset the form
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Widget for rating stars
  Widget _buildRatingStars() {
    return Row(
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: () {
            setState(() {
              _rating = index + 1;
            });
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Your Review')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rate this Book',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildRatingStars(),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Your Comment',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitReview,
              child: const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}
