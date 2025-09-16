class Money {
  final double amount;
  final String currency;

  Money({required this.amount, required this.currency});

  Money addMoney(Money other) {
    if (this.currency != other.currency) {
      throw Exception('Cannot add money with different currencies');
    }
    return Money(amount: this.amount + other.amount, currency: this.currency);
  }

    Money spendMoney() {
        return Money(amount: this.amount - 10, currency: this.currency);
    }

  @override
  String toString() => '$currency $amount';

}