class CartItem {
  final int bookId;
  final String title;
  final double price;
  final int quantity;
  final double total;
  final String? coverImageUrl;

  CartItem({
    required this.bookId,
    required this.title,
    required this.price,
    required this.quantity,
    required this.total,
    this.coverImageUrl,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      bookId: json['bookId'],
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
      total: (json['total'] as num).toDouble(),
      coverImageUrl: json['coverImageUrl'],
    );
  }
}
