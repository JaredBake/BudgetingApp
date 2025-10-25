import 'account.dart';
import 'money.dart';
import 'transaction.dart';
import 'accountType.dart';

class Savings extends Account {
  Savings({
    required int accountId,
    required String name,
    required Money balance,
    required List<Transaction> transactions,
  }) : super(
         accountId: accountId,
         name: name,
         accountType: AccountType.savings,
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
    if (!transactions.contains(transaction)) {
      return false;
    }

    Money newBalance = balance.addMoney(transaction.getMoney());
    balance = newBalance;

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
