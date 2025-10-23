import 'package:flutter/material.dart';
import 'package:flutter_application/models/user.dart';
import '../../services/navigation_service.dart';

class AppBottomNavBar extends StatefulWidget {
  final User user;
  final int currentIndex;

  const AppBottomNavBar({
    super.key,
    required this.user,
    this.currentIndex = 2,
  });

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(AppBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      setState(() {
        _selectedIndex = widget.currentIndex;
      });
    }
  }

  void _onTap(int index) {
    if (index == _selectedIndex) {
      // Already on this page, don't navigate
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
    
    NavigationService.navigateToTab(context, index, widget.user);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Accounts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Transactions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home), 
          label: 'Home'
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pie_chart), 
          label: 'Funds'
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      currentIndex: _selectedIndex,
      unselectedItemColor: const Color(0xFF26A69A),
      selectedItemColor: Colors.orange,
      onTap: _onTap,
    );
  }
}