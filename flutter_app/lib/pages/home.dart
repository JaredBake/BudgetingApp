import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'widgets/pieChart.dart';

import 'widgets/bottomNavBar.dart';
import 'widgets/topNavBar.dart';

import '../api/stats_service.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application/models/user.dart';

class Home extends StatefulWidget {
  final User user;
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

                Text(
                  'Assets overview:',
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
      bottomNavigationBar: BottomNavBar(
        onItemTapped: _onItemTapped,
        initialIndex: _selectedIndex,
      ),
    );
  }
}
