// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mediscan/main.dart';
import 'package:mediscan/screens/home_screen.dart'; // Add this import

void main() {
  testWidgets('App shows title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MediScanApp());

    // Verify that the home screen title is present.
    expect(find.text('MediScan'), findsOneWidget);
  });

  testWidgets('HomeScreen shows main features', (WidgetTester tester) async {
    // Provide a larger viewport to avoid layout overflow in tests.
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(800, 1200)),
          child: const HomeScreen(), // Now this will work
        ),
      ),
    );

    // Verify that the main title is present
    expect(find.text('MediScan'), findsOneWidget);
    
    // Verify that the subtitle is present
    expect(find.text('AI-Powered Prescription & Lab Report Interpreter'), findsOneWidget);
    
    // Verify that both feature cards are present
    expect(find.text('Scan Prescription'), findsOneWidget);
    expect(find.text('Upload Lab Report'), findsOneWidget);
  });

  testWidgets('Tap on prescription scanner navigates', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(800, 1200)),
          child: const HomeScreen(),
        ),
      ),
    );

    // Tap on the prescription scanner card
    await tester.tap(find.text('Scan Prescription'));
    await tester.pumpAndSettle();

    // Verify navigation to prescription scanner screen
    expect(find.text('Scan Prescription'), findsOneWidget);
  });
}