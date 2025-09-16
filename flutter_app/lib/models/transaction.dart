class Transaction {
    final int id;
    final int userId;
    final String description;
    DateTime date;
    Money amount;
    Category category;
    TransactionType transactionType;

    Transaction({
        required this.id,
        required this.userId,
        required this.description,
        required this.date,
        required this.amount,
        required this.category,
        required this.transactionType,
    });

    bool isIncome() {
        // TODO
        return false;
    }

    bool isExpense() {
        // TODO
        return false;
    }

    String getDescription() {
        return this.description;
    }

    DateTime getDate() {
        return this.date;
    }

    Money getAmount() {
        return this.amount;
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