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

    abstract bool addTransaction(Transaction transaction);
    abstract bool removeTransaction(Transaction transaction);
    abstract List<Transaction> getTransactions();
    abstract Money getBalance();

}