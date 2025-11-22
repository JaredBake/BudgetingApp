import 'package:flutter/material.dart';
import 'package:flutter_application/models/user.dart';

class Profile {
  final bool isDarkMode;
  final String selectedCurrency;

  Profile({
     this.isDarkMode = false,
     this.selectedCurrency = "USD",
    });

  Profile.custom(this.isDarkMode, this.selectedCurrency);
}

class ProfileWidget extends StatelessWidget {
  final User user;
  
  const ProfileWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final username = user.getCredentials().getUserName();
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Settings',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Username'),
            subtitle: Text(username),
          ),
          const ListTile(
            leading: Icon(Icons.email),
            title: Text('Email'),
            subtitle: Text('user@example.com'), // You can get this from user object if available
          ),
          const SizedBox(height: 20),
          const Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: false, // You can bind this to actual settings
            onChanged: (value) {
              // Handle dark mode toggle
            },
          ),
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: const Text('Currency'),
            subtitle: const Text('USD'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Handle currency selection
            },
          ),
        ],
      ),
    );
  }
}
