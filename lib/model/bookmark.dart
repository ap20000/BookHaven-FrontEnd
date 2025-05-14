class Bookmark {
  final int bookmarkID;
  final int bookID;
  final String bookTitle;
  final String description;

  Bookmark({
    required this.bookmarkID,
    required this.bookID,
    required this.bookTitle,
    required this.description,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      bookmarkID: json['bookmarkID'],
      bookID: json['bookID'],
      bookTitle: json['bookTitle'],
      description: json['description'],
    );
  }
}
