class Money {
  final double amount;
  final String currency;

  Money({required this.amount, required this.currency});

  double getAmount() {
    return amount;
  }

  String getCurrency() {
    return currency;
  }

  Money addMoney(Money other) {
    if (currency != other.currency) {
      throw Exception('Cannot add money with different currencies');
    }
    return Money(amount: amount + other.amount, currency: currency);
  }

  Money spendMoney(Money other) {
    if (currency != other.currency) {
      throw Exception('Cannot spend money with different currencies');
    }
    return Money(amount: amount - other.amount, currency: currency);
  }

  @override
  String toString() => '$currency $amount';
}
