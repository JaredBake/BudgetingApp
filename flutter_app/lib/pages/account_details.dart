import 'package:flutter/material.dart';
import 'package:flutter_application/models/account.dart';
import 'package:flutter_application/models/user.dart';

import '../api/transaction_service.dart';

import '../models/account_model.dart';
import '../models/accountType.dart';
import '../models/transaction.dart';
import '../models/TransactionType.dart';

import 'widgets/topNavBar.dart';
import 'widgets/app_bottom_nav_bar.dart';
import '../api/account_service.dart';

import 'accounts.dart';

class AccountDetailsPage extends StatefulWidget {
  final Account account;
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
  List<Transaction> transactions = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final loadedTransactions = await TransactionService.getUserTransactions();
      final accountId = widget.account.getAccountId();

      final accountTransactions =
          loadedTransactions
              .where((t) => t.getAccountId() == accountId)
              .toList()
            ..sort((a, b) => b.getDate().compareTo(a.getDate()));

      for (var t in accountTransactions) {
        widget.account.addTransaction(t);
      }

      print("Transactions fetched: ${accountTransactions.length}");
      print(
        "Account stored transactions: ${widget.account.getTransactions().length}",
      );

      setState(() {
        transactions = accountTransactions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

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
                    ? (widget.account.getBalance().getAmount() >= 0
                          ? Colors.green
                          : Colors.red)
                    : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void navigateToAccountsPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AccountsPage(user: widget.user)),
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
      case AccountType.cash:
        return Icons.money;
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
      case AccountType.cash:
        return Colors.teal;
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
                    colors: [
                      accountColor.withOpacity(0.1),
                      accountColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: accountColor.withOpacity(0.2),
                      child: Icon(accountIcon, size: 30, color: accountColor),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      balance.toString(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: balance.getAmount() >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
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
                    _buildDetailRow('Account Name', account.name),
                    _buildDetailRow(
                      'Account Type',
                      _getAccountTypeDisplayName(accountType),
                    ),
                    _buildDetailRow('Current Balance', balance.toString()),
                    _buildDetailRow('Currency', balance.getCurrency()),
                    _buildDetailRow('Transactions', '${transactions.length}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              //TODO: EDIT account
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              AccountService.deleteAccount(
                                account.getAccountId(),
                              ).then((success) {
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Account deleted successfully',
                                      ),
                                    ),
                                  );
                                  navigateToAccountsPage();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to delete account'),
                                    ),
                                  );
                                }
                              });
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

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
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
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
