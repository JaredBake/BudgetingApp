enum TransactionType {
  income,
  expense;

  bool isExpense() => this == TransactionType.expense;
  bool isIncome() => this == TransactionType.income;
}
