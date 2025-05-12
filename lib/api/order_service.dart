import 'dart:convert';
import 'package:book_frontend/model/order.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  final String baseUrl = 'http://localhost:5062/api/orders';

  Future<Map<String, dynamic>> placeOrder(
    List<Map<String, dynamic>> items, {
    bool applyDiscount = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) throw Exception('User not authenticated');

    final response = await http.post(
      Uri.parse('$baseUrl/place'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'items': items, 'applyDiscount': applyDiscount}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to place order: ${response.body}');
    }
  }

  Future<List<Order>> getUserOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId');

    if (token == null || userId == null) throw Exception('User not logged in.');

    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Order.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load orders: ${response.body}');
    }
  }

  Future<bool> cancelOrder(int orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) throw Exception('User not authenticated');

    final response = await http.post(
      Uri.parse('$baseUrl/$orderId/cancel'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to cancel order: ${response.body}');
    }
  }
}
