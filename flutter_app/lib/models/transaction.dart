
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
        required this.transactionType
        });

    bool isIncome() {
        if (this.transactionType == TransactionType.income) {
            return true;
        }
    }
    bool isExpense() {
        if (this.transactionType == TransactionType.expense) {
            return true;
        }
        return false;
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

    Category getCategory() {
        return this.category;
    }

    TransactionType getTransactionType() {
        return this.transactionType;
    }

    @override
    String toString() {
        return 'Transaction{id: $id, userId: $userId, description: 
                            $description, date: $date, amount: $amount, 
                            category: $category, transactionType: $transactionType}';
    }
}