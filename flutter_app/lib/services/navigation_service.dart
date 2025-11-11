import 'package:flutter/material.dart';
import 'package:flutter_application/models/user.dart';

class NavigationService {
  static void navigateToTab(BuildContext context, int index, User user) {
    switch (index) {
      case 0: // Accounts
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/accounts', 
          (route) => false,
          arguments: user,
        );
      case 1: // Transactions
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/transactions', 
          (route) => false,
          arguments: user,
        );
      case 2: // Home
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/home', 
          (route) => false,
          arguments: user,
        );
      case 3: // Funds
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/funds', 
          (route) => false,
          arguments: user,
        );
      case 4: // Settings
        // TODO: Navigate to settings page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings page coming soon!')),
        );
    }
  }

  static String getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Accounts';
      case 1:
        return 'Transactions';
      case 2:
        return 'Home';
      case 3:
        return 'Funds';
      case 4:
        return 'Settings';
      default:
        return 'Budgeting App';
    }
  }

  static int getCurrentPageIndex(String routeName) {
    switch (routeName) {
      case '/accounts':
        return 0;
      case '/transactions':
        return 1;
      case '/home':
        return 2;
      case '/funds':
        return 3;
      case '/settings':
        return 4;
      default:
        return 2; // Default to home
    }
  }
}