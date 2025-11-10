import 'package:flutter/material.dart';
import 'package:flutter_application/models/user.dart';
import '../api/transaction_service.dart';
import '../models/transaction.dart';
import '../models/TransactionType.dart';
import 'transaction_details.dart';
import 'create_transaction.dart';
import 'widgets/topNavBar.dart';
import 'widgets/app_bottom_nav_bar.dart';

class TransactionsPage extends StatefulWidget {
  final User user;

  const TransactionsPage({super.key, required this.user});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  List<Transaction>? transactions;
  bool isLoading = true;
  String? errorMessage;
  int _selectedIndex = 1; // Transactions tab

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

      setState(() {
        transactions = loadedTransactions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _navigateToTransactionDetails(Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TransactionDetailsPage(transaction: transaction, user: widget.user),
      ),
    );
  }

  void _navigateToCreateTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTransactionPage(
          user: widget.user,
          onTransactionCreated: _loadTransactions,
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isIncome = transaction.isIncome();
    final color = isIncome ? Colors.green : Colors.red;
    final icon = isIncome ? Icons.arrow_upward : Icons.arrow_downward;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          transaction.getDescription(),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${transaction.getDate().day}/${transaction.getDate().month}/${transaction.getDate().year}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}${transaction.getMoney().toString()}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: () => _navigateToTransactionDetails(transaction),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: TopNavBar(
          title: 'Transactions',
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
                  'Recent Transactions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadTransactions,
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
                          'Error loading transactions',
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
                          onPressed: _loadTransactions,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : transactions == null || transactions!.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your transactions will appear here',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadTransactions,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: transactions!.length,
                      itemBuilder: (context, index) {
                        return _buildTransactionItem(transactions![index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateTransaction,
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
