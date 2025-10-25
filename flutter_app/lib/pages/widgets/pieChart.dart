// lib/widgets/budget_pie_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartSlice {
  final String label;
  final double value;
  final Color color;
  ChartSlice(this.label, this.value, this.color);
}

class BudgetPieChart extends StatelessWidget {
  final List<ChartSlice> slices;
  final double centerSpace;
  final double radius;

  const BudgetPieChart({
    super.key,
    required this.slices,
    this.centerSpace = 40,
    this.radius = 70,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: centerSpace,
          sections: [
            for (final s in slices)
              PieChartSectionData(
                color: s.color,
                value: s.value,
                title:
                    '', // keep clean; add labels/legend separately if you want
                radius: radius,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
