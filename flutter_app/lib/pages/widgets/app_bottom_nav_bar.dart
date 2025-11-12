import 'package:flutter/material.dart';
import 'package:flutter_application/models/user.dart';
import '../../services/navigation_service.dart';
import './settings_widget.dart';

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
  late Settings _settings;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
    _settings = Settings();
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

  void onSettingsChanged(Settings settings) {
    _settings = settings;
    print("Settings Updated!");
    print("Currency: ${_settings.selectedCurrency}");
    print("DarkMode: ${_settings.isDarkMode}");
  }

  void _onTap(int index) {
    if (index == 4) {
      _showSettingsDialog(context);
    } else {   
      if (index == _selectedIndex) {
        // Already on this page, don't navigate
        return;
      }
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

  void _showSettingsDialog(BuildContext context) {
    bool tempDarkMode = _settings.isDarkMode;
    String tempCurrency = _settings.selectedCurrency;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Settings'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dark/Light Theme Toggle
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: Text(tempDarkMode ? 'Dark theme' : 'Light theme'),
                    value: tempDarkMode,
                    onChanged: (bool value) {
                      setState(() {
                        tempDarkMode = value;
                      });
                    },
                    secondary: Icon(
                      tempDarkMode ? Icons.dark_mode : Icons.light_mode,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Currency Selection
                  ListTile(
                    leading: const Icon(Icons.attach_money),
                    title: const Text('Default Currency'),
                    subtitle: Text(tempCurrency),
                  ),
                  DropdownButton<String>(
                    value: tempCurrency,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'USD', child: Text('USD - US Dollar')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro')),
                      DropdownMenuItem(value: 'GBP', child: Text('GBP - British Pound')),
                      DropdownMenuItem(value: 'JPY', child: Text('JPY - Japanese Yen')),
                      DropdownMenuItem(value: 'CAD', child: Text('CAD - Canadian Dollar')),
                      DropdownMenuItem(value: 'AUD', child: Text('AUD - Australian Dollar')),
                    ],
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          tempCurrency = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    onSettingsChanged(Settings.custom(tempDarkMode, tempCurrency));
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}