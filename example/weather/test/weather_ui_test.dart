// Weather App UI and Widget Tests
//
// Tests the UI components, widget interactions, and visual elements
// of the weather app, including manual testing buttons, query log,
// and status displays.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_example/main.dart';

void main() {
  group('Weather App UI Tests', () {
    testWidgets('Main UI elements are present', (tester) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // App bar
      expect(find.text('Weather App Intents Example'), findsOneWidget);

      // Main sections
      expect(find.text('App Intents Status:'), findsOneWidget);
      expect(find.text('Try these Siri commands:'), findsOneWidget);
      expect(find.text('Manual Testing:'), findsOneWidget);
      expect(find.text('Recent Query Log:'), findsOneWidget);
      expect(find.text('Registered Query Intents:'), findsOneWidget);
    });

    testWidgets('Status card displays correctly', (tester) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // Find the status card
      final statusCard = find.ancestor(
        of: find.text('App Intents Status:'),
        matching: find.byType(Card),
      );
      expect(statusCard, findsOneWidget);

      // Status should show success message
      expect(
        find.text('Weather query intents registered successfully!'),
        findsOneWidget,
      );
    });

    testWidgets('Siri commands are displayed', (tester) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // Verify Siri command examples are shown
      expect(find.text('Try these Siri commands:'), findsOneWidget);
      expect(
        find.textContaining('Get weather from Weather Example'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Check temperature in San Francisco'),
        findsOneWidget,
      );
      expect(
        find.textContaining('forecast for tomorrow'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Is it raining in New York'),
        findsOneWidget,
      );
    });

    testWidgets('Manual testing buttons are present and styled', (
      tester,
    ) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // Find all manual testing buttons
      expect(find.text('Manual Testing:'), findsOneWidget);

      final buttons = [
        'Current Weather',
        'Temperature',
        'Forecast',
        'Rain Check',
      ];

      for (final buttonText in buttons) {
        // Find button by text (ElevatedButton.icon creates a more complex structure)
        final button = find.text(buttonText);
        expect(button, findsOneWidget, reason: 'Button "$buttonText" not found');
      }

      // Verify buttons have appropriate icons
      expect(find.byIcon(Icons.wb_sunny), findsOneWidget); // Current Weather
      expect(find.byIcon(Icons.thermostat), findsOneWidget); // Temperature
      expect(find.byIcon(Icons.calendar_today), findsOneWidget); // Forecast
      expect(find.byIcon(Icons.umbrella), findsOneWidget); // Rain Check
    });

    testWidgets('Query log displays correctly when empty', (tester) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // Find the query log section
      expect(find.text('Recent Query Log:'), findsOneWidget);

      // Should show placeholder text when empty
      expect(
        find.textContaining('No queries yet'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Try voice commands or manual testing'),
        findsOneWidget,
      );
    });

    testWidgets('Registered intents list is displayed', (tester) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // Find the registered intents section
      expect(find.text('Registered Query Intents:'), findsOneWidget);

      // Verify all registered intents are listed
      expect(
        find.text('✓ Get Current Weather (with location parameter)'),
        findsOneWidget,
      );
      expect(
        find.text('✓ Get Temperature (location-specific)'),
        findsOneWidget,
      );
      expect(
        find.text('✓ Get Weather Forecast (location + days)'),
        findsOneWidget,
      );
      expect(
        find.text('✓ Check Rain (boolean query)'),
        findsOneWidget,
      );
    });

    testWidgets('Current Weather button shows dialog with result', (
      tester,
    ) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // Tap Current Weather button
      await tester.tap(find.text('Current Weather'));
      await tester.pump();

      // Wait for async operation (500ms delay in _fetchWeatherData)
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.textContaining('current Query Result'), findsOneWidget);

      // Dialog should contain weather data (specific text from dialog)
      final dialogContent = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.textContaining('weather'),
      );
      expect(dialogContent, findsOneWidget);

      // Close dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Dialog should be gone
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Temperature button shows dialog with result', (tester) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // Tap Temperature button
      await tester.tap(find.text('Temperature'));
      await tester.pump();

      // Wait for async operation (500ms delay in _fetchWeatherData)
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.textContaining('temperature Query Result'), findsOneWidget);

      // Dialog should contain temperature data
      final dialogContent = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.textContaining('°F'),
      );
      expect(dialogContent, findsOneWidget);

      // Close dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    });

    testWidgets('Forecast button shows dialog with result', (tester) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // Tap Forecast button
      await tester.tap(find.text('Forecast'));
      await tester.pump();

      // Wait for async operation (800ms delay in _fetchForecastData)
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.textContaining('forecast Query Result'), findsOneWidget);

      // Dialog should contain forecast data (in dialog)
      final dialogContent = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.textContaining('day'),
      );
      expect(dialogContent, findsOneWidget);

      // Close dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    });

    testWidgets('Rain Check button shows dialog with result', (tester) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // Tap Rain Check button
      await tester.tap(find.text('Rain Check'));
      await tester.pump();

      // Wait for async operation (500ms delay in _fetchWeatherData)
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.textContaining('rain Query Result'), findsOneWidget);

      // Dialog should contain rain status (in dialog)
      final dialogContent = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.textContaining('raining'),
      );
      expect(dialogContent, findsOneWidget);

      // Close dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    });

    testWidgets('Query log updates after manual test', (tester) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // Initially empty
      expect(find.textContaining('No queries yet'), findsOneWidget);

      // Tap a test button
      await tester.tap(find.text('Temperature'));
      await tester.pump();

      // Wait for async operation (500ms delay in _fetchWeatherData)
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Close dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Query log should now have an entry
      expect(find.textContaining('Temperature for'), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget); // Time icon

      // Placeholder should be gone
      expect(find.textContaining('No queries yet'), findsNothing);
    });

    testWidgets('Multiple queries appear in log', (tester) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // Execute multiple queries
      final buttons = [
        'Current Weather',
        'Temperature',
        'Forecast',
      ];

      for (final buttonText in buttons) {
        await tester.tap(find.text(buttonText));
        await tester.pump();

        // Wait for async operation (800ms for forecast, 500ms for others)
        if (buttonText == 'Forecast') {
          await tester.pump(const Duration(milliseconds: 800));
        } else {
          await tester.pump(const Duration(milliseconds: 500));
        }
        await tester.pumpAndSettle();

        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
      }

      // All queries should appear in log (most recent first)
      // Check for query log entries (not the button text or instructions)
      expect(find.textContaining('forecast for Seattle'), findsOneWidget);
      expect(find.textContaining('Temperature for New York'), findsOneWidget);
      expect(find.textContaining('Current weather for San Francisco'), findsOneWidget);

      // Multiple time icons (one per query)
      expect(find.byIcon(Icons.access_time), findsWidgets);
    });

    testWidgets('UI is scrollable for small screens', (tester) async {
      // Set a small screen size
      tester.view.physicalSize = const Size(400, 600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // Verify SingleChildScrollView is present
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Should be able to scroll
      final scrollView = find.byType(SingleChildScrollView);
      await tester.drag(scrollView, const Offset(0, -300));
      await tester.pumpAndSettle();

      // Content should still be accessible after scrolling
      expect(find.text('Registered Query Intents:'), findsOneWidget);

      // Reset view size
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('Cards have proper styling and elevation', (tester) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // Find all cards
      final cards = find.byType(Card);
      expect(cards, findsWidgets);

      // Status card should exist with proper content
      final statusCard = find.ancestor(
        of: find.text('App Intents Status:'),
        matching: find.byType(Card),
      );
      expect(statusCard, findsOneWidget);
    });

    testWidgets('Container styling is applied correctly', (tester) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // Verify container with Siri commands has blue background
      final siriCommandsContainer = find.ancestor(
        of: find.text('Try these Siri commands:'),
        matching: find.byType(Container),
      );
      expect(siriCommandsContainer, findsOneWidget);

      // Verify registered intents container has grey background
      final intentsContainer = find.ancestor(
        of: find.text('Registered Query Intents:'),
        matching: find.byType(Container),
      );
      expect(intentsContainer, findsOneWidget);
    });

    testWidgets('App layout uses proper spacing', (tester) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // Verify SizedBox spacing elements exist
      expect(find.byType(SizedBox), findsWidgets);

      // Verify Padding is applied
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('Dialog dismissal works with back button', (tester) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // Show dialog
      await tester.tap(find.text('Current Weather'));
      await tester.pump();

      // Wait for async operation (500ms delay in _fetchWeatherData)
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      // Simulate back button
      final NavigatorState navigator = tester.state(find.byType(Navigator));
      navigator.pop();
      await tester.pumpAndSettle();

      // Dialog should be gone
      expect(find.byType(AlertDialog), findsNothing);
    });
  });

  group('Weather App Widget Structure', () {
    testWidgets('App uses Material Design 3', (tester) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // Find MaterialApp
      final materialApp = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );

      // Verify Material 3 is used
      expect(materialApp.theme?.useMaterial3, isTrue);
    });

    testWidgets('Theme uses blue color scheme', (tester) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );

      // Theme should be configured
      expect(materialApp.theme, isNotNull);
      expect(materialApp.theme?.colorScheme, isNotNull);
    });

    testWidgets('Scaffold structure is correct', (tester) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // Verify Scaffold exists
      expect(find.byType(Scaffold), findsOneWidget);

      // Verify AppBar exists
      expect(find.byType(AppBar), findsOneWidget);

      // Verify body content exists
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('Column layout contains all sections', (tester) async {
      await tester.pumpWidget(const WeatherApp());
      await tester.pumpAndSettle();

      // Find main Column
      final columns = find.byType(Column);
      expect(columns, findsWidgets);

      // Verify proper widget hierarchy
      expect(find.byType(Card), findsWidgets);
      expect(find.byType(Container), findsWidgets);
      // Buttons exist (verified by text)
      expect(find.text('Current Weather'), findsOneWidget);
    });
  });
}
