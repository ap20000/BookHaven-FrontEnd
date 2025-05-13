class Review {
  final int bookId;
  final int rating;
  final String comment;

  Review({required this.bookId, required this.rating, required this.comment});

  Map<String, dynamic> toJson() {
    return {'bookID': bookId, 'rating': rating, 'comment': comment};
  }
}
