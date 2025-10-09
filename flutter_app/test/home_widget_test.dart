import 'package:flutter/material.dart';
import 'package:flutter_app/pages/home.dart';
import 'package:flutter_app/widgets/pieChart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home shows welcome name, center message and pie chart', (WidgetTester tester) async {
    final user = {'userName': 'Alice'};

    await tester.pumpWidget(MaterialApp(
      home: Home(user: user),
    ));

    // Welcome text
    expect(find.text('Welcome Back Alice'), findsOneWidget);

    // The message that corresponds to initialIndex = 2
    expect(find.text('Welcome to Home!'), findsOneWidget);

    // BudgetPieChart should be present
    expect(find.byType(BudgetPieChart), findsOneWidget);
  });
}