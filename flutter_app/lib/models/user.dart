import 'money.dart';
import 'transaction.dart';


class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String username;
  final DateTime timestamp;
  
  // Constructor
  User({required this.id, required this.name, required this.email, required this.password, required this.username, required this.timestamp});

  bool addTransaction(Transaction transaction) {
    // TODO: Implement logic to add a transaction
    return true;
  }

  bool removeTransaction(Transaction transaction) {
    //TODO: Implement logic to remove a transaction
    return true;
  }

  List<Transaction> getTransaction(){
    // TODO: Implement logic to get transactions
    return [];
  }

  List<Transaction> getTransactionsByCategory(String category, DateTime startDate, DateTime endDate) {
    //TODO: Implement logic to get transactions by category within a date range
    return [];
  }

  // bool addFund(Fund Fund){
  //   //TODO: Implement logic to add a fund
  //   return true;
  // }

  // List<Fund> getFunds(){
  //   //TODO: Implement logic to get funds
  //   return [];
  // }

  Money getTotalIncome(DateTime startDate, DateTime endDate){
    //TODO: Implement logic to calculate total income within a date range
    return Money(amount: 0.0, currency: 'USD');
  }

  Money getTotalExpense(DateTime startDate, DateTime endDate){
    //TODO: Implement logic to calculate total expense within a date range
    return Money(amount: 0.0, currency: 'USD');
  }
}