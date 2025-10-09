import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BudgetPieChart extends StatelessWidget {
  const BudgetPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: _buildSections(),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return [
      PieChartSectionData(
        color: Colors.greenAccent,
        radius: 70,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      PieChartSectionData(
        color: Colors.blueAccent,
        radius: 70,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      PieChartSectionData(
        color: Colors.orangeAccent,
        radius: 70,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      PieChartSectionData(
        color: Colors.purpleAccent,
        radius: 70,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    ];
  }
}
