// import 'package:flutter/material.dart';
// // import 'package:flutter_application/pages/widgets/bottomNavBar.dart';
// import 'package:flutter_application/pages/widgets/app_bottom_nav_bar.dart'
// import 'package:flutter_test/flutter_test.dart';

// void main() {
//   testWidgets('BottomNavBar shows items, respects initialIndex and calls callback on tap',
//       (WidgetTester tester) async {
//     int tappedIndex = -1;

//     await tester.pumpWidget(MaterialApp(
//       home: Scaffold(
//         bottomNavigationBar: AppBottomNavBar(
//           user: null
//           // initialIndex: 1,
//           // onItemTapped: (index) => tappedIndex = index,
//         ),
//       ),
//     ));

//     // BottomNavigationBar renders
//     final barFinder = find.byType(BottomNavigationBar);
//     expect(barFinder, findsOneWidget);

//     // initialIndex forwarded to BottomNavigationBar
//     final barWidget = tester.widget<BottomNavigationBar>(barFinder);
//     expect(barWidget.currentIndex, equals(1));

//     // Tap the Home icon (index 2)
//     await tester.tap(find.byIcon(Icons.home));
//     await tester.pumpAndSettle();
//     expect(tappedIndex, equals(2));
//     final barAfterHomeTap = tester.widget<BottomNavigationBar>(barFinder);
//     expect(barAfterHomeTap.currentIndex, equals(2));

//     // Tap the Settings icon (index 4)
//     tappedIndex = -1;
//     await tester.tap(find.byIcon(Icons.settings));
//     await tester.pumpAndSettle();
//     expect(tappedIndex, equals(4));
//     final barAfterSettingsTap = tester.widget<BottomNavigationBar>(barFinder);
//     expect(barAfterSettingsTap.currentIndex, equals(4));
//   });
// }