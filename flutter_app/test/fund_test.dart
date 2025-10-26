import 'package:flutter_application/models/fund.dart';
import 'package:flutter_application/models/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

//   void setUp(dynamic Function() body) {
    
// }
  test('Valid check adding of money', () {
    // Arrange
    var fund = Fund(name: 'Test Fund', goalAmount: Money(amount: 100, currency: 'USD'), currentAmount: Money(amount: 10, currency: 'USD'), targetDate: DateTime.now());
    // Act
    var total = fund.addMoney(Money(amount: 5, currency: 'USD'));
    // Assert
    expect(total.amount, 15);
  });

  test("Valid creation of Fund", (){
    var fund = Fund(name: 'Test', goalAmount: Money(amount: 2000, currency: 'USD'), currentAmount: Money(amount: 500, currency: 'USD'), targetDate: DateTime(2024, 12, 31));
    expect(fund.name, 'Test');
    expect(fund.goalAmount.amount, 2000);
    expect(fund.currentAmount.amount, 500);
    expect(fund.targetDate, DateTime(2024, 12, 31));
  });

  //   test("Invalid creation of Fund", (){
  //   var fund = Fund(name: 'Test', goalAmount: Money(amount: 2000, currency: 'USD'), currentAmount: Money(amount: 500, currency: 'USD'), targetDate: DateTime(2024, 12, 31));
  //   // Expect error response
  // });

  // test("Check Delete Fund", (){
  //   var fund = Fund(name: 'Emergency', goalAmount: Money(amount: 1000, currency: 'USD'), currentAmount: Money(amount: 200, currency: 'USD'), targetDate: DateTime(2024, 6, 30));

  // });
}