import 'package:flutter/material.dart';
import 'package:flutter_application/models/account.dart';
import 'package:flutter_application/models/user.dart';
import 'package:flutter_application/pages/add_account_bottom_sheet.dart';
import 'package:flutter_application/pages/widgets/home_overview_banner.dart';
import 'package:flutter_application/pages/widgets/profile_widget.dart'; // Add this import

import '../api/account_service.dart';
import '../api/stats_service.dart';
import 'widgets/app_bottom_nav_bar.dart';
import 'widgets/pieChart.dart';
import 'widgets/topNavBar.dart';
import 'accounts.dart';

class HomeOverview {
  final int totalAccounts;
  final double totalBalance;
  final int totalFunds;
  final double totalFundGoalAmount;
  final double totalFundCurrentAmount;
  final double overallFundProgress;
  final Map<String, int> accountsByType;
  final List<Account> accounts;

  HomeOverview({
    required this.totalAccounts,
    required this.totalBalance,
    required this.totalFunds,
    required this.totalFundGoalAmount,
    required this.totalFundCurrentAmount,
    required this.overallFundProgress,
    required this.accountsByType,
    required this.accounts,
  });
}

class Home extends StatefulWidget {
  final User user;
  const Home({super.key, required this.user});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 2;
  late Future<HomeOverview> _overviewFuture;

  @override
  void initState() {
    super.initState();
    final userId = widget.user.getCredentials().getUserId();
    _overviewFuture = _fetchOverview(userId);
  }

  Future<HomeOverview> _fetchOverview(int userId) async {
    final results = await Future.wait([
      StatsService.getUserAccountStats(userId),
      StatsService.getUserFundStats(userId),
      AccountService.getUserAccounts(),
    ]);

    final accountStats = results[0] as Map<String, dynamic>?;
    final fundStats = results[1] as Map<String, dynamic>?;
    final accounts = results[2] as List<Account>;

    if (accountStats == null && fundStats == null) {
      return HomeOverview(
        totalAccounts: 0,
        totalBalance: 0.0,
        totalFunds: 0,
        totalFundGoalAmount: 0.0,
        totalFundCurrentAmount: 0.0,
        overallFundProgress: 0.0,
        accountsByType: {},
        accounts: const [],
      );
    }

    final totalAccounts =
        (accountStats?['totalAccounts'] as num?)?.toInt() ?? 0;
    final totalBalance =
        (accountStats?['totalBalance'] as num?)?.toDouble() ?? 0.0;

    final totalFunds = (fundStats?['totalFunds'] as num?)?.toInt() ?? 0;
    final totalFundGoalAmount =
        (fundStats?['totalGoalAmount'] as num?)?.toDouble() ?? 0.0;
    final totalFundCurrentAmount =
        (fundStats?['totalCurrentAmount'] as num?)?.toDouble() ?? 0.0;
    final overallFundProgress =
        (fundStats?['overallProgressPercentage'] as num?)?.toDouble() ?? 0.0;

    final rawAccountsByType =
        (accountStats?['accountsByType'] ?? {}) as Map<String, dynamic>;
    final accountsByType = rawAccountsByType.map<String, int>(
      (k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0),
    );

    return HomeOverview(
      totalAccounts: totalAccounts,
      totalBalance: totalBalance,
      totalFunds: totalFunds,
      totalFundGoalAmount: totalFundGoalAmount,
      totalFundCurrentAmount: totalFundCurrentAmount,
      overallFundProgress: overallFundProgress,
      accountsByType: accountsByType,
      accounts: accounts,
    );
  }

  Widget _buildLegend(Map<String, double> balances) {
    final palette = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
    ];

    final entries = balances.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entries.asMap().entries.map((mapEntry) {
        final idx = mapEntry.key;
        final entry = mapEntry.value;
        final color = palette[idx % palette.length];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(width: 12, height: 12, color: color),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${entry.key}: \$${entry.value.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Map<String, double> _computeBalancesByAccount(List<Account> accounts) {
    final Map<String, double> sums = {};
    for (final acct in accounts) {
      final key = acct.name;
      final double value = acct.getBalance().getAmount().abs();
      sums[key] = (sums[key] ?? 0.0) + value;
    }
    return sums;
  }

  List<ChartSlice> _createChartSlicesFromBalances(
    Map<String, double> balancesByType,
  ) {
    final palette = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
    ];

    final entries = balancesByType.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return List<ChartSlice>.generate(entries.length, (i) {
      final entry = entries[i];
      final label = entry.key;
      final value = entry.value;
      final color = palette[i % palette.length];
      return ChartSlice(label, value, color);
    });
  }

  @override
  Widget build(BuildContext context) {
    final username = widget.user.getCredentials().getUserName();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: TopNavBar(
          title: 'Home',
          backgroundColor: Colors.green,
          showBackButton: true,
          showProfileButton: true,
          onProfilePressed: () {
            // Navigate to ProfileWidget instead of Profile page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(
                    title: const Text('Profile'),
                    backgroundColor: Colors.grey,
                  ),
                  body: ProfileWidget(
                    user: widget.user,
                  ), // Use ProfileWidget here
                ),
              ),
            );
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black87, Colors.grey.shade900],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  'Welcome Back $username',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                FutureBuilder<HomeOverview>(
                  future: _overviewFuture,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ), // Add const here
                        ),
                      );
                    }
                    if (snap.hasError) {
                      return Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 100,
                                color: Colors.white24,
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'No accounts yet',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Navigate to Accounts to add your first account',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AccountsPage(user: widget.user),
                                    ),
                                  ).then((_) {
                                    // Refresh the overview when returning from accounts page
                                    setState(() {
                                      _overviewFuture = _fetchOverview(
                                        widget.user
                                            .getCredentials()
                                            .getUserId(),
                                      );
                                    });
                                  });
                                },
                                icon: const Icon(Icons.account_balance),
                                label: const Text('Go to Accounts'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final data =
                        snap.data ??
                        HomeOverview(
                          totalAccounts: 0,
                          totalBalance: 0.0,
                          totalFunds: 0,
                          totalFundGoalAmount: 0.0,
                          totalFundCurrentAmount: 0.0,
                          overallFundProgress: 0.0,
                          accountsByType: {},
                          accounts: [],
                        );

                    // Empty state: No accounts
                    if (data.totalAccounts == 0) {
                      return Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                // Add const here
                                Icons.account_balance_wallet_outlined,
                                size: 100,
                                color: Colors.white24,
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                // Add const here
                                'No accounts yet',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                // Add const here
                                'Add your first account to get started',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white54,
                                ),
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final account =
                                      await showModalBottomSheet<Account>(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) =>
                                            AddAccountBottomSheet(
                                              userId: widget.user
                                                  .getCredentials()
                                                  .getUserId(),
                                            ),
                                      );

                                  print(account);
                                  // TODO
                                  // Here if account is not null
                                  // We will add the account to the user data
                                  // Something like: widget.user.getData().addAccount(account);
                                  //  THEN REFRESH THE UI
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add Account'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Has accounts: Show banner and pie chart
                    return Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Overview banner with stats
                          OverviewBanner(data: data),

                          const SizedBox(height: 12),
                          const Text(
                            'Assets overview:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 50),
                          Builder(
                            builder: (context) {
                              final balancesByType = _computeBalancesByAccount(
                                data.accounts,
                              );
                              print('balancesByType: $balancesByType');

                              if (balancesByType.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No balances to show',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                );
                              }

                              return Column(
                                children: [
                                  Center(
                                    child: BudgetPieChart(
                                      slices: _createChartSlicesFromBalances(
                                        balancesByType,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildLegend(balancesByType),
                                ],
                              );
                            },
                          ),

                          const Spacer(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        user: widget.user,
        currentIndex: _selectedIndex,
        // settings: Settings(),
      ),
    );
  }
}
