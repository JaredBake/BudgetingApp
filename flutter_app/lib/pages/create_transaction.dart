import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/models/user.dart';
import '../api/transaction_service.dart';
import '../api/category_service.dart';
import '../api/fund_service.dart';
import '../models/TransactionType.dart';
import 'widgets/topNavBar.dart';
import 'widgets/app_bottom_nav_bar.dart';

class CreateTransactionPage extends StatefulWidget {
  final User user;
  final VoidCallback? onTransactionCreated;

  const CreateTransactionPage({
    super.key,
    required this.user,
    this.onTransactionCreated,
  });

  @override
  State<CreateTransactionPage> createState() => _CreateTransactionPageState();
}

class _CreateTransactionPageState extends State<CreateTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  List<Map<String, dynamic>> _accounts = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _funds = [];
  
  int? _selectedAccountId;
  int? _selectedCategoryId;
  int? _selectedFundId;
  TransactionType _selectedTransactionType = TransactionType.expense;
  
  bool _isLoading = false;
  bool _isLoadingAccounts = true;
  bool _isLoadingCategories = true;
  bool _isLoadingFunds = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
    _loadCategories();
    _loadFunds();
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
        if (accounts.isNotEmpty) {
          _selectedAccountId = accounts.first['id'];
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingAccounts = false;
      });
    }
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoadingCategories = true;
      });

      final categories = await CategoryService.getUserCategories();
      
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadFunds() async {
    try {
      setState(() {
        _isLoadingFunds = true;
      });

      final funds = await FundService.getUserFunds();
      
      setState(() {
        _funds = funds;
        _isLoadingFunds = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingFunds = false;
      });
    }
  }

  Future<void> _showCreateCategoryDialog() async {
    final nameController = TextEditingController();
    
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Category'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              hintText: 'e.g., Groceries, Rent, etc.',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  return;
                }
                
                try {
                  final newCategory = await CategoryService.createCategory(name: name);
                  setState(() {
                    _categories.add(newCategory);
                    _selectedCategoryId = newCategory['id'];
                  });
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Category "$name" created successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createTransaction() async {
    if (!_formKey.currentState!.validate() || _selectedAccountId == null) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final amount = double.parse(_amountController.text);
      
      // Validate positive amount
      if (amount <= 0) {
        setState(() {
          _errorMessage = 'Amount must be greater than zero';
          _isLoading = false;
        });
        return;
      }
      
      await TransactionService.createTransaction(
        accountId: _selectedAccountId!,
        amount: amount,
        type: _selectedTransactionType,
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategoryId,
        fundId: _selectedFundId,
      );

      // Call callback to refresh the transactions list
      widget.onTransactionCreated?.call();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction created successfully!'),
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

  String _getAccountDisplayName(Map<String, dynamic> account) {
    final name = account['name'] ?? 'Account ${account['id']}';
    final balance = account['balance']?['amount']?.toString() ?? '0';
    final currency = account['balance']?['currency'] ?? 'USD';
    return '$name ($currency $balance)';
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: TopNavBar(
          title: 'Create Transaction',
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
                        'You need at least one account to create a transaction',
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
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<int>(
                                  initialValue: _selectedAccountId,
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
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Transaction Type
                                DropdownButtonFormField<TransactionType>(
                                  initialValue: _selectedTransactionType,
                                  decoration: const InputDecoration(
                                    labelText: 'Type',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.swap_vert),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: TransactionType.expense,
                                      child: Text('Expense'),
                                    ),
                                    DropdownMenuItem(
                                      value: TransactionType.income,
                                      child: Text('Income'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedTransactionType = value;
                                      });
                                    }
                                  },
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
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter an amount';
                                    }
                                    final amount = double.tryParse(value);
                                    if (amount == null) {
                                      return 'Please enter a valid number';
                                    }
                                    if (amount <= 0) {
                                      return 'Amount must be greater than 0';
                                    }
                                    return null;
                                  },
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Category Selection
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<int?>(
                                        initialValue: _selectedCategoryId,
                                        decoration: const InputDecoration(
                                          labelText: 'Category (Optional)',
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.category),
                                        ),
                                        items: [
                                          const DropdownMenuItem<int?>(
                                            value: null,
                                            child: Text('No Category'),
                                          ),
                                          ..._categories.map((category) {
                                            return DropdownMenuItem<int?>(
                                              value: category['id'],
                                              child: Text(category['name']),
                                            );
                                          }),
                                        ],
                                        onChanged: _isLoadingCategories ? null : (value) {
                                          setState(() {
                                            _selectedCategoryId = value;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: _showCreateCategoryDialog,
                                      icon: const Icon(Icons.add_circle),
                                      tooltip: 'Create New Category',
                                      color: Colors.green,
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Fund Selection
                                DropdownButtonFormField<int?>(
                                  initialValue: _selectedFundId,
                                  decoration: const InputDecoration(
                                    labelText: 'Fund (Optional)',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.savings),
                                  ),
                                  items: [
                                    const DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text('No Fund'),
                                    ),
                                    ..._funds.map((fund) {
                                      return DropdownMenuItem<int?>(
                                        value: fund['id'],
                                        child: Text(fund['description']),
                                      );
                                    }),
                                  ],
                                  onChanged: _isLoadingFunds ? null : (value) {
                                    setState(() {
                                      _selectedFundId = value;
                                    });
                                  },
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
                            onPressed: _isLoading ? null : _createTransaction,
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
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Create Transaction',
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