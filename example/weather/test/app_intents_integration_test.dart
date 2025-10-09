// Weather App Intents integration tests
//
// Tests the integration between the weather app and the flutter_app_intents
// package, including query intent demonstrations, voice-optimized responses,
// and platform-specific behavior handling.

import 'package:flutter/material.dart';
import 'package:flutter_app_intents/flutter_app_intents.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_example/main.dart';

void main() {
  group('Weather App Intents Integration Tests', () {
    testWidgets('App properly integrates with flutter_app_intents package', (
      tester,
    ) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // Verify flutter_app_intents components are accessible
      expect(find.text('App Intents Status:'), findsOneWidget);

      // The status should show success message
      final statusCard = find.ancestor(
        of: find.text('App Intents Status:'),
        matching: find.byType(Card),
      );
      expect(statusCard, findsOneWidget);

      // Should show success message (platform-agnostic)
      expect(
        find.text('Weather query intents registered successfully!'),
        findsOneWidget,
      );
    });

    testWidgets('Query intent builder functionality works correctly',
        (tester) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // Test that the app uses query intents with presentsResult=true
      expect(find.text('App Intents Status:'), findsOneWidget);

      // Verify that the example demonstrates query intent features
      expect(find.textContaining('Siri'), findsWidgets);
      expect(find.textContaining('weather'), findsWidgets);
      expect(find.textContaining('temperature'), findsWidgets);
      expect(find.textContaining('forecast'), findsWidgets);
    });

    testWidgets('App demonstrates query intents with presentsResult', (
      tester,
    ) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // The app should demonstrate:
      // - Query intents (presentsResult=true)
      // - Voice-optimized responses
      // - Background execution (needsToContinueInApp=false)
      // - Multiple parameter types (location, days)

      // Verify UI elements that indicate these are being used
      expect(find.text('Try these Siri commands:'), findsOneWidget);
      expect(
        find.byType(Card),
        findsWidgets,
      ); // Multiple cards showing different aspects

      // Check that manual testing works (demonstrating AppIntentResult
      // handling)
      expect(find.text('Manual Testing:'), findsOneWidget);
      // Buttons exist (ElevatedButton.icon creates complex structure)
      expect(find.text('Current Weather'), findsOneWidget);
    });

    testWidgets('App handles flutter_app_intents exceptions gracefully', (
      tester,
    ) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // The app should handle any flutter_app_intents setup errors gracefully
      // and display appropriate status messages
      final statusCard = find.ancestor(
        of: find.text('App Intents Status:'),
        matching: find.byType(Card),
      );
      expect(statusCard, findsOneWidget);

      // Should not crash and should display some status
      final statusTexts = find.descendant(
        of: statusCard,
        matching: find.byType(Text),
      );
      expect(statusTexts, findsWidgets);
    });

    group('Flutter App Intents Model Integration', () {
      test('Query intents can be created with presentsResult', () {
        // Test that query intents work as expected in the example context
        const intent = AppIntent(
          identifier: 'test_query',
          title: 'Test Query',
          description: 'A test query intent',
          presentsResult: true, // Query intent
        );

        expect(intent.identifier, equals('test_query'));
        expect(intent.title, equals('Test Query'));
        expect(intent.description, equals('A test query intent'));
        expect(intent.presentsResult, isTrue);
        expect(intent.parameters, isEmpty);
        expect(intent.isEligibleForSearch, isTrue);
      });

      test('AppIntentParameter with optional location works correctly', () {
        const parameter = AppIntentParameter(
          name: 'location',
          title: 'Location',
          type: AppIntentParameterType.string,
          description: 'Location for weather query',
          isOptional: true,
          defaultValue: 'current location',
        );

        expect(parameter.name, equals('location'));
        expect(parameter.title, equals('Location'));
        expect(parameter.type, equals(AppIntentParameterType.string));
        expect(parameter.isOptional, isTrue);
        expect(parameter.defaultValue, equals('current location'));
      });

      test('AppIntentResult for background queries works correctly', () {
        final successResult = AppIntentResult.successful(
          value: 'Current weather in San Francisco: 72 degrees and Sunny.',
          needsToContinueInApp: false, // Background query
        );

        expect(successResult.success, isTrue);
        expect(successResult.value, contains('weather'));
        expect(successResult.needsToContinueInApp, isFalse);
        expect(successResult.error, isNull);
      });

      test('AppIntentBuilder creates query intent correctly', () {
        final intent = AppIntentBuilder()
            .identifier('test_weather_query')
            .title('Test Weather Query')
            .description('Testing query intent pattern')
            .presentsResult(presents: true)
            .build();

        expect(intent.identifier, equals('test_weather_query'));
        expect(intent.title, equals('Test Weather Query'));
        expect(intent.presentsResult, isTrue);
      });
    });

    group('Platform-specific behavior', () {
      testWidgets('App shows appropriate messages for platform', (
        tester,
      ) async {
        await tester.pumpWidget(const WeatherApp());
        await tester.pumpAndSettle();

        // App shows platform-agnostic success message
        final statusTexts = find.byType(Text);
        expect(statusTexts, findsWidgets);

        // Weather app shows same success message on all platforms
        expect(
          find.text('Weather query intents registered successfully!'),
          findsOneWidget,
        );
      });

      testWidgets('FlutterAppIntentsClient singleton works correctly', (
        tester,
      ) async {
        await tester.pumpWidget(const WeatherApp());

        // The app uses FlutterAppIntentsClient.instance
        // We can verify this works by checking the app doesn't crash
        // and properly initializes
        await tester.pumpAndSettle();

        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.text('Weather App Intents Example'), findsWidgets);
      });
    });

    testWidgets(
      'Example demonstrates proper query intent usage patterns',
      (tester) async {
        await tester.pumpWidget(const WeatherApp());
        await tester.pumpAndSettle();

        // The example should show query intent best practices:
        // 1. Proper error handling
        expect(find.text('App Intents Status:'), findsOneWidget);

        // 2. User guidance for voice commands
        expect(find.text('Try these Siri commands:'), findsOneWidget);

        // 3. Multiple query types (weather, temperature, forecast, rain)
        expect(find.textContaining('weather'), findsWidgets);
        expect(find.textContaining('temperature'), findsWidgets);
        expect(find.textContaining('forecast'), findsWidgets);
        expect(find.textContaining('rain'), findsWidgets);

        // 4. Manual testing alongside voice commands
        expect(find.text('Manual Testing:'), findsOneWidget);
        expect(find.text('Current Weather'), findsOneWidget);

        // 5. Query log demonstrating intent execution
        expect(find.text('Recent Query Log:'), findsOneWidget);
      },
    );

    testWidgets('Manual testing buttons work correctly', (tester) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // Find and tap the Current Weather button
      final currentWeatherButton = find.text('Current Weather');
      expect(currentWeatherButton, findsOneWidget);

      await tester.tap(currentWeatherButton);
      await tester.pump();

      // Wait for async operation (500ms delay in _fetchWeatherData)
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should show a dialog with the result
      expect(find.byType(AlertDialog), findsOneWidget);

      // Close the dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Verify query was logged (specific to avoid Siri commands text)
      expect(find.textContaining('Current weather for San Francisco'), findsOneWidget);
    });

    testWidgets('Query log updates correctly', (tester) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // Initially, log should be empty or show placeholder
      expect(find.text('Recent Query Log:'), findsOneWidget);

      // Tap a test button to trigger a query
      await tester.tap(find.text('Temperature'));
      await tester.pump();

      // Wait for async operation (500ms delay in _fetchWeatherData)
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Close the result dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Log should now contain the query (be specific to avoid button/intents text)
      expect(find.textContaining('Temperature for New York'), findsOneWidget);
    });
  });
}
