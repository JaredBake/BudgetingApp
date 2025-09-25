import 'account.dart';
import 'fund.dart';


class Data {
    List<Fund> funds;
    List<Account> accounts;

    Data({
        required this.funds, 
        required this.accounts
        });

    List<Account> getAccounts() {
        return this.accounts;
    }


    List<Fund> getFunds() {
        return this.funds;
    }

}