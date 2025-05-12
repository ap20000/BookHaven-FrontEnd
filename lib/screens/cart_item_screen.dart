import 'package:book_frontend/api/order_service.dart';
import 'package:book_frontend/model/cart_item.dart';
import 'package:book_frontend/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import '../api/cart_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cartService = CartService();
  late Future<List<CartItem>> _cartFuture;

  @override
  void initState() {
    super.initState();
    _cartFuture = _cartService.getCartItems();
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
      body: FutureBuilder<List<CartItem>>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }

          final items = snapshot.data!;
          final total = items.fold(0.0, (sum, item) => sum + item.total);

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      leading:
                          item.coverImageUrl != null
                              ? Image.network(
                                item.coverImageUrl!,
                                width: 50,
                                height: 75,
                                fit: BoxFit.cover,
                              )
                              : const Icon(
                                Icons.book,
                                size: 40,
                                color: Colors.black54,
                              ),
                      title: Text(
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Qty: ${item.quantity} | \$${item.price.toStringAsFixed(2)}',
                      ),
                      trailing: Text(
                        '\$${item.total.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final cartItems = await _cartService.getCartItems();

                          if (cartItems.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cart is empty'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          final items =
                              cartItems
                                  .map(
                                    (item) => {
                                      'bookID': item.bookId,
                                      'quantity': item.quantity,
                                    },
                                  )
                                  .toList();

                          final orderService = OrderService();
                          final result = await orderService.placeOrder(
                            items,
                            applyDiscount: true,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result['message'] ??
                                    'Order placed successfully',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );

                          // Optionally, refresh the cart
                          setState(() {
                            _cartFuture = _cartService.getCartItems();
                          });

                          // Navigate to success or order summary screen if needed
                          Navigator.pushNamed(context, '/orders-list');
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Checkout failed: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text('Proceed to Checkout'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
