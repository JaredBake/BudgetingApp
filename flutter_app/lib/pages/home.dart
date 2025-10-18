import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'widgets/pieChart.dart';

import 'widgets/bottomNavBar.dart';
import 'widgets/topNavBar.dart';

import '../api/stats_service.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application/models/user.dart';
import 'package:flutter_application/models/credentials.dart';
import 'package:flutter_application/pages/widgets/home_overview_banner.dart';

class HomeOverview {
  final int totalAccounts;
  final double totalBalance;
  final int totalFunds;

  HomeOverview({
    required this.totalAccounts,
    required this.totalBalance,
    required this.totalFunds,
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
  final List<String> _messages = [
    'Should navigate to Accounts.',
    'Should navigate to Transactions.',
    'Welcome to Home!',
    'Should navigate to Funds.',
    'Should navigate to Settings.',
  ];

  @override
  void initState() {
    super.initState();
    final userId = widget.user.getCredentials().getUserId();
    _overviewFuture = _fetchOverview(userId);
  }

  Future<HomeOverview> _fetchOverview(int userId) async {
    final res = await StatsService.getUserAccountStats(userId);
    if (res == null) {
      return HomeOverview(totalAccounts: 0, totalBalance: 0.0, totalFunds: 0);
    }
    return HomeOverview(
      totalAccounts: (res['totalAccounts'] ?? 0) as int,
      totalBalance: (res['totalBalance'] ?? 0).toDouble(),
      totalFunds: 0, // later: fill from /api/Stats/users/{id}/funds
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // All the user information we are going to need
    // final username = widget.user['credentials']?['userName'] ?? 'Guest';
    // final name = widget.user['credentials']?['name'] ?? 'Guest';
    // final userId = widget.user['id'];
    // final email = widget.user['credentials']?['email'];

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

                Text(
                  'Assets overview:',
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
                      return Container(
                        width: double.infinity,
                        height: 52,
                        margin: const EdgeInsets.only(top: 12, bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    if (snap.hasError) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(top: 12, bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Couldn’t load overview. Tap to retry.",
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }
                    final data =
                        snap.data ??
                        HomeOverview(
                          totalAccounts: 0,
                          totalBalance: 0.0,
                          totalFunds: 0,
                        );
                    return OverviewBanner(data: data);
                  },
                ),

                const SizedBox(height: 12),
                const Text(
                  'Assets overview:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 100),
                const Center(child: BudgetPieChart()),
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    _messages[_selectedIndex],
                    style: const TextStyle(fontSize: 18, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        onItemTapped: _onItemTapped,
        initialIndex: _selectedIndex,
      ),
    );
  }
}
