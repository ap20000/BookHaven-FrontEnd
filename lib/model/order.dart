class OrderItem {
  final int bookId;
  final String title;
  final int quantity;
  final double priceAtPurchase;

  OrderItem({
    required this.bookId,
    required this.title,
    required this.quantity,
    required this.priceAtPurchase,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      bookId: json['bookID'],
      title: json['title'],
      quantity: json['quantity'],
      priceAtPurchase: (json['priceAtPurchase'] as num).toDouble(),
    );
  }
}

class Order {
  final int orderId;
  final DateTime orderDate;
  final double totalAmount;
  final String status;
  final String pickupStatus;
  final bool discountApplied;
  final int discountPercent;
  final String claimCode;
  final List<OrderItem> items;

  Order({
    required this.orderId,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.pickupStatus,
    required this.discountApplied,
    required this.discountPercent,
    required this.claimCode,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderID'],
      orderDate: DateTime.parse(json['orderDate']),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'],
      pickupStatus: json['pickupStatus'],
      discountApplied: json['discountApplied'],
      discountPercent: json['discountPercent'],
      claimCode: json['claimCode'],
      items:
          (json['items'] as List)
              .map((item) => OrderItem.fromJson(item))
              .toList(),
    );
  }
}
