// lib/widgets/BottomNavBar.dart
import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final Function(int) onItemTapped;
  final int initialIndex;
  const BottomNavBar({
    super.key,
    required this.onItemTapped,
    this.initialIndex = 0,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onItemTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Accounts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Transactions',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Funds'),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ), // 5th item
      ],
      currentIndex: _selectedIndex,
      unselectedItemColor: Colors.blueGrey,
      selectedItemColor: Colors.orange,
      onTap: _onTap,
    );
  }
}
