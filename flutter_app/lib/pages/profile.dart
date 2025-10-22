import 'package:flutter/material.dart';

import 'widgets/bottomNavBar.dart';
import 'widgets/topNavBar.dart';

class Profile extends StatefulWidget {
  final Map<String, dynamic> user;
  const Profile({super.key, required this.user});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
    int _selectedIndex = 4;
    final List<String> _messages = [
        'Should navigate to Accounts.',
        'Should navigate to Transactions.',
        'Should navigate to Home.',
        'Should navigate to Funds.',
        'Welcome to Profile!',
    ];
    
    void _onItemTapped(int index) {
        setState(() {
        _selectedIndex = index;
        });
    }

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
            title: 'Profile',
            backgroundColor: Colors.grey,
            showBackButton: true,
            showProfileButton: false,
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
 