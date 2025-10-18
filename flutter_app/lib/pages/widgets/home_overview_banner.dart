import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:http/http.dart' as http;

import 'package:flutter_application/models/user.dart';

import 'package:flutter_application/pages/home.dart';

class OverviewBanner extends StatelessWidget {
  final HomeOverview data;
  const OverviewBanner({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final style = const TextStyle(fontSize: 16, color: Colors.white70);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 12, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: data.totalAccounts == 0
          ? Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white70),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "You don’t have any Data yet, add your first Account.",
                    style: style,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: navigate to Add Account
                  },
                  child: const Text("Add Account"),
                ),
              ],
            )
          : Text(
              "You have ${data.totalAccounts} account${data.totalAccounts == 1 ? '' : 's'} totaling \$${data.totalBalance.toStringAsFixed(2)}.",
              style: style,
            ),
    );
  }
}
