import 'dart:convert';
import 'package:book_frontend/model/cart_item.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  final String baseUrl = 'http://localhost:5062/api/user-actions/cart';

  Future<void> addToCart(String userId, int bookId, {int quantity = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('User not authenticated. Token is missing.');
    }

    final url = Uri.parse('$baseUrl/$userId/$bookId?quantity=$quantity');

    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add to cart: ${response.body}');
    }
  }

  Future<List<CartItem>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('token');

    if (userId == null || token == null) {
      throw Exception('User not logged in.');
    }

    final url = Uri.parse('$baseUrl/$userId');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((item) => CartItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load cart: ${response.body}');
    }
  }
}
