class Review {
  final int reviewID;
  final String userID;
  final int rating;
  final String comment;
  final DateTime reviewDate;
  final int bookID;

  Review({
    required this.reviewID,
    required this.userID,
    required this.rating,
    required this.comment,
    required this.reviewDate,
    required this.bookID,
  });

  // Convert Review object to JSON format
  Map<String, dynamic> toJson() {
    return {
      'reviewID': reviewID,
      'username': userID,
      'rating': rating,
      'comment': comment,
      'reviewDate': reviewDate.toIso8601String(), // Format date in ISO 8601
      'bookID': bookID,
    };
  }
}
