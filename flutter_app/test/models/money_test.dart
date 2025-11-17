import 'package:flutter_application/models/money.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {

group('Money Tests', () {
    test('Valid creation of Money object', () {
      final money = Money(amount: 100.0, currency: 'USD');
      
      expect(money.getAmount(), 100.0);
      expect(money.getCurrency(), 'USD');
    });

    // test('Invalid creation of Money', () {
    //   expect(
    //     () => Money(amount: -100.0, currency: 'USD'),
    //     throwsA(isA<ArgumentError>().having(
    //       (e) => e.message,
    //       'message',
    //       'Invalid Input'
    //     )),
    //   );

    //   expect(
    //     () => Money(amount: 100.0, currency: ''),
    //     throwsA(isA<ArgumentError>().having(
    //       (e) => e.message,
    //       'message',
    //       'Invalid Input'
    //     )),
    //   );
    // });

    test('Valid addMoney', () {
      final money = Money(amount: 100.0, currency: 'USD');
      final addedMoney = Money(amount: 50.0, currency: 'USD');

      final finalMoney = money.addMoney(addedMoney);

      expect(finalMoney.getAmount(), 150.0);
      expect(finalMoney.getCurrency(), 'USD');
    });

    test('Invalid addMoney - different currency', () {
      final money = Money(amount: 100.0, currency: 'USD');
      final addedMoney = Money(amount: 50.0, currency: 'EUR');

      expect(
        () => money.addMoney(addedMoney),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          'Exception: Cannot add money with different currencies'
        )),
      );

    });

    test('Valid spendMoney', () {
      final money = Money(amount: 100.0, currency: 'USD');
      final spentMoney = Money(amount: 50.0, currency: 'USD');

      final finalMoney = money.spendMoney(spentMoney);

      expect(finalMoney.getAmount(), 50.0);
      expect(finalMoney.getCurrency(), 'USD');
    });


    test('Invalid spendMoney - different currency', () {
      final money = Money(amount: 100.0, currency: 'USD');
      final spentMoney = Money(amount: 50.0, currency: 'EUR');

      expect(
        () => money.spendMoney(spentMoney),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          'Exception: Cannot spend money with different currencies'
        )),
      );
    });
  });
}