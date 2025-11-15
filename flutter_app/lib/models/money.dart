class Money {
  final double amount;
  final String currency;

  Money({required this.amount, required this.currency});

  double getAmount() {
    return this.amount;
  }

  String getCurrency() {
    return this.currency;
  }

  Money addMoney(Money other) {
    if (currency != other.currency) {
      throw Exception('Cannot add money with different currencies');
    }
    return Money(amount: this.amount + other.amount, currency: this.currency);
  }

  Money spendMoney(Money other) {
    if (currency != other.currency) {
      throw Exception('Cannot spend money with different currencies');
    }
    return Money(amount: this.amount - other.amount, currency: this.currency);
  }

  @override
  String toString() => '$currency $amount';
}
