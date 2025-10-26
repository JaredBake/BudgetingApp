import 'package:flutter_application/models/TransactionType.dart';
import 'package:flutter_application/models/cash.dart';
import 'package:flutter_application/models/money.dart';
import 'package:flutter_application/models/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Cash cashAccount;
  late Transaction validTransaction;
  late Transaction invalidTransaction;
  late Money initialBalance;

  setUp(() {
    // This runs before each test
    initialBalance = Money(amount: 100.0, currency: "USD");
    cashAccount = Cash(
      accountId: 1,
      name: "Test Cash Account",
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
      expect(cashAccount.addTransaction(validTransaction), true);
      expect(cashAccount.getTransactions().length, 1);
      expect(cashAccount.getBalance().getAmount(), 50.0); // 100 - 50
    });

    test("Invalid addTransaction with Insufficient Funds", () {
      expect(cashAccount.addTransaction(invalidTransaction), false);
      expect(cashAccount.getTransactions().length, 0);
      expect(cashAccount.getBalance().getAmount(), 100.0); // Balance unchanged
    });
  });

  group("Remove Transaction", () {
    test("Valid removeTransaction", () {
      cashAccount.addTransaction(validTransaction);
      expect(cashAccount.removeTransaction(validTransaction), true);
      expect(cashAccount.getTransactions().length, 0);
      expect(cashAccount.getBalance().getAmount(), 100.0); // Balance restored
    });

    test("Invalid removeTransaction - not in list", () {
      cashAccount.addTransaction(validTransaction);
      expect(cashAccount.removeTransaction(invalidTransaction), false);
      expect(cashAccount.getTransactions().length, 1);
      expect(cashAccount.getBalance().getAmount(), 50.0); // Balance unchanged
    });
  });
}