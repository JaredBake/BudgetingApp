import 'package:flutter/material.dart';
import 'package:flutter_application/models/user.dart';
import '../models/account_model.dart';
import '../models/accountType.dart';
import 'widgets/topNavBar.dart';
import 'widgets/app_bottom_nav_bar.dart';

class AccountDetailsPage extends StatefulWidget {
  final AccountModel account;
  final User user;

  const AccountDetailsPage({
    super.key,
    required this.account,
    required this.user,
  });

  @override
  State<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {



  Widget _buildDetailRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
                fontSize: highlight ? 18 : 16,
                color: highlight 
                    ? (widget.account.getBalance().getAmount() >= 0 ? Colors.green : Colors.red)
                    : Colors.black87,
              ),
            ),
          ),
        ],
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
    }
  }

  IconData _getAccountIcon(AccountType type) {
    switch (type) {
      case AccountType.checking:
        return Icons.account_balance;
      case AccountType.savings:
        return Icons.savings;
      case AccountType.creditCard:
        return Icons.credit_card;
      case AccountType.brokerage:
        return Icons.trending_up;
    }
  }

  Color _getAccountColor(AccountType type) {
    switch (type) {
      case AccountType.checking:
        return Colors.blue;
      case AccountType.savings:
        return Colors.green;
      case AccountType.creditCard:
        return Colors.orange;
      case AccountType.brokerage:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = widget.account;
    final accountType = account.getAccountType();
    final balance = account.getBalance();
    final accountColor = _getAccountColor(accountType);
    final accountIcon = _getAccountIcon(accountType);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: TopNavBar(
          title: 'Account Details',
          backgroundColor: Colors.green,
          showBackButton: true,
          showProfileButton: true,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account balance card
            Card(
              elevation: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [accountColor.withOpacity(0.1), accountColor.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: accountColor.withOpacity(0.2),
                      child: Icon(
                        accountIcon,
                        size: 30,
                        color: accountColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      balance.toString(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: balance.getAmount() >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: accountColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getAccountTypeDisplayName(accountType),
                        style: TextStyle(
                          color: accountColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Account details card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Account ID', account.getId().toString()),
                    _buildDetailRow('Account Name', account.getName()),
                    _buildDetailRow('Account Type', _getAccountTypeDisplayName(accountType)),
                    _buildDetailRow('Current Balance', balance.toString()),
                    _buildDetailRow('Currency', balance.getCurrency()),
                    _buildDetailRow('Transactions', '${account.getTransactions().length}'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Recent transactions card (if any)
            if (account.getTransactions().isNotEmpty)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Transactions',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to full transactions list for this account
                              Navigator.pushNamed(context, '/transactions');
                            },
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: account.getTransactions().take(5).length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final transaction = account.getTransactions()[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              transaction.isIncome() 
                                  ? Icons.arrow_downward 
                                  : Icons.arrow_upward,
                              color: transaction.isIncome() 
                                  ? Colors.green 
                                  : Colors.red,
                            ),
                            title: Text(transaction.getDescription()),
                            subtitle: Text(
                              '${transaction.getDate().day}/${transaction.getDate().month}/${transaction.getDate().year}',
                            ),
                            trailing: Text(
                              '${transaction.isIncome() ? '+' : '-'}${transaction.getMoney().toString()}',
                              style: TextStyle(
                                color: transaction.isIncome() 
                                    ? Colors.green 
                                    : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        user: widget.user,
        currentIndex: 0, // Accounts section
      ),
    );
  }
}