import 'package:flutter/material.dart';

class TopNavBar extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final VoidCallback? onBackPressed;
  final VoidCallback? onProfilePressed;
  final bool showBackButton;
  final bool showProfileButton;

  const TopNavBar({
    super.key,
    required this.title,
    this.backgroundColor = Colors.green,
    this.onBackPressed,
    this.onProfilePressed,
    this.showBackButton = true,
    this.showProfileButton = false,
  });

  

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 4,
        right: 4,
        bottom: 12,
      ),
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              tooltip: 'Back',
            ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.15,
              ),
            ),
          ),
          if (showProfileButton)
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: onProfilePressed ?? () {
                Navigator.pushNamed(context, '/profile');
              },
              tooltip: 'Profile',
            ),
        ],
      ),
    );
  }
}
