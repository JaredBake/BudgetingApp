import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/bottomNavBar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BottomNavBar forwards initialIndex to BottomNavigationBar', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        bottomNavigationBar: BottomNavBar(onItemTapped: (_) {}, initialIndex: 1),
      ),
    ));

    // Find the underlying BottomNavigationBar and verify its currentIndex
    final bottomNavFinder = find.byType(BottomNavigationBar);
    expect(bottomNavFinder, findsOneWidget);

    final bottomNav = tester.widget<BottomNavigationBar>(bottomNavFinder);
    expect(bottomNav.currentIndex, equals(1));
  });
}