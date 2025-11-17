import 'credentials.dart';
import 'fund.dart';
import 'money.dart';
import 'transaction.dart';
import 'data.dart';

class User {
  final DateTime createdAt;
  final Credentials
  credentials; // Credentials objects hold name, username, password, email
  final Data data;

  // Constructor
  User({
    required this.createdAt,
    required this.credentials,
    required this.data,
  });

  Credentials getCredentials() {
    return credentials;
  }

  bool addTransaction(Transaction transaction) {
    // TODO: Implement logic to add a transaction
    return true;
  }

  bool removeTransaction(Transaction transaction) {
    //TODO: Implement logic to remove a transaction
    return true;
  }

  List<Transaction> getTransactions() {
    // TODO: Implement logic to get transactions
    return [];
  }

  List<Transaction> getTransactionsByCategory(
    String category,
    DateTime startDate,
    DateTime endDate,
  ) {
    //TODO: Implement logic to get transactions by category within a date range
    return [];
  }

  bool addFund(Fund Fund) {
    //TODO: Implement logic to add a fund
    return true;
  }

  List<Fund> getFunds() {
    //TODO: Implement logic to get funds
    return [];
  }

  Money getTotalIncome(DateTime startDate, DateTime endDate) {
    //TODO: Implement logic to calculate total income within a date range
    return Money(amount: 0.0, currency: 'USD');
  }

  Money getTotalExpense(DateTime startDate, DateTime endDate) {
    //TODO: Implement logic to calculate total expense within a date range
    return Money(amount: 0.0, currency: 'USD');
  }
}
