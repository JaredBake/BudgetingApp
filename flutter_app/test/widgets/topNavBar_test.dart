import 'package:flutter/material.dart';
import 'package:flutter_application/pages/widgets/topNavBar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TopNavBar Widget Tests', () {
    testWidgets('TopNavBar renders with default properties', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: TopNavBar(
              title: 'Test Title',
            ),
          ),
        ),
      ));

      // Check title is displayed
      expect(find.text('Test Title'), findsOneWidget);
      
      // Back button should be visible by default
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      
      // Profile button should be hidden by default
      expect(find.byIcon(Icons.person), findsNothing);
    });

    testWidgets('TopNavBar shows/hides buttons correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: TopNavBar(
              title: 'Test',
              showBackButton: false,
              showProfileButton: true,
            ),
          ),
        ),
      ));

      // Back button should be hidden
      expect(find.byIcon(Icons.arrow_back), findsNothing);
      
      // Profile button should be visible
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('TopNavBar back button calls onBackPressed', (WidgetTester tester) async {
      bool wasPressed = false;
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: TopNavBar(
              title: 'Test',
              onBackPressed: () => wasPressed = true,
            ),
          ),
        ),
      ));

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      // Verify callback was called
      expect(wasPressed, true);
    });

    testWidgets('TopNavBar uses correct background color', (WidgetTester tester) async {
      const testColor = Colors.blue;
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: TopNavBar(
              title: 'Test',
              backgroundColor: testColor,
            ),
          ),
        ),
      ));

      // Find Container with specified background color
      final containerFinder = find.byWidgetPredicate(
        (widget) => widget is Container && widget.decoration == null && widget.color == testColor,
      );
      
      expect(containerFinder, findsOneWidget);
    });

  });
}