import 'money.dart';
import 'transaction.dart';
import 'fund.dart';
import 'accountType.dart';

// abstract class Account

abstract class Account {
  final int accountId;
  final String name;
  final AccountType accountType;
  Money balance;
  List<Transaction> transactions;

  Account({
    required this.accountId,
    required this.name,
    required this.accountType,
    required this.balance,
    required this.transactions,
  });

  String getDescription() {
    return this.name;
  }

  bool addTransaction(Transaction transaction);
  bool removeTransaction(Transaction transaction);
  List<Transaction> getTransactions();
  Money getBalance();
  int getAccountId() => this.accountId;
  AccountType getAccountType() => this.accountType;
}
