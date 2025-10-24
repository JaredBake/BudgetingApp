import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/pages/widgets/pieChart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  testWidgets('BudgetPieChart builds and contains a PieChart', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: BudgetPieChart(),
      ),
    ));

    // BudgetPieChart widget exists
    expect(find.byType(BudgetPieChart), findsOneWidget);

    // Underlying fl_chart PieChart is present
    expect(find.byType(PieChart), findsOneWidget);

    // The PieChart is constrained by the SizedBox height (220)
    final sizedBoxFinder = find.byWidgetPredicate(
      (widget) => widget is SizedBox && widget.height == 220,
    );
    expect(sizedBoxFinder, findsOneWidget);
  });
}