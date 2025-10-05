import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const String baseUrl = 'http://localhost:5284';

  static Future<List<dynamic>> getAllUsers(
    String email,
    String password,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/Users/GetAll'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final users = jsonDecode(response.body) as List;
      return users;
    } else {
      throw Exception('Failed to load users');
    }
  }
}
