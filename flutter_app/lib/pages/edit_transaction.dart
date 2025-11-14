import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/models/user.dart';
import '../api/transaction_service.dart';
import 'widgets/topNavBar.dart';

import 'transaction_details.dart';
import 'widgets/app_bottom_nav_bar.dart';

import '../models/money.dart';
import '../models/transaction.dart';
import '../models/TransactionType.dart';
import '../models/account.dart';

class EditTransactionPage extends StatefulWidget {
  final Transaction transaction;
  final User user;
  final VoidCallback? onTransactionUpdated;

  const EditTransactionPage({
    super.key,
    required this.transaction,
    required this.user,
    this.onTransactionUpdated,
  });

  @override
  State<EditTransactionPage> createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late TransactionType _selectedTransactionType;
  late DateTime _selectedDate;

  List<Map<String, dynamic>> _accounts = [];
  int? _selectedAccountId;
  bool _isLoading = false;
  bool _isLoadingAccounts = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Pre-fill form with existing transaction data
    final amount = widget.transaction.getMoney().getAmount().abs();
    _amountController = TextEditingController(text: amount.toStringAsFixed(2));
    _descriptionController = TextEditingController(
      text: widget.transaction.getDescription(),
    );
    _selectedTransactionType = widget.transaction.getTransactionType();
    _selectedDate = widget.transaction.getDate();
    _selectedAccountId = widget.transaction.getAccountId();
    _loadAccounts();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    try {
      setState(() {
        _isLoadingAccounts = true;
        _errorMessage = null;
      });

      final accounts = await TransactionService.getUserAccounts();

      setState(() {
        _accounts = accounts;
        _isLoadingAccounts = false;
        if (_selectedAccountId != null &&
            !accounts.any((a) => a['id'] == _selectedAccountId)) {
          if (accounts.isNotEmpty) {
            _selectedAccountId = accounts.first['id'];
          }
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingAccounts = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
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

  Future<void> _updateTransaction() async {
    if (!_formKey.currentState!.validate() || _selectedAccountId == null) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final amount = double.parse(_amountController.text);

      Money money = Money(amount: amount, currency: 'USD');

      Transaction updatedTransaction = Transaction(
        id: widget.transaction.getId(),
        accountId: _selectedAccountId!,
        date: _selectedDate,
        money: money,
        description: _descriptionController.text.trim(),
        transactionType: _selectedTransactionType,
      );

      await TransactionService.updateTransaction(
        transaction: updatedTransaction,
      );

      widget.onTransactionUpdated?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        //Navigator.pop(context);
        _navigateToTransactionDetails(updatedTransaction);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getAccountDisplayName(Map<String, dynamic> account) {
    final name = account['name'] ?? 'Account ${account['id']}';
    final balance = account['balance']?['amount']?.toString() ?? '0';
    final currency = account['balance']?['currency'] ?? 'USD';
    return '$name ($currency $balance)';
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: TopNavBar(
          title: 'Edit Transaction',
          backgroundColor: Colors.green,
          showBackButton: true,
          showProfileButton: false,
        ),
      ),
      body: _isLoadingAccounts
          ? const Center(child: CircularProgressIndicator())
          : _accounts.isEmpty
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
                    'You need at least one account to edit a transaction',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Account Selection
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Account',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              value: _selectedAccountId,
                              decoration: const InputDecoration(
                                labelText: 'Account',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.account_balance),
                              ),
                              items: _accounts.map((account) {
                                return DropdownMenuItem<int>(
                                  value: account['id'],
                                  child: Text(_getAccountDisplayName(account)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedAccountId = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select an account';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Transaction Details
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transaction Details',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),

                            // Amount
                            TextFormField(
                              controller: _amountController,
                              decoration: const InputDecoration(
                                labelText: 'Amount',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.attach_money),
                                hintText: '0.00',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}'),
                                ),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an amount';
                                }
                                final amount = double.tryParse(value);
                                if (amount == null) {
                                  return 'Please enter a valid number';
                                }
                                if (amount == 0) {
                                  return 'Amount must be greater than 0';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Dropdown for Transaction Type
                            DropdownButtonFormField<TransactionType>(
                              value: _selectedTransactionType,
                              decoration: const InputDecoration(
                                labelText: 'Transaction Type',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.swap_horiz),
                              ),
                              items: TransactionType.values.map((type) {
                                return DropdownMenuItem<TransactionType>(
                                  value: type,
                                  child: Text(
                                    type.isIncome() ? 'Income' : 'Expense',
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _selectedTransactionType = value;
                                });
                              },
                            ),

                            const SizedBox(height: 16),

                            // Date Selection
                            InkWell(
                              onTap: () => _selectDate(context),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_formatDate(_selectedDate)),
                                    const Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Time Selection
                            InkWell(
                              onTap: () => _selectTime(context),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Time',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.access_time),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_formatTime(_selectedDate)),
                                    const Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Description (Optional)
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description (Optional)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.description),
                                hintText: 'What was this transaction for?',
                              ),
                              maxLines: 3,
                              maxLength: 200,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Error Message
                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Update Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Update Transaction',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: AppBottomNavBar(
        user: widget.user,
        currentIndex: 1, // Transactions section
      ),
    );
  }
}
