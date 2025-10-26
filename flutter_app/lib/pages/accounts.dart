import 'package:flutter/material.dart';
import 'package:flutter_application/models/user.dart';
import '../api/account_service.dart';
import '../models/account_model.dart';
import '../models/account.dart';
import '../models/accountType.dart';
import 'account_details.dart';
import 'create_account.dart';
import 'widgets/topNavBar.dart';
import 'widgets/app_bottom_nav_bar.dart';

class AccountsPage extends StatefulWidget {
  final User user;

  const AccountsPage({super.key, required this.user});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  List<Account>? accounts;
  bool isLoading = true;
  String? errorMessage;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final loadedAccounts = await AccountService.getUserAccounts();

      setState(() {
        accounts = loadedAccounts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _navigateToAccountDetails(Account account) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AccountDetailsPage(account: account, user: widget.user),
      ),
    );
  }

  void _navigateToCreateAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateAccountPage(
          user: widget.user,
          onAccountCreated: _loadAccounts,
        ),
      ),
    );
  }

  Widget _buildAccountItem(Account account) {
    final accountType = account.getAccountType();
    final balance = account.getBalance();

    IconData icon;
    Color color;

    switch (accountType) {
      case AccountType.checking:
        icon = Icons.account_balance;
        color = Colors.blue;
        break;
      case AccountType.savings:
        icon = Icons.savings;
        color = Colors.green;
        break;
      case AccountType.creditCard:
        icon = Icons.credit_card;
        color = Colors.orange;
        break;
      case AccountType.brokerage:
        icon = Icons.trending_up;
        color = Colors.purple;
        break;
      case AccountType.cash:
        icon = Icons.money;
        color = Colors.teal;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          account.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          _getAccountTypeDisplayName(accountType),
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              balance.toString(),
              style: TextStyle(
                color: balance.getAmount() >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              '${account.getTransactions().length} transactions',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        onTap: () => _navigateToAccountDetails(account),
      ),
    );
  }

  String _getAccountTypeDisplayName(AccountType type) {
    switch (type) {
      case AccountType.checking:
        return 'Checking Account';
      case AccountType.savings:
        return 'Savings Account';
      case AccountType.creditCard:
        return 'Credit Card';
      case AccountType.brokerage:
        return 'Brokerage Account';
      case AccountType.cash:
        return 'Cash Account';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: TopNavBar(
          title: 'Accounts',
          backgroundColor: Colors.green,
          showBackButton: true,
          showProfileButton: true,
        ),
      ),
      body: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Accounts',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadAccounts,
                ),
              ],
            ),
          ),

          // Content section
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading accounts',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          errorMessage!,
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadAccounts,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : accounts == null || accounts!.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No accounts found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first account to get started',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _navigateToCreateAccount,
                          icon: const Icon(Icons.add),
                          label: const Text('Create Account'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadAccounts,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: accounts!.length,
                      itemBuilder: (context, index) {
                        return _buildAccountItem(accounts![index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateAccount,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: AppBottomNavBar(
        user: widget.user,
        currentIndex: _selectedIndex,
      ),
    );
  }
}
