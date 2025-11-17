import 'package:flutter_application/models/fund.dart';
import 'package:flutter_application/models/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Valid creation of Fund", (){
    var fund = Fund(name: 'Test', goalAmount: Money(amount: 2000, currency: 'USD'), currentAmount: Money(amount: 500, currency: 'USD'), targetDate: DateTime(2024, 12, 31));
    expect(fund.name, 'Test');
    expect(fund.goalAmount.amount, 2000);
    expect(fund.currentAmount.amount, 500);
    expect(fund.targetDate, DateTime(2024, 12, 31));
  });
  group("Add to Fund Tests", () {
    test('Valid check adding of money', () {
      // Arrange
      var fund = Fund(name: 'Test Fund', goalAmount: Money(amount: 100, currency: 'USD'), currentAmount: Money(amount: 10, currency: 'USD'), targetDate: DateTime.now());
      // Act
      var total = fund.addMoney(Money(amount: 5, currency: 'USD'));
      // Assert
      expect(total.amount, 15);
    });

    test('Invalid adding of money with different currency', () {
      var fund = Fund(name: 'Test Fund', goalAmount: Money(amount: 100, currency: 'USD'), currentAmount: Money(amount: 10, currency: 'USD'), targetDate: DateTime.now());
      final addedMoney = Money(amount: 5, currency: 'EUR');
      expect(
        () => fund.addMoney(addedMoney),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          'Exception: Cannot add money with different currencies'
        )),
      );
    });
  });

  group("Spend from Fund Tests", () {
    test('Valid check spending of money', () {
      // Arrange
      var fund = Fund(name: 'Test Fund', goalAmount: Money(amount: 100, currency: 'USD'), currentAmount: Money(amount: 10, currency: 'USD'), targetDate: DateTime.now());
      // Act
      var total = fund.spendMoney(Money(amount: 5, currency: 'USD'));
      // Assert
      expect(total.amount, 5);
    });

    test('Invalid spending of money with different currency', () {
      var fund = Fund(name: 'Test Fund', goalAmount: Money(amount: 100, currency: 'USD'), currentAmount: Money(amount: 10, currency: 'USD'), targetDate: DateTime.now());
      final spentMoney = Money(amount: 5, currency: 'EUR');
      expect(
        () => fund.spendMoney(spentMoney),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          'Exception: Cannot spend money with different currencies'
        )),
      );
    });

    test('Invalid spending of more money than available', () {
      var fund = Fund(name: 'Test Fund', goalAmount: Money(amount: 100, currency: 'USD'), currentAmount: Money(amount: 10, currency: 'USD'), targetDate: DateTime.now());
      final spentMoney = Money(amount: 15, currency: 'USD');
      expect(
        () => fund.spendMoney(spentMoney),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          'Exception: Cannot spend more money than is available in the fund'
        )),
      );
    });
  });

  //   test("Invalid creation of Fund", (){
  //   var fund = Fund(name: 'Test', goalAmount: Money(amount: 2000, currency: 'USD'), currentAmount: Money(amount: 500, currency: 'USD'), targetDate: DateTime(2024, 12, 31));
  //   // Expect error response
  // });

  // test("Check Delete Fund", (){
  //   var fund = Fund(name: 'Emergency', goalAmount: Money(amount: 1000, currency: 'USD'), currentAmount: Money(amount: 200, currency: 'USD'), targetDate: DateTime(2024, 6, 30));

  // });



}