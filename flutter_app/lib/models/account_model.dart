import 'money.dart';
import 'transaction.dart';
import 'accountType.dart';

class AccountModel {
  final int id;
  final String name;
  final AccountType accountType;
  final Money balance;
  final List<Transaction> transactions;

  AccountModel({
    required this.id,
    required this.name,
    required this.accountType,
    required this.balance,
    this.transactions = const [],
  });

  int getId() => id;
  String getName() => name;
  AccountType getAccountType() => accountType;
  Money getBalance() => balance;
  List<Transaction> getTransactions() => transactions;

  @override
  String toString() {
    return '''AccountModel{
      id: $id,
      name: $name,
      accountType: $accountType,
      balance: ${balance.toString()},
      transactions: ${transactions.length} items
    }''';
  }
}