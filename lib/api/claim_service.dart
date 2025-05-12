import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String apiBaseUrl = 'http://localhost:5062/api';

class ClaimService {
  // Verify claim code and get order details
  Future<Map<String, dynamic>> verifyClaimCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    print('[DEBUG] Verifying claim code: $code');
    print('[DEBUG] Retrieved token: ${token != null ? 'Exists' : 'Missing'}');

    final response = await http.get(
      Uri.parse('$apiBaseUrl/orders/claim/$code'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    print('[DEBUG] Response status: ${response.statusCode}');
    print('[DEBUG] Response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to verify claim code: ${response.body}');
    }
  }

  // Mark order as fulfilled using order ID
  Future<bool> markClaimCodeFulfilled(String ClaimCode) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$apiBaseUrl/orders/fulfill/$ClaimCode'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print(
      '[DEBUG] Fulfill Order ID: $ClaimCode → Status: ${response.statusCode}',
    );
    return response.statusCode == 200;
  }
}
