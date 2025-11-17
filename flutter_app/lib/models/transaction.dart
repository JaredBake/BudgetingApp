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
    final int? categoryId;
    final int? fundId;

    Transaction({
        required this.id,
        required this.accountId, 
        required this.date, 
        required this.money, 
        required this.description, 
        required this.transactionType,
        this.categoryId,
        this.fundId,
        });

    bool isIncome() {
        if (transactionType == TransactionType.income) {
            return true;
        }
        return false;
    }
    bool isExpense() {
        if (transactionType == TransactionType.expense) {
            return true;
        }
        return false;
    }


  int getId() {
    return id;
  }

  int getAccountId() {
    return accountId;
  }

  String getDescription() {
    return description;
  }

  DateTime getDate() {
    return date;
  }

  Money getMoney() {
    /*  Returns the money object associated with the transaction
        *   Money is a class that holds both the amount and the currency
        */
        return money;
    }

    TransactionType getTransactionType() {
        return transactionType;
    }

  @override
  String toString() {
    return '''Transaction{
            id: $id,
            accountId: $accountId,
            date: $date,
            money: ${money.toString()},
            description: $description,
            transactionType: $transactionType,
            categoryId: $categoryId,
            fundId: $fundId
        }''';
  }
}
