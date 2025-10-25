import 'account.dart';
import 'accountType.dart';
import 'money.dart';
import 'transaction.dart';

import 'savings.dart';
import 'checking.dart';
import 'cash.dart';
import 'credit_card.dart';
import 'brokerage.dart';

class AccountFactory {
  static Account create(
    AccountType type, {
    required int accountId,
    required String name,
    required Money balance,
    List<Transaction>? transactions,
    Map<String, dynamic>? extra,
  }) {
    final t = transactions ?? <Transaction>[];

    switch (type) {
      case AccountType.savings:
        return Savings(
          accountId: accountId,
          name: name,
          balance: balance,
          transactions: t,
        );

      case AccountType.checking:
        return Checking(
          accountId: accountId,
          name: name,
          balance: balance,
          transactions: t,
        );

      case AccountType.cash:
        return Cash(
          accountId: accountId,
          name: name,
          balance: balance,
          transactions: t,
        );

      case AccountType.creditCard:
        return CreditCard(
          accountId: accountId,
          name: name,
          balance: balance,
          transactions: t,
        );
      case AccountType.brokerage:
        return Brokerage(
          accountId: accountId,
          name: name,
          balance: balance,
          transactions: t,
        );
    }
  }
}
