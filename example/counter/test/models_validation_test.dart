// Models and validation tests
//
// Tests error handling, model validation, and data integrity for
// flutter_app_intents package models including exceptions, builders,
// serialization, and edge cases.

import 'package:flutter_app_intents/flutter_app_intents.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Models Validation Tests', () {
    group('FlutterAppIntentsException', () {
      test('creates exception with message', () {
        const exception = FlutterAppIntentsException('Test error');

        expect(exception.message, equals('Test error'));
        expect(exception.code, isNull);
        expect(exception.toString(), contains('Test error'));
      });

      test('creates exception with message and code', () {
        const exception = FlutterAppIntentsException('Test error', 'TEST_CODE');

        expect(exception.message, equals('Test error'));
        expect(exception.code, equals('TEST_CODE'));
        expect(exception.toString(), contains('Test error'));
        expect(exception.toString(), contains('TEST_CODE'));
      });

      test('implements Exception interface', () {
        const exception = FlutterAppIntentsException('Test');

        expect(exception, isA<Exception>());
      });
    });

    group('Model Validation', () {
      test('AppIntent handles invalid authentication policy gracefully', () {
        // Test fromMap() with unknown authentication policy
        final map = {
          'identifier': 'test',
          'title': 'Test',
          'description': 'Test description',
          'authenticationPolicy': 'unknownPolicy',
        };

        final intent = AppIntent.fromMap(map);
        expect(intent.authenticationPolicy, equals(AuthenticationPolicy.none));
      });

      test('AppIntentParameter handles unknown types gracefully', () {
        final map = {'name': 'test', 'title': 'Test', 'type': 'unknownType'};

        final parameter = AppIntentParameter.fromMap(map);
        expect(parameter.type, equals(AppIntentParameterType.string));
      });

      test('AppIntentResult handles serialization correctly', () {
        final successResult = AppIntentResult.successful(value: 'test');
        final map = successResult.toMap();
        final reconstructed = AppIntentResult.fromMap(map);

        expect(reconstructed, equals(successResult));
        expect(reconstructed.success, isTrue);
        expect(reconstructed.value, equals('test'));

        final failureResult = AppIntentResult.failed(error: 'error');
        final errorMap = failureResult.toMap();
        final reconstructedError = AppIntentResult.fromMap(errorMap);

        expect(reconstructedError, equals(failureResult));
        expect(reconstructedError.success, isFalse);
        expect(reconstructedError.error, equals('error'));
      });
    });

    group('Builder Validation', () {
      test('AppIntentBuilder validates required fields', () {
        final builder = AppIntentBuilder();

        // Should throw when missing required fields
        expect(builder.build, throwsArgumentError);

        // Should work with minimal required fields
        builder
          ..identifier('test')
          ..title('Test')
          ..description('Test description');

        final intent = builder.build();
        expect(intent.identifier, equals('test'));
        expect(intent.title, equals('Test'));
        expect(intent.description, equals('Test description'));
      });

      test('AppIntentBuilder handles null and empty values correctly', () {
        final builder = AppIntentBuilder()
          ..identifier('test')
          ..title('Test')
          ..description('Test description');

        // Should handle empty parameters list
        final intent = builder.build();
        expect(intent.parameters, isEmpty);

        // Should handle parameter addition and removal
        const param = AppIntentParameter(
          name: 'test',
          title: 'Test',
          type: AppIntentParameterType.string,
        );

        builder.parameter(param);
        final intentWithParam = builder.build();
        expect(intentWithParam.parameters, hasLength(1));
        expect(intentWithParam.parameters.first, equals(param));
      });

      test('AppIntentBuilder supports method chaining correctly', () {
        final intent = AppIntentBuilder()
            .identifier('chain_test')
            .title('Chain Test')
            .description('Testing method chaining')
            .eligibleForSearch(eligible: false)
            .eligibleForPrediction(eligible: false)
            .authenticationPolicy(AuthenticationPolicy.requiresAuthentication)
            .build();

        expect(intent.identifier, equals('chain_test'));
        expect(intent.isEligibleForSearch, isFalse);
        expect(intent.isEligibleForPrediction, isFalse);
        expect(
          intent.authenticationPolicy,
          equals(AuthenticationPolicy.requiresAuthentication),
        );
      });
    });

    group(
      'Service Error Handling',
      () {
        test('FlutterAppIntentsService methods handle platform correctly', () {
          // These tests verify the service handles non-iOS platforms gracefully
          // by throwing appropriate UnsupportedError exceptions
          const testIntent = AppIntent(
            identifier: 'test',
            title: 'Test',
            description: 'Test intent',
          );

          // All service methods should throw UnsupportedError on non-iOS
          expect(
            () => FlutterAppIntentsService.registerIntent(testIntent),
            throwsA(isA<UnsupportedError>()),
          );

          expect(
            () => FlutterAppIntentsService.registerIntents([testIntent]),
            throwsA(isA<UnsupportedError>()),
          );

          expect(
            () => FlutterAppIntentsService.unregisterIntent('test'),
            throwsA(isA<UnsupportedError>()),
          );

          expect(
            FlutterAppIntentsService.getRegisteredIntents(),
            throwsA(isA<UnsupportedError>()),
          );

          expect(
            FlutterAppIntentsService.updateShortcuts(),
            throwsA(isA<UnsupportedError>()),
          );

          expect(
            () => FlutterAppIntentsService.donateIntent('test', {}),
            throwsA(isA<UnsupportedError>()),
          );
        });

        testWidgets('FlutterAppIntentsClient delegates to service correctly', (
          tester,
        ) async {
          final client = FlutterAppIntentsClient.instance;

          // Client methods should delegate to service and handle errors
          const testIntent = AppIntent(
            identifier: 'test',
            title: 'Test',
            description: 'Test intent',
          );

          expect(
            () => client.registerIntent(testIntent, (params) async {
              return AppIntentResult.successful();
            }),
            throwsA(isA<UnsupportedError>()),
          );

          expect(
            client.getRegisteredIntents(),
            throwsA(isA<UnsupportedError>()),
          );

          expect(client.updateShortcuts(), throwsA(isA<UnsupportedError>()));
        });
      },
    );

    group('Data Integrity', () {
      test('Models maintain equality contract correctly', () {
        const intent1 = AppIntent(
          identifier: 'test',
          title: 'Test',
          description: 'Test description',
        );
        const intent2 = AppIntent(
          identifier: 'test',
          title: 'Test',
          description: 'Test description',
        );
        const intent3 = AppIntent(
          identifier: 'different',
          title: 'Test',
          description: 'Test description',
        );

        // Equal objects should be equal
        expect(intent1, equals(intent2));
        expect(intent1.hashCode, equals(intent2.hashCode));

        // Different objects should not be equal
        expect(intent1, isNot(equals(intent3)));
        expect(intent1.hashCode, isNot(equals(intent3.hashCode)));
      });

      test('copyWith() preserves object integrity', () {
        const original = AppIntent(
          identifier: 'original',
          title: 'Original Title',
          description: 'Original description',
          isEligibleForSearch: false,
        );

        final modified = original.copyWith(title: 'Modified Title');

        expect(modified.identifier, equals('original'));
        expect(modified.title, equals('Modified Title'));
        expect(modified.description, equals('Original description'));
        expect(modified.isEligibleForSearch, isFalse);

        // Original should be unchanged
        expect(original.title, equals('Original Title'));
      });

      test('Round-trip serialization preserves data', () {
        const parameter = AppIntentParameter(
          name: 'complex_param',
          title: 'Complex Parameter',
          type: AppIntentParameterType.integer,
          description: 'A complex parameter with all fields',
          isOptional: true,
          defaultValue: 42,
        );
        const intent = AppIntent(
          identifier: 'complex_intent',
          title: 'Complex Intent',
          description: 'An intent with all possible fields',
          parameters: [parameter],
          isEligibleForSearch: false,
          isEligibleForPrediction: false,
          authenticationPolicy: AuthenticationPolicy.requiresUnlockedDevice,
        );

        final map = intent.toMap();
        final reconstructed = AppIntent.fromMap(map);

        expect(reconstructed, equals(intent));
        expect(reconstructed.parameters, hasLength(1));
        expect(reconstructed.parameters.first, equals(parameter));
      });
    });
  });
}
