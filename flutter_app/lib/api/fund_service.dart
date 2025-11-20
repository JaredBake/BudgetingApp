import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import '../models/money.dart';

class FundService {
  static const String baseUrl = 'http://localhost:5284';

  static Future<List<Map<String, dynamic>>> getUserFunds() async {
    final token = localStorage.getItem('token');

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/Funds/MyFunds'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final fundsData = jsonDecode(response.body) as List<dynamic>;
      List<Map<String, dynamic>> funds = [];
      
      for (var fund in fundsData) {
        funds.add({
          'id': fund['id'],
          'description': fund['description'] ?? 'Fund ${fund['id']}',
          'goalAmount': Money(
            amount: (fund['goalAmount']?['amount'] as num?)?.toDouble() ?? 0.0,
            currency: fund['goalAmount']?['currency'] ?? 'USD',
          ),
          'current': Money(
            amount: (fund['current']?['amount'] as num?)?.toDouble() ?? 0.0,
            currency: fund['current']?['currency'] ?? 'USD',
          ),
        });
      }
      
      return funds;
    } else {
      throw Exception('Failed to load funds');
    }
  }

  static Future<Map<String, dynamic>> createFund({
    required String description,
    required double goalAmount,
    required double currentAmount,
    String currency = 'USD',
  }) async {
    final token = localStorage.getItem('token');

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final fundData = {
      'description': description,
      'goalAmount': {
        'amount': goalAmount,
        'currency': currency,
      },
      'current': {
        'amount': currentAmount,
        'currency': currency,
      },
    };

    final response = await http.post(
      Uri.parse('$baseUrl/api/Funds'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(fundData),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      return {
        'id': data['id'],
        'description': data['description'],
        'goalAmount': Money(
          amount: (data['goalAmount']?['amount'] as num?)?.toDouble() ?? 0.0,
          currency: data['goalAmount']?['currency'] ?? 'USD',
        ),
        'current': Money(
          amount: (data['current']?['amount'] as num?)?.toDouble() ?? 0.0,
          currency: data['current']?['currency'] ?? 'USD',
        ),
      };
    } else {
      throw Exception('Failed to create fund: ${response.statusCode} ${response.body}');
    }
  }
}
