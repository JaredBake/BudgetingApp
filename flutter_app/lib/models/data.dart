import 'account.dart';
import 'fund.dart';

class Data {
  List<Fund> funds;
  List<Account> accounts;

  Data({required this.funds, required this.accounts});

  List<Account> getAccounts() {
    return this.accounts;
  }

  List<Fund> getFunds() {
    return this.funds;
  }

  bool addAccount(Account account) {
    if (!accounts.any((a) => a.accountId == account.accountId)) {
      accounts.add(account);
      return true;
    }
    return false;
  }

  Account? findAccount(int accountId) {
    for (Account account in accounts) {
      if (accountId == account.accountId) {
        return account;
      }
    }
    return null;
  }
}
