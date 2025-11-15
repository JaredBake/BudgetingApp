// import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter_application/models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:localstorage/localstorage.dart';
import 'base_url.dart';

class AuthService {
  static String baseUrl = BaseUrl.getUrl();

  static Future<bool> recordToken(Map<String, dynamic> response) async {
    print(response);

    if (response['authenticated'] == null ||
        response['username'] == null ||
        response['token'] == null ||
        response['userId'] == null ||
        response['expiresAt'] == null) {
      return false;
    }

    if (!response['authenticated']) return false;

    WidgetsFlutterBinding.ensureInitialized();
    await initLocalStorage();

    localStorage.setItem('username', response['username']);
    localStorage.setItem('token', response['token']);
    localStorage.setItem('userId', response['userId'].toString());
    localStorage.setItem('expiration', response['expiresAt'].toString());

    return true;
  }

  static Future<Map<String, dynamic>> getUser() async {
    final token = localStorage.getItem('token');
    final userId = localStorage.getItem('userId');

    final userGet = await http.get(
      Uri.parse('$baseUrl/api/Users/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (userGet.statusCode == 200) {
      final user = jsonDecode(userGet.body) as Map<String, dynamic>;
      return user;
    } else {
      throw Exception('Failed to load user after logging in');
    }
  }

  static Future<Map<String, dynamic>?> register(
    String name,
    String username,
    String email,
    String password,
  ) async {
    final jsonBody = jsonEncode({
      'name': name,
      'username': username,
      'email': email,
      'password': password,
    });

    final url = Uri.parse('$baseUrl/api/Auth/register');

    final response = await http.post(
      url,
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonBody,
    );
    debugPrint(
      'register() status=${response.statusCode} body=${response.body}',
    );

    if (response.statusCode != 200) {
      return null;
    }

    final raw = json.decode(response.body) as Map<String, dynamic>;

    final normalized = <String, dynamic>{
      'authenticated': raw['authenticated'] ?? true,
      'username':
          raw['username'] ??
          raw['userName'] ??
          raw['user']?['username'] ??
          username,
      'token': raw['token'],
      'userId': raw['userId'],
      'expiresAt': raw['expiresAt'],
    };

    if (normalized['token'] == null || normalized['userId'] == null) {
      return login(email, password);
    }

    if (!await recordToken(normalized)) {
      return null;
    }

    return getUser();
  }

  static Future<Map<String, dynamic>?> login(
    String email,
    String password,
  ) async {
    final jsonBody = jsonEncode({'email': email, 'password': password});
    final url = Uri.parse('$baseUrl/api/Auth/login');

    // 1) Fix the content-type header typo
    final response = await http.post(
      url,
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonBody,
    );

    if (response.statusCode != 200) {
      debugPrint('login() ${response.statusCode}: ${response.body}');
      return null;
    }

    final raw = json.decode(response.body) as Map<String, dynamic>;

    final normalized = <String, dynamic>{
      'authenticated': raw['authenticated'] ?? true,
      'username':
          raw['username'] ??
          raw['userName'] ??
          raw['user']?['username'] ??
          email,
      'token': raw['token'] ?? raw['jwt'] ?? raw['accessToken'],
      'userId': raw['userId'] ?? raw['id'] ?? raw['user']?['id'],
      'expiresAt': raw['expiresAt'] ?? raw['expires'] ?? raw['exp'],
    };

    if (normalized['token'] == null || normalized['userId'] == null) {
      debugPrint('login(): missing token/userId in response: $raw');
      return null;
    }
    if (!await recordToken(normalized)) {
      debugPrint(
        'login(): recordToken() returned false. normalized=$normalized',
      );
      return null;
    }

    return getUser();
  }
}
