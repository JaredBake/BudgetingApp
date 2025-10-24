import 'package:flutter_application/models/fund.dart';
import 'package:flutter_application/models/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

//   void setUp(dynamic Function() body) {
    
// }
  test('Check if adding money correctly', () {
    // Arrange
    var fund = Fund(name: 'Test Fund', goalAmount: Money(amount: 100, currency: 'USD'), currentAmount: Money(amount: 10, currency: 'USD'), targetDate: DateTime.now());
    // Act
    var total = fund.addMoney(Money(amount: 5, currency: 'USD'));
    // Assert
    expect(total.amount, 15);
  });

  test("Check creation of Fund", (){
    var fund = Fund(name: 'Vacation', goalAmount: Money(amount: 2000, currency: 'USD'), currentAmount: Money(amount: 500, currency: 'USD'), targetDate: DateTime(2024, 12, 31));
    expect(fund.name, 'Vacation');
    expect(fund.goalAmount.amount, 2000);
    expect(fund.currentAmount.amount, 500);
    expect(fund.targetDate, DateTime(2024, 12, 31));
  });

  // test("Check Delete Fund", (){
  //   var fund = Fund(name: 'Emergency', goalAmount: Money(amount: 1000, currency: 'USD'), currentAmount: Money(amount: 200, currency: 'USD'), targetDate: DateTime(2024, 6, 30));

  // });
}