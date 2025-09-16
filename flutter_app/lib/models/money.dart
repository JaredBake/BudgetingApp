class Money {
  final double amount;
  final String currency;

  Money({required this.amount, required this.currency});

  @override
  String toString() => '$currency $amount';
}