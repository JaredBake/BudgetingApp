import 'money.dart';


class Fund {
    String name;
    Money goalAmount;
    Money currentAmount;
    DateTime targetDate;

    Fund({
        required this.name, 
        required this.goalAmount, 
        required this.currentAmount, 
        required this.targetDate
        });

    Money addMoney(Money amount) {
        /*  Adds money to the current amount of the fund
        *   Throws an exception if the currencies do not match
        */  
        if (amount.getCurrency() != this.currentAmount.getCurrency()) {
            throw Exception('Cannot add money with different currencies');
        }

        // Instead of modifying the existing Money object, a new one is created and returned
        currentAmount = Money(
        amount: currentAmount.amount + amount.amount,
        currency: currentAmount.currency,
        );

        return currentAmount;
    }

    Money spendMoney(Money amount) {

        /*  Spends money from the current amount of the fund
        *   Throws an exception if the currencies do not match
        */
        if (amount.getCurrency() != this.currentAmount.getCurrency()) {
            throw Exception('Cannot spend money with different currencies');
        }

        if (amount.getAmount() > this.currentAmount.getAmount()) {
            throw Exception('Cannot spend more money than is available in the fund');
        }

        // Instead of modifying the existing Money object, a new one is created and returned

        currentAmount = Money(
        amount: currentAmount.amount - amount.amount,
        currency: currentAmount.currency,
        );

        return currentAmount;
    }

}