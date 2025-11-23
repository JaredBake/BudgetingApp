import 'package:flutter/material.dart';
import 'package:flutter_application/models/user.dart';

class Profile {
  final String newUsername;
  final String newPassword;

  Profile({
     this.newUsername = "",
     this.newPassword = "",
    });

  Profile.custom(this.newUsername, this.newPassword);
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
            'Profile',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Handle username change
            },
            child: Row(
              children: [
                const Icon(Icons.person),
                const SizedBox(width: 8),
                Text('Username: $username'),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle password change
            },
            child: Row(
              children: [
                const Icon(Icons.lock),
                const SizedBox(width: 8),
                const Text('Change Password'),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
