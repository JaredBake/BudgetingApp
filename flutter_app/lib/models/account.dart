import 'money.dart';
import 'transaction.dart';
import 'fund.dart';
import 'accountType.dart';


// abstract class Account

abstract class Account {
    final int accountId;
    final String name;
    final String accountType; 
    final Money balance;


    Account({
        required this.accountId,
        required this.name,
        required this.accountType,
        required this.balance
        });

    bool addTransaction(Transaction transaction);
    bool removeTransaction(Transaction transaction);
    List<Transaction> getTransactions();
    Money getBalance();

}