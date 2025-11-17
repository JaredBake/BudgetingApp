import 'account.dart';
import 'accountType.dart';
import 'money.dart';
import 'transaction.dart';

class Cash extends Account {
  Cash({
    required super.accountId,
    required super.name,
    required super.balance,
    required super.transactions,
  }) : super(
         accountType: AccountType.cash,
       );

  @override
  bool addTransaction(Transaction transaction) {
    final double transactionAmount = transaction.getMoney().getAmount();

    if (transaction.isExpense() && transactionAmount > balance.getAmount()) {
      // Insufficient funds
      return false;
    }

    if (transaction.getMoney().currency != balance.currency) {
      // Currency mismatch
      return false;
    }

    Money newBalance = balance.spendMoney(transaction.getMoney());
    balance = newBalance;
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

    transactions.remove(transaction);
    return true;
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
