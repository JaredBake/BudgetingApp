import 'package:flutter/material.dart';
import 'package:flutter_application/models/user.dart';
import '../models/transaction.dart';
import '../models/TransactionType.dart';
import 'widgets/topNavBar.dart';
import 'widgets/app_bottom_nav_bar.dart';
import 'package:flutter_application/pages/widgets/settings_widget.dart';

import '../models/account.dart';

import 'transactions.dart';
import 'edit_transaction.dart';

import '../api/transaction_service.dart';

class TransactionDetailsPage extends StatefulWidget {
  final Transaction transaction;
  final User user;

  const TransactionDetailsPage({
    super.key,
    required this.transaction,
    required this.user,
  });

  @override
  State<TransactionDetailsPage> createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {
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
                    ? (widget.transaction.isIncome()
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

  // Widget _buildButtonRow(Widget child) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 8.0),
  //     child: Row(children: [Expanded(child: child)]),
  //   );
  // }

  String getAccountName() {
    Account? account = widget.user.getData().findAccount(
      widget.transaction.getAccountId(),
    );
    return account != null ? account.getDescription() : 'Unknown Account';
  }

  void navigateToTransactionsPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionsPage(user: widget.user),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour == 0
        ? 12
        : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.transaction.isIncome();
    final statusColor = isIncome ? Colors.green : Colors.red;
    final statusIcon = isIncome ? Icons.arrow_upward : Icons.arrow_downward;
    final statusText = isIncome ? 'Income' : 'Expense';

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: TopNavBar(
          title: 'Transaction Details',
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
            // Transaction amount card
            Card(
              elevation: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      statusColor.withOpacity(0.1),
                      statusColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: statusColor.withOpacity(0.2),
                      child: Icon(statusIcon, size: 30, color: statusColor),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${isIncome ? '+' : '-'}${widget.transaction.getMoney().toString()}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Transaction details card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildDetailRow('Account', getAccountName()),

                    _buildDetailRow(
                      'Description',
                      widget.transaction.getDescription(),
                    ),
                    _buildDetailRow(
                      'Date',
                      _formatDate(widget.transaction.getDate()),
                    ),
                    _buildDetailRow(
                      'Time',
                      _formatTime(widget.transaction.getDate()),
                    ),
                    _buildDetailRow(
                      'Currency',
                      widget.transaction.getMoney().getCurrency(),
                    ),
                    _buildDetailRow('Type', statusText),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditTransactionPage(
                                    transaction: widget.transaction,
                                    user: widget.user,
                                    onTransactionUpdated: () {
                                      // Refresh the transaction details by navigating back
                                      // and then to transactions page which will reload
                                      navigateToTransactionsPage();
                                    },
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text("Edit"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              TransactionService.deleteTransaction(
                                widget.transaction.id,
                              ).then((success) {
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Transaction deleted'),
                                    ),
                                  );
                                  navigateToTransactionsPage();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Failed to delete transaction',
                                      ),
                                    ),
                                  );
                                }
                              });
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text("Delete"),
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
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        user: widget.user,
        currentIndex: 1, // Transactions section
        // settings: Settings(),
      ),
    );
  }
}
