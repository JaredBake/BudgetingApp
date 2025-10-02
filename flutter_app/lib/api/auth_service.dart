import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:5284';

  static Future<bool> authenticateUser(String email, String password) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/Users/GetAll'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final users = jsonDecode(response.body) as List;
      final user = users.firstWhere(
        (u) =>
            u['Credentials']['Email'] == email &&
            u['Credentials']['Password'] == password,
        orElse: () => null,
      );
      return user != null;
    } else {
      throw Exception('Failed to load users');
    }
  }
}
