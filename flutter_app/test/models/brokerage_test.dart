import 'package:flutter_application/models/TransactionType.dart';
import 'package:flutter_application/models/brokerage.dart';
import 'package:flutter_application/models/money.dart';
import 'package:flutter_application/models/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Brokerage brokerageAccount;
  late Transaction validTransaction;
  late Transaction invalidTransaction;
  late Money initialBalance;

  setUp(() {
    // This runs before each test
    initialBalance = Money(amount: 100.0, currency: "USD");
    brokerageAccount = Brokerage(
      accountId: 1,
      name: "Test Brokerage Account",
      balance: initialBalance,
      transactions: [],
    );

    validTransaction = Transaction(
      id: 1,
      accountId: 1,
      date: DateTime.now(),
      money: Money(amount: 50.0, currency: "USD"),
      description: "Valid transaction",
      transactionType: TransactionType.expense,
    );

    invalidTransaction = Transaction(
      id: 2,
      accountId: 1,
      date: DateTime.now(),
      money: Money(amount: 150.0, currency: "USD"),
      description: "Invalid transaction - insufficient funds",
      transactionType: TransactionType.expense,
    );
  });

  group("Add Transaction", () {
    test("Valid addTransaction", () {
      expect(brokerageAccount.addTransaction(validTransaction), true);
      expect(brokerageAccount.getTransactions().length, 1);
      expect(brokerageAccount.getBalance().getAmount(), 50.0); // 100 - 50
    });

    test("Invalid addTransaction with Insufficient Funds", () {
      expect(brokerageAccount.addTransaction(invalidTransaction), false);
      expect(brokerageAccount.getTransactions().length, 0);
      expect(brokerageAccount.getBalance().getAmount(), 100.0); // Balance unchanged
    });
  });

  group("Remove Transaction", () {
    test("Valid removeTransaction", () {
      brokerageAccount.addTransaction(validTransaction);
      expect(brokerageAccount.removeTransaction(validTransaction), true);
      expect(brokerageAccount.getTransactions().length, 0);
      expect(brokerageAccount.getBalance().getAmount(), 100.0); // Balance restored
    });

    test("Invalid removeTransaction - not in list", () {
      brokerageAccount.addTransaction(validTransaction);
      expect(brokerageAccount.removeTransaction(invalidTransaction), false);
      expect(brokerageAccount.getTransactions().length, 1);
      expect(brokerageAccount.getBalance().getAmount(), 50.0); // Balance unchanged
    });
  });
}