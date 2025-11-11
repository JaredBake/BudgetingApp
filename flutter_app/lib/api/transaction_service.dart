import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import '../models/transaction.dart';
import '../models/money.dart';
import '../models/TransactionType.dart';

class TransactionService {
  static const String baseUrl = 'http://localhost:5284';

  static Future<List<Transaction>> getUserTransactions() async {
    final token = localStorage.getItem('token');

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/Transactions/MyTransactions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final transactionsData = jsonDecode(response.body) as List<dynamic>;
      final transactions = transactionsData
          .map((data) => _parseTransaction(data as Map<String, dynamic>))
          .toList();
      
      // Sort by date (newest first) - already sorted on backend but just to be sure
      transactions.sort((a, b) => b.date.compareTo(a.date));
      
      return transactions;
    } else {
      throw Exception('Failed to load transactions');
    }
  }



  static Transaction _parseTransaction(Map<String, dynamic> data) {
    return Transaction(
      id: data['id'] ?? 0,
      accountId: data['accountId'] ?? 0,
      date: DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()),
      money: Money(
        amount: (data['money']?['amount'] as num?)?.toDouble() ?? 0.0,
        currency: data['money']?['currency'] ?? 'USD',
      ),
      description: 'Transaction #${data['id'] ?? 0}', // Fallback since backend doesn't have description
      transactionType: _parseTransactionType(data['type']),
      categoryId: data['categoryId'],
      fundId: data['fundId'],
    );
  }

  static TransactionType _parseTransactionType(dynamic typeValue) {
    if (typeValue == null) {
      return TransactionType.expense; // Default fallback
    }
    
    // Handle both string and int representations
    if (typeValue is String) {
      return typeValue.toLowerCase() == 'income' 
          ? TransactionType.income 
          : TransactionType.expense;
    } else if (typeValue is int) {
      return typeValue == 1 ? TransactionType.income : TransactionType.expense;
    }
    
    return TransactionType.expense;
  }

  static Future<Transaction?> getTransactionById(int id) async {
    final token = localStorage.getItem('token');

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/Transactions/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return _parseTransaction(data);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load transaction');
    }
  }

  static Future<Transaction> createTransaction({
    required int accountId,
    required double amount,
    required TransactionType type,
    String currency = 'USD',
    String? description,
    int? categoryId,
    int? fundId,
  }) async {
    final token = localStorage.getItem('token');

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final transactionData = {
      'accountId': accountId,
      'date': DateTime.now().toUtc().toIso8601String(),
      'money': {
        'amount': amount,
        'currency': currency,
      },
      'type': type == TransactionType.income ? 1 : 0, // Send as int: Income=1, Expense=0
      if (categoryId != null) 'categoryId': categoryId,
      if (fundId != null) 'fundId': fundId,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/api/Transactions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(transactionData),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return _parseTransaction(data);
    } else {
      throw Exception('Failed to create transaction: ${response.statusCode} ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> getUserAccounts() async {
    final token = localStorage.getItem('token');

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/Accounts/MyAccounts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final accountsData = jsonDecode(response.body) as List<dynamic>;
      List<Map<String, dynamic>> accounts = [];
      
      for (var accountData in accountsData) {
        accounts.add({
          'id': accountData['id'],
          'name': accountData['name'] ?? 'Account ${accountData['id']}',
          'accountType': accountData['accountType'],
          'balance': accountData['balance'],
        });
      }
      
      return accounts;
    } else {
      throw Exception('Failed to load accounts');
    }
  }
}