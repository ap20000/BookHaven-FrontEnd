class Book {
  final int bookID;
  final String title;
  final String isbn;
  final String description;
  final String publicationDate;
  final double price;
  final int stock;
  final String language;
  final String format;
  final bool isOnSale;

  Book({
    required this.bookID,
    required this.title,
    required this.isbn,
    required this.description,
    required this.publicationDate,
    required this.price,
    required this.stock,
    required this.language,
    required this.format,
    required this.isOnSale,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      bookID: json['bookID'],
      title: json['title'],
      isbn: json['isbn'],
      description: json['description'],
      publicationDate: json['publicationDate'],
      price: json['price'].toDouble(),
      stock: json['stock'],
      language: json['language'],
      format: json['format'],
      isOnSale: json['isOnSale'] ?? false,
    );
  }
}
