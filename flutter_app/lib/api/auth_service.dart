// import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter_application/models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:localstorage/localstorage.dart';


class AuthService {
  static const String baseUrl = 'http://localhost:5284';

  static Future<bool> recordToken(Map<String, dynamic> response) async {
    if (response['authenticated'] != null &&
        response['username'] != null &&
        response['token'] != null &&
        response['userId'] != null &&    
        response['expiresAt'] != null)
    {
      return false;
    }    

    print(response);

    if (!response['authenticated']) return false;

    WidgetsFlutterBinding.ensureInitialized();
    await initLocalStorage();

    localStorage.setItem('username', response['username']);
    localStorage.setItem('token', response['token']);
    localStorage.setItem('userId', response['userId'].toString());
    localStorage.setItem('expiration', response['expiresAt'].toString());

    return true;
  }

  static Future<Map<String, dynamic>?> register(
    String name,
    String username,
    String email,
    String password
  ) async {

    final jsonBody = jsonEncode({
      'name': name,
      'username': username,
      'email': email,
      'password': password
    });

    final url = Uri.parse('$baseUrl/api/Auth/register');

    final response = await http.post(
      url,
      headers: <String, String>{'Content-Type': 'application/json; charst=UTF-8'},
      body: jsonBody
    ); 

    if (response.statusCode != 200){
      return null;
    }  

    final res = json.decode(response.body) as Map<String, dynamic>;

    if (! await recordToken(res)) {
      // Error login response unsuccessful
      return null;
    }

    final userId = res['userId'];

    final userGet = await http.get(
      Uri.parse('$baseUrl/api/Users/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (userGet.statusCode == 200) {
      final user = jsonDecode(userGet.body) as Map<String, dynamic>;
      return user;
    } else {
      throw Exception('Failed to load user after logging in');
    }
  }

  static Future<Map<String, dynamic>?> login(
    String email,
    String password
  ) async {    

    final jsonBody = jsonEncode({
      'email': email,
      'password': password
    });

    final url = Uri.parse('$baseUrl/api/Auth/login');
    

    final response = await http.post(
      url,
      headers: <String, String>{'Content-Type': 'application/json; charst=UTF-8'},
      body: jsonBody
      );

    if (response.statusCode != 200) {
      return null;
    }

    final res = json.decode(response.body) as Map<String, dynamic>;

    if (! await recordToken(res)) {
      // Error login response unsuccessful
      return null;
    }
    
    final userId = res['userId'];

    final userGet = await http.get(
      Uri.parse('$baseUrl/api/Users/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (userGet.statusCode == 200) {
      final user = jsonDecode(userGet.body) as Map<String, dynamic>;
      return user;
    } else {
      throw Exception('Failed to load user after logging in');
    }
  
  }
}
