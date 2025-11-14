import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/models/money.dart';
import 'package:flutter_application/models/user.dart';
import '../api/account_service.dart';
import '../models/accountType.dart';
import 'widgets/topNavBar.dart';
import 'widgets/app_bottom_nav_bar.dart';
import 'package:flutter_application/pages/widgets/settings_widget.dart';

import 'package:localstorage/localstorage.dart';
import 'package:flutter_application/models/account.dart';
import 'package:flutter_application/models/account_factory.dart';


class CreateAccountPage extends StatefulWidget {
  final User user;
  final VoidCallback? onAccountCreated;

  const CreateAccountPage({
    super.key,
    required this.user,
    this.onAccountCreated,
  });

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();

  AccountType _selectedAccountType = AccountType.checking;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final balance = double.parse(_balanceController.text);
      final money = Money(amount: balance, currency: 'USD');

      final acc = AccountFactory.create(
        _selectedAccountType,
        accountId: 0,
        name: _nameController.text.trim(),
        balance: money,
        transactions: const [],
      );

      final account = await AccountService.createAccount(acc);

      print(account);

      // Call callback to refresh the accounts list
      widget.onAccountCreated?.call();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
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

  IconData _getAccountTypeIcon(AccountType type) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: TopNavBar(
          title: 'Create Account',
          backgroundColor: Colors.green,
          showBackButton: true,
          showProfileButton: false,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Type Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Type',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ...AccountType.values.map((type) {
                        return RadioListTile<AccountType>(
                          value: type,
                          groupValue: _selectedAccountType,
                          onChanged: (AccountType? value) {
                            setState(() {
                              _selectedAccountType = value!;
                            });
                          },
                          title: Row(
                            children: [
                              Icon(_getAccountTypeIcon(type)),
                              const SizedBox(width: 8),
                              Text(_getAccountTypeDisplayName(type)),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Account Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Details',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Account Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Account Name',
                          hintText: 'e.g., Chase Checking',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.account_balance_wallet),
                          // hintText: 'Enter account name',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an account name';
                          }
                          if (value.trim().length < 2) {
                            return 'Account name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: 'USD', // Hardcode USD as the selected value
                        decoration: const InputDecoration(
                          labelText: 'Currency',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.currency_exchange),
                        ),
                        items: const [
                          DropdownMenuItem<String>(
                            value: 'USD',
                            child: Text('USD'),
                          ),
                        ],
                        onChanged:
                            null, // Disable changes by setting onChanged to null
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please select a currency';
                          }
                          if (value.trim() != 'USD') {
                            return 'Currency must be USD';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Initial Balance
                      TextFormField(
                        controller: _balanceController,
                        decoration: const InputDecoration(
                          labelText: 'Initial Balance',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                          hintText: '0.00',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^-?\d*\.?\d{0,2}'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an initial balance';
                          }
                          final balance = double.tryParse(value);
                          if (balance == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // Helper text for negative balances
                      Text(
                        'Note: Negative balances are allowed for credit cards and overdrafts',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
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

              // Create Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createAccount,
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
                          'Create Account',
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
        currentIndex: 0, // Accounts section
        // settings: Settings(),
      ),
    );
  }
}
