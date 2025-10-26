import 'package:flutter/material.dart';
import 'widgets/app_bottom_nav_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application/models/account.dart';
import 'widgets/pieChart.dart';

import 'widgets/bottomNavBar.dart';
import 'widgets/topNavBar.dart';

import '../api/stats_service.dart';

import 'package:flutter_application/models/user.dart';
import 'package:flutter_application/models/credentials.dart';
import 'package:flutter_application/pages/widgets/home_overview_banner.dart';
import 'package:flutter_application/pages/add_account_bottom_sheet.dart';
import 'package:flutter_application/models/account.dart';
import 'package:flutter_application/models/accountType.dart';

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
    ]);

    final accountStats = results[0] as Map<String, dynamic>?;
    final fundStats = results[1] as Map<String, dynamic>?;

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
      accounts: const [],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Color _getColorForAccountType(AccountType type) {
    switch (type) {
      case AccountType.savings:
        return Colors.blue;
      case AccountType.checking:
        return Colors.green;
      case AccountType.cash:
        return Colors.orange;
      case AccountType.creditCard:
        return Colors.red;
      case AccountType.brokerage:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  List<ChartSlice> _createChartSlices(Map<String, int> accountsByType) {
    return accountsByType.entries.map((entry) {
      return ChartSlice(
        entry.key,
        entry.value.toDouble(), // Use the count as the value
        _getColorForAccountType(_stringToAccountType(entry.key)),
      );
    }).toList();
  }

  AccountType _stringToAccountType(String type) {
    try {
      return AccountType.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == type.toLowerCase(),
        orElse: () => AccountType.cash, // Fallback to cash for unknown types
      );
    } catch (e) {
      return AccountType.cash;
    }
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
                      return Expanded(
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    if (snap.hasError) {
                      return Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 60,
                                color: Colors.white38,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Couldn't load your data${snap.error}",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _overviewFuture = _fetchOverview(
                                      widget.user.getCredentials().getUserId(),
                                    );
                                  });
                                },
                                child: Text('Tap to retry'),
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
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 100,
                                color: Colors.white24,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'No accounts yet',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
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
                          Center(
                            child: BudgetPieChart(
                              slices: _createChartSlices(data.accountsByType),
                            ),
                          ),
                          const Spacer(),
                          Center(),
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
      ),
    );
  }
}
