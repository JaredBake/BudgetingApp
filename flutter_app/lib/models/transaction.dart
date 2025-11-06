import 'money.dart';
import 'category.dart';
import 'TransactionType.dart';

class Transaction {
  final int id;
  final int accountId;
  final DateTime date;
  final Money money;
  final String description;
  final TransactionType transactionType;

  Transaction({
    required this.id,
    required this.accountId,
    required this.date,
    required this.money,
    required this.description,
    required this.transactionType,
  });

  bool isIncome() {
    if (this.transactionType == TransactionType.income) {
      return true;
    }
    return false;
  }

  bool isExpense() {
    if (this.transactionType == TransactionType.expense) {
      return true;
    }
    return false;
  }

  int getId() {
    return this.id;
  }

  int getAccountId() {
    return this.accountId;
  }

  String getDescription() {
    return this.description;
  }

  DateTime getDate() {
    return this.date;
  }

  Money getMoney() {
    /*  Returns the money object associated with the transaction
        *   Money is a class that holds both the amount and the currency
        */
    return this.money;
  }

  TransactionType getTransactionType() {
    return this.transactionType;
  }

  @override
  String toString() {
    return '''Transaction{
            id: $id,
            accountId: $accountId,
            date: $date,
            money: ${money.toString()},
            description: $description,
            transactionType: $transactionType
        }''';
  }
}
