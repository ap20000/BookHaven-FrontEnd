import 'package:book_frontend/model/author.dart';
import 'package:book_frontend/model/genre.dart';

class Book {
  final int bookID;
  final String title;
  final String isbn;
  final String description;
  final DateTime publicationDate;
  final double price;
  final int stock;
  final String language;
  final String format;
  final bool isOnSale;
  final int publisherID;
  final DateTime? saleStartDate;
  final DateTime? saleEndDate;
  final List<Author> authors;
  final List<Genre> genres;

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
    required this.publisherID,
    this.saleStartDate,
    this.saleEndDate,
    required this.authors,
    required this.genres,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    // Handle publisherID safely
    int safePublisherID;
    if (json['publisherID'] == null) {
      safePublisherID = 0;
    } else if (json['publisherID'] is int) {
      safePublisherID = json['publisherID'];
    } else {
      safePublisherID = 0;
    }

    // Handle price safely
    double safePrice;
    if (json['price'] == null) {
      safePrice = 0.0;
    } else if (json['price'] is int) {
      safePrice = (json['price'] as int).toDouble();
    } else if (json['price'] is double) {
      safePrice = json['price'];
    } else {
      safePrice = 0.0;
    }

    // Parse dates safely
    DateTime parseDate(dynamic dateValue) {
      if (dateValue == null || dateValue == '') {
        return DateTime.now();
      }
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        print('Error parsing date: $e for value: $dateValue');
        return DateTime.now();
      }
    }

    return Book(
      bookID: json['bookID'] ?? 0,
      title: json['title'] ?? '',
      isbn: json['isbn'] ?? '',
      description: json['description'] ?? '',
      publicationDate: parseDate(json['publicationDate']),
      price: safePrice,
      stock: json['stock'] ?? 0,
      language: json['language'] ?? '',
      format: json['format'] ?? '',
      isOnSale: json['isOnSale'] ?? false,
      publisherID: safePublisherID,
      saleStartDate:
          json['saleStartDate'] != null
              ? parseDate(json['saleStartDate'])
              : null,
      saleEndDate:
          json['saleEndDate'] != null ? parseDate(json['saleEndDate']) : null,

      authors:
          (json['authors'] as List).map((a) => Author.fromJson(a)).toList(),
      genres: (json['genres'] as List).map((g) => Genre.fromJson(g)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    // Format dates in UTC ISO8601 format
    String formatDate(DateTime date) {
      return date.toUtc().toIso8601String();
    }

    final Map<String, dynamic> data = {
      "title": title,
      "isbn": isbn,
      "description": description,
      "publicationDate": formatDate(publicationDate),
      "price": price,
      "stock": stock,
      "language": language,
      "format": format,
      "isOnSale": isOnSale,
      "publisherID": publisherID,
    };

    // Add sale dates only if they exist
    if (saleStartDate != null) {
      data["saleStartDate"] = formatDate(saleStartDate!);
    }
    if (saleEndDate != null) {
      data["saleEndDate"] = formatDate(saleEndDate!);
    }

    return data;
  }
}
