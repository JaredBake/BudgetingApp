import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  final Map<String, dynamic> user;
  const Home({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final username =
        (user['userName'] ??
                user['username'] ??
                user['Credentials']?['UserName'] ??
                user['credentials']?['userName'] ??
                user['name'])
            ?.toString() ??
        'Guest';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pop(context);
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black87, Colors.grey.shade900],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Budgeting Application CS4400 X01 — $username',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  childAspectRatio: 2.0,
                  children: [
                    _buildDashboardCard(
                      context,
                      icon: Icons.account_balance_wallet,
                      title: 'Accounts',
                      color: Colors.blue,
                      onTap: () {},
                    ),
                    _buildDashboardCard(
                      context,
                      icon: Icons.receipt_long,
                      title: 'Transactions',
                      color: Colors.green,
                      onTap: () {},
                    ),
                    _buildDashboardCard(
                      context,
                      icon: Icons.pie_chart,
                      title: 'Funds',
                      color: Colors.orange,
                      onTap: () {},
                    ),
                    _buildDashboardCard(
                      context,
                      icon: Icons.settings,
                      title: 'Settings',
                      color: Colors.purple,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.black87,
        padding: const EdgeInsets.all(16),
        child: const Text(
          '© 2025 CS4400 Budget App.\n Caleb Terry, Shawn Crook, Jared Blake, Santos Laprida',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      color: Colors.grey.shade800,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
