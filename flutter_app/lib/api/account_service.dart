import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import '../models/account_model.dart';
import '../models/accountType.dart';
import '../models/money.dart';

class AccountService {
  static const String baseUrl = 'http://localhost:5284';

  static Future<List<AccountModel>> getUserAccounts() async {
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
      final accounts = accountsData
          .map((data) => _parseAccount(data as Map<String, dynamic>))
          .toList();

      // Sort by account name
      accounts.sort((a, b) => a.getName().compareTo(b.getName()));

      return accounts;
    } else {
      throw Exception('Failed to load accounts');
    }
  }

  static AccountModel _parseAccount(Map<String, dynamic> data) {
    return AccountModel(
      id: data['id'] ?? 0,
      name: data['name'] ?? 'Account ${data['id']}',
      accountType: _parseAccountType(data['accountType']),
      balance: Money(
        amount: (data['balance']?['amount'] as num?)?.toDouble() ?? 0.0,
        currency: data['balance']?['currency'] ?? 'USD',
      ),
    );
  }

  static AccountType _parseAccountType(dynamic type) {
    if (type is String) {
      switch (type.toLowerCase()) {
        case 'checking':
          return AccountType.checking;
        case 'saving':
        case 'savings':
          return AccountType.savings;
        case 'creditcard':
        case 'credit_card':
          return AccountType.creditCard;
        case 'brokerage':
          return AccountType.brokerage;
        default:
          return AccountType.checking;
      }
    } else if (type is int) {
      switch (type) {
        case 0:
          return AccountType.checking;
        case 1:
          return AccountType.savings;
        case 2:
          return AccountType.creditCard;
        case 3:
          return AccountType.brokerage;
        default:
          return AccountType.checking;
      }
    }
    return AccountType.checking;
  }

  static Future<AccountModel?> getAccountById(int id) async {
    final token = localStorage.getItem('token');

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/Accounts/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return _parseAccount(data);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load account');
    }
  }

  static Future<AccountModel> createAccount({
    required String name,
    required AccountType accountType,
    required double initialBalance,
    required String currency,
  }) async {
    final token = localStorage.getItem('token');
    final userId = localStorage.getItem('userId');

    if (token == null || userId == null) {
      throw Exception('User not authenticated');
    }

    final accountData = {
      'name': name,
      'accountType': _accountTypeToInt(accountType),
      'balance': {'amount': initialBalance, 'currency': currency},
    };

    final response = await http.post(
      Uri.parse('$baseUrl/api/Accounts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(accountData),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final account = _parseAccount(data);

      // Associate the account with the current user
      await _associateAccountWithUser(account.getId(), int.parse(userId));

      return account;
    } else {
      throw Exception(
        'Failed to create account: ${response.statusCode} ${response.body}',
      );
    }
  }

  static int _accountTypeToInt(AccountType accountType) {
    switch (accountType) {
      case AccountType.checking:
        return 0;
      case AccountType.savings:
        return 1;
      case AccountType.creditCard:
        return 2;
      case AccountType.brokerage:
        return 3;
      case AccountType.cash:
        return 4;
    }
  }

  static Future<void> _associateAccountWithUser(
    int accountId,
    int userId,
  ) async {
    final token = localStorage.getItem('token');

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final associationData = {'userId': userId, 'accountId': accountId};

    final response = await http.post(
      Uri.parse('$baseUrl/api/Accounts/User'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(associationData),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to associate account with user: ${response.statusCode} ${response.body}',
      );
    }
  }

  static Future<AccountModel> updateAccount(AccountModel account) async {
    final token = localStorage.getItem('token');

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final accountData = {
      'id': account.getId(),
      'name': account.getName(),
      'accountType': _accountTypeToInt(account.getAccountType()),
      'balance': {
        'amount': account.getBalance().amount,
        'currency': account.getBalance().currency,
      },
    };

    final response = await http.put(
      Uri.parse('$baseUrl/api/Accounts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(accountData),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return _parseAccount(data);
    } else {
      throw Exception(
        'Failed to update account: ${response.statusCode} ${response.body}',
      );
    }
  }

  static Future<void> deleteAccount(int accountId) async {
    final token = localStorage.getItem('token');

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/api/Accounts/$accountId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete account: ${response.statusCode} ${response.body}',
      );
    }
  }
}
