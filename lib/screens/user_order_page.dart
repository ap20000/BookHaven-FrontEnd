import 'package:book_frontend/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import '../api/order_service.dart';
import '../model/order.dart';
import 'package:intl/intl.dart';

class UserOrdersPage extends StatefulWidget {
  const UserOrdersPage({Key? key}) : super(key: key);

  @override
  State<UserOrdersPage> createState() => _UserOrdersPageState();
}

class _UserOrdersPageState extends State<UserOrdersPage> {
  final OrderService _orderService = OrderService();
  late Future<List<Order>> _orderFuture;

  @override
  void initState() {
    super.initState();
    _orderFuture = _orderService.getUserOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        isLoggedIn: true,
        activeRoute: 'cart',
        onHomePressed: () => Navigator.pushNamed(context, '/home'),
        onCatalogPressed: () => Navigator.pushNamed(context, '/catalog'),
        onBookmarkPressed: () => Navigator.pushNamed(context, '/bookmarks'),
        onCartPressed: () => Navigator.pushNamed(context, '/cart'),
      ),
      body: FutureBuilder<List<Order>>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('You haven’t placed any orders yet.'),
            );
          }

          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.all(12),
                child: ExpansionTile(
                  title: Text(
                    'Order #${order.orderId} - \$${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Status: ${order.status} | ${DateFormat.yMMMd().format(order.orderDate)}',
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pickup Status: ${order.pickupStatus}'),
                          if (order.discountApplied)
                            Text('Discount Applied: ${order.discountPercent}%'),
                          Text('Claim Code: ${order.claimCode}'),
                          const SizedBox(height: 8),
                          const Divider(),
                          const Text(
                            'Items:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...order.items.map(
                            (item) => ListTile(
                              title: Text(item.title),
                              subtitle: Text('Qty: ${item.quantity}'),
                              trailing: Text(
                                '\$${(item.priceAtPurchase * item.quantity).toStringAsFixed(2)}',
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          if (order.pickupStatus == "Pending" &&
                              order.status == "Placed")
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (_) => AlertDialog(
                                          title: const Text("Cancel Order"),
                                          content: const Text(
                                            "Are you sure you want to cancel this order?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    false,
                                                  ),
                                              child: const Text("No"),
                                            ),
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    true,
                                                  ),
                                              child: const Text("Yes"),
                                            ),
                                          ],
                                        ),
                                  );

                                  if (confirm == true) {
                                    try {
                                      final success = await _orderService
                                          .cancelOrder(order.orderId);
                                      if (success) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Order cancelled.'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        setState(() {
                                          _orderFuture =
                                              _orderService.getUserOrders();
                                        });
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to cancel: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.cancel),
                                label: const Text("Cancel Order"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
