import 'package:book_frontend/api/auth_service.dart';
import 'package:book_frontend/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import '../../api/claim_service.dart';

class ClaimProcessPage extends StatefulWidget {
  const ClaimProcessPage({Key? key}) : super(key: key);

  @override
  State<ClaimProcessPage> createState() => _ClaimProcessPageState();
}

class _ClaimProcessPageState extends State<ClaimProcessPage> {
  final _claimCodeController = TextEditingController();
  final _claimService = ClaimService();

  Map<String, dynamic>? orderDetails;
  bool isLoading = false;
  String? error;

  // GET API to fetch order details by claim code
  Future<void> _verifyCode() async {
    setState(() {
      isLoading = true;
      orderDetails = null;
      error = null;
    });

    final enteredCode = _claimCodeController.text.trim();
    print('[DEBUG] Verifying claim code: $enteredCode');

    try {
      final result = await _claimService.verifyClaimCode(enteredCode);
      print('[DEBUG] Order details received: $result');
      setState(() => orderDetails = result);
    } catch (e) {
      print('[ERROR] Claim verification failed: $e');
      setState(() => error = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  // POST API to mark order as fulfilled
  Future<void> _fulfillOrder() async {
    if (orderDetails == null || orderDetails!['claimCode'] == null) return;

    final claimCode = orderDetails!['claimCode'];
    print('[DEBUG] Attempting to fulfill order with claim code: $claimCode');

    final success = await _claimService.markClaimCodeFulfilled(claimCode);

    print('[DEBUG] Fulfillment response: $success');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Order marked as fulfilled!' : 'Failed to fulfill order.',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      setState(() {
        _claimCodeController.clear();
        orderDetails = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        isLoggedIn: true,
        activeRoute: 'claim',
        onHomePressed: () => Navigator.pushNamed(context, '/home'),
        onCatalogPressed: () => Navigator.pushNamed(context, '/catalog'),
        onBookmarkPressed: () => Navigator.pushNamed(context, '/bookmarks'),
        onCartPressed: () => Navigator.pushNamed(context, '/cart'),
        onLogoutPressed: () async {
          final auth = AuthService();
          await auth.logout();
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _claimCodeController,
              decoration: const InputDecoration(
                labelText: 'Enter Claim Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : _verifyCode,
              child:
                  isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text('Verify'),
            ),
            const SizedBox(height: 20),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            if (orderDetails != null) ...[
              const Divider(height: 32),
              Text('Order ID: ${orderDetails!['orderID']}'),
              Text('Claim Code: ${orderDetails!['claimCode']}'),
              Text('Total: \$${orderDetails!['totalAmount']}'),
              Text('Status: ${orderDetails!['pickupStatus']}'),
              const SizedBox(height: 12),
              const Text(
                'Items:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (orderDetails!['items'] is List)
                ...List.from(orderDetails!['items']).map(
                  (item) => ListTile(
                    title: Text(item['title']),
                    subtitle: Text('Qty: ${item['quantity']}'),
                    trailing: Text('\$${item['priceAtPurchase']}'),
                  ),
                ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _fulfillOrder,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: const Text('Mark as Fulfilled'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
