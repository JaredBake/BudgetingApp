import 'package:flutter/material.dart';
import 'package:flutter_application/models/user.dart';
import 'package:flutter_application/pages/login.dart';
import '../../services/navigation_service.dart';
import './settings_widget.dart';
import 'package:file_picker/file_picker.dart';

import '../../api/user_service.dart';

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
  final TextEditingController passwordUpdaterController = TextEditingController();

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

  void _changePassword(String password) async {
    if (password.isEmpty){
      print('Password field is empty, ignoring');
      return;
    };

    await UserService.changePassword(password);
    print('Updated password to $password');
  }

  Future<bool> _deleteUser() async {
    print('Deleting user!');
    return await UserService.deleteUser();
  }

  Future<String> _pickAndUploadFile(String filterDecision) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;

      return file.name;
    }

    return '';
  }

  

  void _showUploadDialog(BuildContext context) {
  String filterDecision = 'Account';
  final TextEditingController uploadText = TextEditingController();
  
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              title: const Text(
                'Upload File',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Select file type',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: filterDecision,
                          isExpanded: true,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down),
                          items: const [
                            DropdownMenuItem(
                              value: 'Account',
                              child: Text('Accounts'),
                            ),
                            DropdownMenuItem(
                              value: 'Transaction',
                              child: Text('Transactions'),
                            ),
                            DropdownMenuItem(
                              value: 'Fund',
                              child: Text('Funds'),
                            ),
                          ],
                          onChanged: (String? value) {
                            if (value != null) {
                              setState(() {
                                filterDecision = value;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          String value = 'File Uploaded: ${await _pickAndUploadFile(filterDecision)}';
                          setState(() {
                            print(value);
                            uploadText.text += '${uploadText.text.isEmpty ? '' : '\n'}$value';
                          });
                        },
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Select File'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      if (uploadText.text.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Uploaded files:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                uploadText.text,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Submit'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showUserSettingsDialog(BuildContext context) {
    bool obscureText = true;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              title: const Text(
                'User Settings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        obscureText: obscureText,
                        controller: passwordUpdaterController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          labelText: 'Enter new password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureText ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureText = !obscureText;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () {
                          _changePassword(passwordUpdaterController.text);
                          Navigator.of(context).pop(true);
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Save Password'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showSettingsDialog(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Go Back...'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      const Text(
                        'Warning!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This action cannot be undone. Your account and all data will be permanently deleted.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          // Show confirmation dialog
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                title: const Text('Confirm Account Deletion'),
                                content: const Text(
                                  'Are you sure you want to delete your account? This action cannot be undone.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () async => {
                                      if (await _deleteUser()){
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(builder: (_) => Login())
                                        )
                                      }
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('Delete Account'),
                                  ),
                                ],
                              );
                            },
                          );
                          
                          if (confirmed == true) {
                            if (await _deleteUser()) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => Login()),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.delete_forever),
                        label: const Text('Delete Account'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              title: const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // User Settings Section
                      const Text(
                        'Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showUserSettingsDialog(context);
                        },
                        icon: const Icon(Icons.person_outline),
                        label: const Text('Change User Settings'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 16),
                      
                      // Appearance Section
                      const Text(
                        'Appearance',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SwitchListTile(
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 16),
                      
                      // Currency Section
                      const Text(
                        'Default Currency',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: tempCurrency,
                          isExpanded: true,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down),
                          items: const [
                            DropdownMenuItem(
                              value: 'USD',
                              child: Row(
                                children: [
                                  Icon(Icons.attach_money, size: 20),
                                  SizedBox(width: 8),
                                  Text('USD - US Dollar'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'EUR',
                              child: Row(
                                children: [
                                  Icon(Icons.euro, size: 20),
                                  SizedBox(width: 8),
                                  Text('EUR - Euro'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'GBP',
                              child: Row(
                                children: [
                                  Icon(Icons.currency_pound, size: 20),
                                  SizedBox(width: 8),
                                  Text('GBP - British Pound'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'JPY',
                              child: Row(
                                children: [
                                  Icon(Icons.currency_yen, size: 20),
                                  SizedBox(width: 8),
                                  Text('JPY - Japanese Yen'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'CAD',
                              child: Row(
                                children: [
                                  Icon(Icons.attach_money, size: 20),
                                  SizedBox(width: 8),
                                  Text('CAD - Canadian Dollar'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'AUD',
                              child: Row(
                                children: [
                                  Icon(Icons.attach_money, size: 20),
                                  SizedBox(width: 8),
                                  Text('AUD - Australian Dollar'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (String? value) {
                            if (value != null) {
                              setState(() {
                                tempCurrency = value;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 16),
                      
                      // Data Management Section
                      const Text(
                        'Data Management',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showUploadDialog(context);
                        },
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Import Data File'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    onSettingsChanged(Settings.custom(tempDarkMode, tempCurrency));
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Save'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}