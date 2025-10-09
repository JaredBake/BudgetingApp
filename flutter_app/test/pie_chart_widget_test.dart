import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/pieChart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BudgetPieChart builds a fl_chart.PieChart', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: BudgetPieChart())));

    // Verify a PieChart from fl_chart is present
    expect(find.byType(PieChart), findsOneWidget);
  });
}