import 'account.dart';
import 'money.dart';
import 'transaction.dart';
import 'accountType.dart';

class CreditCard extends Account {
  CreditCard({
    required int accountId,
    required String name,
    required Money balance,
    required List<Transaction> transactions,
  }) : super(
         accountId: accountId,
         name: name,
         accountType: AccountType.creditCard,
         balance: balance,
         transactions: transactions,
       );

  @override
  bool addTransaction(Transaction transaction) {
    transactions.add(transaction);
    return true;
  }

  @override
  bool removeTransaction(Transaction transaction) {
    return transactions.remove(transaction);
  }

  @override
  List<Transaction> getTransactions() {
    return transactions;
  }

  @override
  Money getBalance() {
    return balance;
  }
}
