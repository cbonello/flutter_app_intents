import 'dart:io';

import 'package:counter_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_intents/flutter_app_intents.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Flutter App Intents Integration Tests', () {
    testWidgets('App properly integrates with flutter_app_intents package', (
      tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify flutter_app_intents components are accessible
      expect(find.text('App Intents Status:'), findsOneWidget);

      // The status should reflect the platform
      if (Platform.isIOS) {
        // On iOS, should show either success or specific error
        final statusCard = find.ancestor(
          of: find.text('App Intents Status:'),
          matching: find.byType(Card),
        );
        expect(statusCard, findsOneWidget);
      } else {
        // On non-iOS, should show platform warning
        expect(find.textContaining('iOS'), findsOneWidget);
      }
    });

    testWidgets('Intent builder functionality works correctly', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Test that the app uses the flutter_app_intents AppIntentBuilder
      // by checking that intents are being processed
      // (This is implicit through the status display)
      expect(find.text('App Intents Status:'), findsOneWidget);

      // Verify that the example demonstrates flutter_app_intents features
      expect(find.textContaining('Siri'), findsWidgets);
      expect(find.textContaining('increment'), findsOneWidget);
      expect(find.textContaining('reset'), findsOneWidget);
      expect(find.textContaining('get'), findsOneWidget);
    });

    testWidgets('App demonstrates all flutter_app_intents model classes', (
      tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // The app should demonstrate usage of:
      // - AppIntent (through the builder)
      // - AppIntentParameter (shown in the example commands)
      // - AppIntentResult (returned from handlers)
      // - FlutterAppIntentsClient (singleton usage)

      // Verify UI elements that indicate these are being used
      expect(find.text('Try these Siri commands:'), findsOneWidget);
      expect(
        find.byType(Card),
        findsWidgets,
      ); // Multiple cards showing different aspects

      // Check that counter functionality works (demonstrating AppIntentResult
      // handling)
      final initialCounter = find.text('0');
      expect(initialCounter, findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });

    testWidgets('App handles flutter_app_intents exceptions gracefully', (
      tester,
    ) async {
      await tester.pumpWidget(const MyApp());
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
      test('AppIntent models can be created as expected', () {
        // Test that the models work as expected in the example context
        const intent = AppIntent(
          identifier: 'test_intent',
          title: 'Test Intent',
          description: 'A test intent',
        );

        expect(intent.identifier, equals('test_intent'));
        expect(intent.title, equals('Test Intent'));
        expect(intent.description, equals('A test intent'));
        expect(intent.parameters, isEmpty);
        expect(intent.isEligibleForSearch, isTrue);
        expect(intent.authenticationPolicy, equals(AuthenticationPolicy.none));
      });

      test('AppIntentParameter models work correctly', () {
        const parameter = AppIntentParameter(
          name: 'amount',
          title: 'Amount',
          type: AppIntentParameterType.integer,
          description: 'Amount to increment',
          isOptional: true,
          defaultValue: 1,
        );

        expect(parameter.name, equals('amount'));
        expect(parameter.title, equals('Amount'));
        expect(parameter.type, equals(AppIntentParameterType.integer));
        expect(parameter.isOptional, isTrue);
        expect(parameter.defaultValue, equals(1));
      });

      test('AppIntentResult models work correctly', () {
        final successResult = AppIntentResult.successful(
          value: 'Counter incremented by 1. New value: 1',
        );

        expect(successResult.success, isTrue);
        expect(successResult.value, contains('Counter incremented'));
        expect(successResult.error, isNull);

        const failureResult = AppIntentResult(
          success: false,
          error: 'Test error',
        );

        expect(failureResult.success, isFalse);
        expect(failureResult.error, equals('Test error'));
      });

      test('AppIntentBuilder works correctly', () {
        final builder = AppIntentBuilder()
          ..identifier('test_builder')
          ..title('Test Builder Intent')
          ..description('Testing the builder pattern');

        final intent = builder.build();

        expect(intent.identifier, equals('test_builder'));
        expect(intent.title, equals('Test Builder Intent'));
        expect(intent.description, equals('Testing the builder pattern'));
      });
    });

    group('Platform-specific behavior', () {
      testWidgets('App shows appropriate messages for platform', (
        tester,
      ) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        if (Platform.isIOS) {
          // On iOS, should attempt to register intents
          final statusTexts = find.byType(Text);
          expect(statusTexts, findsWidgets);

          // Should not show the iOS-only warning
          expect(find.textContaining('only supported on iOS'), findsNothing);
        } else {
          // On non-iOS platforms, should show platform limitation
          expect(find.textContaining('iOS'), findsOneWidget);
        }
      });

      testWidgets('FlutterAppIntentsClient singleton works correctly', (
        tester,
      ) async {
        await tester.pumpWidget(const MyApp());

        // The app uses FlutterAppIntentsClient.instance
        // We can verify this works by checking the app doesn't crash
        // and properly initializes
        await tester.pumpAndSettle();

        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.text('Flutter App Intents Example'), findsWidgets);
      });
    });

    testWidgets(
      'Example demonstrates proper flutter_app_intents usage patterns',
      (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // The example should show best practices:
        // 1. Proper error handling
        expect(find.text('App Intents Status:'), findsOneWidget);

        // 2. User guidance for voice commands
        expect(find.text('Try these Siri commands:'), findsOneWidget);

        // 3. Multiple intent types (with and without parameters)
        expect(find.textContaining('increment'), findsOneWidget);
        expect(find.textContaining('reset'), findsOneWidget);
        expect(find.textContaining('get'), findsOneWidget);

        // 4. Manual fallbacks alongside voice commands
        expect(find.byType(FloatingActionButton), findsOneWidget);

        // 5. State management that works with both UI and intents
        expect(find.text('Current counter value:'), findsOneWidget);
        expect(find.text('0'), findsOneWidget);
      },
    );
  });
}
