import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import '../models/account_model.dart';
import '../models/accountType.dart';
import '../models/money.dart';
import '../models/account.dart';
import '../models/account_factory.dart';
import 'base_url.dart';

class AccountService {
  static String baseUrl = BaseUrl.getUrl();

  static Future<List<Account>> getUserAccounts() async {
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

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load accounts: ${response.statusCode} ${response.body}',
      );
    }

    final accountsData = jsonDecode(response.body) as List<dynamic>;

    final accounts = accountsData.cast<Map<String, dynamic>>().map((data) {
      final accountType = _parseAccountType(data['accountType']);

      final balanceJson =
          (data['balance'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      final amount =
          (balanceJson['amount'] as num?)?.toDouble() ??
          (data['balanceAmount'] as num?)?.toDouble() ??
          0.0;
      final currency = (balanceJson['currency'] as String?) ?? 'USD';

      final money = Money(amount: amount, currency: currency);

      final id =
          (data['id'] as num?)?.toInt() ??
          (data['accountId'] as num?)?.toInt() ??
          0;
      final name = (data['name'] as String?) ?? 'Account $id';

      return AccountFactory.create(
        accountType,
        accountId: id,
        name: name,
        balance: money,
        transactions: [],
      );
    }).toList();

    accounts.sort((a, b) => a.name.compareTo(b.name));
    return accounts;
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
        case 'cash':
          return AccountType.cash;
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
        case 4:
          return AccountType.cash;
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

  static Future<Account> createAccount(Account account) async {
    final token = localStorage.getItem('token');
    final userId = localStorage.getItem('userId');

    if (token == null || userId == null) {
      throw Exception('User not authenticated');
    }

    // Build request payload from the domain Account
    final accountData = {
      'name': account.name,
      'accountType': _accountTypeToInt(account.accountType),
      'balance': {
        'amount': account.getBalance().getAmount(),
        'currency': account.getBalance().currency,
      },
    };

    // Send POST request
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

      // 🏗️ Build a proper domain Account using the factory
      final created = AccountFactory.create(
        _parseAccountType(data['accountType']),
        accountId: (data['id'] as num?)?.toInt() ?? 0,
        name: (data['name'] as String?) ?? '',
        balance: Money(
          amount: ((data['balance']?['amount']) as num?)?.toDouble() ?? 0.0,
          currency: (data['balance']?['currency'] as String?) ?? 'USD',
        ),
        transactions: [],
      );

      // Associate account with the user
      await _associateAccountWithUser(created.accountId, int.parse(userId));

      return created; // return domain Account
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

  static Future<bool> deleteAccount(int accountId) async {
    /***
     * Since the transaction service function for deleting transactions returns a boolean,
     * I changed this to return boolean for consistency. (Santos)
     */
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

    if (response.statusCode == 204) {
      return true;
    } else {
      print(
        'Failed to delete account: ${response.statusCode} - ${response.body}',
      );
      return false;
    }
  }
}
