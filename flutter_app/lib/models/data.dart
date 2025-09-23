class Data {
    List<Fund> funds;
    List<Account> accounts;

    Data({
        required this.funds, 
        required this.accounts
        });

    List<Fund> getAccounts() {
        return this.accounts;
    }


    List<Fund> getFunds() {
        return this.funds;
    }

}