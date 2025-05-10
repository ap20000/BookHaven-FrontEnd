import 'dart:convert';
import 'package:http/http.dart' as http;

const String API_URL =
    'http://localhost:5062/api/user/'; // Ensure this is correct

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(API_URL + 'login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to login: ${response.reasonPhrase}, Response Body: ${response.body}',
        );
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password, {
    String role = 'user', // Default role is 'user'
  }) async {
    try {
      final response = await http.post(
        Uri.parse(API_URL + 'register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Registration failed: ${response.statusCode}');
        print('Response Body: ${response.body}'); // Debugging
        throw Exception(
          'Failed to register: ${response.reasonPhrase}, Response Body: ${response.body}',
        );
      }
    } catch (error) {
      print('Error during registration: $error');
      throw Exception('Error: $error');
    }
  }
}
