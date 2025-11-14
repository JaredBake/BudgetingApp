import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter_application/models/user.dart';

import 'package:localstorage/localstorage.dart';

class StatsService {
  static const String baseUrl = 'http://localhost:5284';

  static Future<Map<String, dynamic>?> getUserFundStats(int userId) async {
    final token = localStorage.getItem('token');
    final url = Uri.parse('$baseUrl/api/Stats/users/$userId/funds');

    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load user fund stats: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>?> getUserAccountStats(int userId) async {
    final token = localStorage.getItem('token');
    // print("*******************************");
    // print(token);
    // print("*******************************");
    final url = Uri.parse('$baseUrl/api/Stats/users/$userId/accounts');

    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception(
        'Failed to load user account stats: ${response.statusCode}',
      );
    }
  }
}
