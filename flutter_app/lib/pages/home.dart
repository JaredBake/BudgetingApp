import 'package:flutter/material.dart';
import 'widgets/app_bottom_nav_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'widgets/pieChart.dart';
import 'widgets/topNavBar.dart';

class Home extends StatefulWidget {
  final Map<String, dynamic> user;
  const Home({super.key, required this.user});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 2;
  final List<String> _messages = [
    'Should navigate to Accounts.',
    'Should navigate to Transactions.',
    'Welcome to Home!',
    'Should navigate to Funds.',
    'Should navigate to Settings.',
  ];

  @override
  Widget build(BuildContext context) {
    final username =
        (widget.user['userName'] ??
                widget.user['username'] ??
                widget.user['Credentials']?['UserName'] ??
                widget.user['credentials']?['userName'] ??
                widget.user['name'])
            ?.toString() ??
        'Guest';

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: TopNavBar(
          title: 'Budgeting App',
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
      bottomNavigationBar: AppBottomNavBar(
        user: widget.user,
        currentIndex: _selectedIndex,
      ),
    );
  }
}
