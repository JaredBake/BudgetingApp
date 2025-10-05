// import 'dart:ffi';

import 'package:flutter_application/models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginResponse {
    final bool authenticated;
    final String username;
    final String token;
    final int UserId;
    final DateTime ExpiresAt;


    LoginResponse({
      required this.authenticated,
      required this.username,
      required this.token,
      required this.UserId,
      required this.ExpiresAt
    });
}



class AuthService {
  static const String baseUrl = 'http://localhost:5284';

  static Future<User?> login(
    String email,
    String password
  ) async {    

    final queryParameters = {
      'email': email.isNotEmpty ? email : '',
      'passowrd': password
    };

    final uri = Uri.http(baseUrl, '/api/Auth/login', queryParameters);

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      return null;
    }

    final res = jsonDecode(response.body) as LoginResponse;
    final userId = res.UserId;

    final userGet = await http.get(
      Uri.parse('$baseUrl/api/Users/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (userGet.statusCode == 200) {
      final user = jsonDecode(response.body) as User;
      return user;
    } else {
      throw Exception('Failed to load user after logging in');
    }
  
  }
}
