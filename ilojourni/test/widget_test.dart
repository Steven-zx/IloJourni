// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ilojourni/main.dart';
import 'package:ilojourni/screens/profile_guest_screen.dart';
import 'package:ilojourni/screens/profile_signed_screen.dart';

void main() {
  testWidgets('App loads and shows welcome screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that the welcome screen loads with the app name
    expect(find.text('IloJourni'), findsOneWidget);
    expect(find.text('Journeys Made\nEffortless'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('Navigation to sign up screen works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Tap the Get Started button
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Verify that we navigated to the sign up screen
    expect(find.text('Welcome to IloJourni!'), findsOneWidget);
    expect(find.text('Sign up'), findsAtLeastNWidgets(1));
  });

  testWidgets('TextField widgets are properly constrained', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Navigate to sign up screen
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Verify that TextFields render without layout errors
    expect(find.byType(TextField), findsAtLeastNWidgets(3)); // Name, Email, Password
    
    // This test will fail if there are layout constraint errors
    expect(tester.takeException(), isNull);
  });

  testWidgets('Profile guest screen renders without layout errors', (WidgetTester tester) async {
    // Build the profile guest screen directly
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileGuestScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify the screen renders
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Guest User'), findsOneWidget);
    expect(find.text('Sign in to save your trips across devices'), findsOneWidget);
    expect(find.text('Dark mode'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
    
    // Verify no layout exceptions occurred
    expect(tester.takeException(), isNull);
  });

  testWidgets('Profile signed screen renders without layout errors', (WidgetTester tester) async {
    // Build the profile signed screen directly
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileSignedScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify the screen renders
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Philip Hamilton'), findsOneWidget);
    expect(find.text('Travel Stats'), findsOneWidget);
    expect(find.text('My Journeys'), findsOneWidget);
    
    // Verify no layout exceptions occurred
    expect(tester.takeException(), isNull);
  });
}
