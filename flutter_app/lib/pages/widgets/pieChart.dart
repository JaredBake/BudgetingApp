// lib/widgets/budget_pie_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartSlice {
  final String label;
  final double value;
  final Color color;
  ChartSlice(this.label, this.value, this.color);
}

class BudgetPieChart extends StatefulWidget {
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
  State<BudgetPieChart> createState() => _BudgetPieChartState();
}

class _BudgetPieChartState extends State<BudgetPieChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: widget.centerSpace,
          sections: _buildSections(),
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  touchedIndex = null;
                  return;
                }
                touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
            enabled: true,
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return List.generate(widget.slices.length, (index) {
      final isTouched = index == touchedIndex;
      final slice = widget.slices[index];
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? widget.radius + 5 : widget.radius;

      return PieChartSectionData(
        color: slice.color,
        value: slice.value,
        title: isTouched
            ? '${slice.label}\n\$${slice.value.toStringAsFixed(2)}'
            : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 4,
            ),
          ],
        ),
      );
    });
  }
}
