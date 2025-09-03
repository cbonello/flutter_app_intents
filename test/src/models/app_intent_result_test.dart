import 'package:flutter_app_intents/src/models/app_intent_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(AppIntentResult, () {
    group('constructor', () {
      test('creates successful result with minimal parameters', () {
        const result = AppIntentResult(success: true);

        expect(result.success, isTrue);
        expect(result.value, isNull);
        expect(result.error, isNull);
        expect(result.needsToContinueInApp, isFalse);
        expect(result.opensIntent, isNull);
      });

      test('creates failed result with error', () {
        const result = AppIntentResult(
          success: false,
          error: 'Something went wrong',
        );

        expect(result.success, isFalse);
        expect(result.value, isNull);
        expect(result.error, equals('Something went wrong'));
        expect(result.needsToContinueInApp, isFalse);
        expect(result.opensIntent, isNull);
      });

      test('creates result with all parameters', () {
        const result = AppIntentResult(
          success: true,
          value: 'Operation completed successfully',
          needsToContinueInApp: true,
          opensIntent: 'open_detail_view',
        );

        expect(result.success, isTrue);
        expect(result.value, equals('Operation completed successfully'));
        expect(result.error, isNull);
        expect(result.needsToContinueInApp, isTrue);
        expect(result.opensIntent, equals('open_detail_view'));
      });
    });

    group('successful factory', () {
      test('creates successful result with default values', () {
        final result = AppIntentResult.successful();

        expect(result.success, isTrue);
        expect(result.value, isNull);
        expect(result.error, isNull);
        expect(result.needsToContinueInApp, isFalse);
        expect(result.opensIntent, isNull);
      });

      test('creates successful result with value', () {
        final result = AppIntentResult.successful(value: 'Task completed');

        expect(result.success, isTrue);
        expect(result.value, equals('Task completed'));
        expect(result.error, isNull);
        expect(result.needsToContinueInApp, isFalse);
        expect(result.opensIntent, isNull);
      });

      test('creates successful result with continuation required', () {
        final result = AppIntentResult.successful(
          value: 'Partial completion',
          needsToContinueInApp: true,
          opensIntent: 'continue_flow',
        );

        expect(result.success, isTrue);
        expect(result.value, equals('Partial completion'));
        expect(result.needsToContinueInApp, isTrue);
        expect(result.opensIntent, equals('continue_flow'));
      });

      test('creates successful result with complex value', () {
        final complexValue = {
          'items': ['item1', 'item2', 'item3'],
          'count': 3,
          'status': 'completed',
        };

        final result = AppIntentResult.successful(value: complexValue);

        expect(result.success, isTrue);
        expect(result.value, equals(complexValue));
      });
    });

    group('failed factory', () {
      test('creates failed result with error message', () {
        final result = AppIntentResult.failed(
          error: 'Network connection failed',
        );

        expect(result.success, isFalse);
        expect(result.value, isNull);
        expect(result.error, equals('Network connection failed'));
        expect(result.needsToContinueInApp, isFalse);
        expect(result.opensIntent, isNull);
      });

      test('creates failed result with detailed error', () {
        final result = AppIntentResult.failed(
          error: 'Authentication failed: Invalid credentials provided',
        );

        expect(result.success, isFalse);
        expect(
          result.error,
          equals('Authentication failed: Invalid credentials provided'),
        );
      });
    });

    group(AppIntentResult.fromMap, () {
      test('creates successful result from map', () {
        final map = <String, dynamic>{
          'success': true,
          'value': 'Operation successful',
          'error': null,
          'needsToContinueInApp': false,
          'opensIntent': null,
        };

        final result = AppIntentResult.fromMap(map);

        expect(result.success, isTrue);
        expect(result.value, equals('Operation successful'));
        expect(result.error, isNull);
        expect(result.needsToContinueInApp, isFalse);
        expect(result.opensIntent, isNull);
      });

      test('creates failed result from map', () {
        final map = <String, dynamic>{
          'success': false,
          'value': null,
          'error': 'Operation failed',
          'needsToContinueInApp': false,
          'opensIntent': null,
        };

        final result = AppIntentResult.fromMap(map);

        expect(result.success, isFalse);
        expect(result.value, isNull);
        expect(result.error, equals('Operation failed'));
        expect(result.needsToContinueInApp, isFalse);
        expect(result.opensIntent, isNull);
      });

      test('creates result with continuation from map', () {
        final map = <String, dynamic>{
          'success': true,
          'value': 'Partial result',
          'needsToContinueInApp': true,
          'opensIntent': 'next_step',
        };

        final result = AppIntentResult.fromMap(map);

        expect(result.success, isTrue);
        expect(result.value, equals('Partial result'));
        expect(result.needsToContinueInApp, isTrue);
        expect(result.opensIntent, equals('next_step'));
      });

      test('handles missing optional fields with defaults', () {
        final map = <String, dynamic>{'success': true, 'value': 'Test value'};

        final result = AppIntentResult.fromMap(map);

        expect(result.success, isTrue);
        expect(result.value, equals('Test value'));
        expect(result.error, isNull);
        expect(result.needsToContinueInApp, isFalse);
        expect(result.opensIntent, isNull);
      });

      test('handles complex value types', () {
        final complexValue = {
          'nested': {'key': 'value'},
          'array': [1, 2, 3],
          'boolean': true,
        };

        final map = <String, dynamic>{'success': true, 'value': complexValue};

        final result = AppIntentResult.fromMap(map);

        expect(result.value, equals(complexValue));
      });
    });

    group('toMap()', () {
      test('converts successful result to map', () {
        const result = AppIntentResult(
          success: true,
          value: 'Test result',
          needsToContinueInApp: true,
          opensIntent: 'test_intent',
        );

        final map = result.toMap();

        expect(
          map,
          equals({
            'success': true,
            'value': 'Test result',
            'error': null,
            'needsToContinueInApp': true,
            'opensIntent': 'test_intent',
          }),
        );
      });

      test('converts failed result to map', () {
        const result = AppIntentResult(success: false, error: 'Test error');

        final map = result.toMap();

        expect(
          map,
          equals({
            'success': false,
            'value': null,
            'error': 'Test error',
            'needsToContinueInApp': false,
            'opensIntent': null,
          }),
        );
      });

      test('converts result with null values', () {
        const result = AppIntentResult(success: true);

        final map = result.toMap();

        expect(
          map,
          equals({
            'success': true,
            'value': null,
            'error': null,
            'needsToContinueInApp': false,
            'opensIntent': null,
          }),
        );
      });

      test('converts result with complex value', () {
        final complexValue = {
          'status': 'completed',
          'data': [1, 2, 3],
          'metadata': {'timestamp': '2023-01-01'},
        };

        final result = AppIntentResult(success: true, value: complexValue);

        final map = result.toMap();

        expect(map['value'], equals(complexValue));
        expect(map['success'], isTrue);
      });
    });

    group('equality', () {
      test('two results with same properties are equal', () {
        const result1 = AppIntentResult(
          success: true,
          value: 'Same value',
          needsToContinueInApp: true,
        );

        const result2 = AppIntentResult(
          success: true,
          value: 'Same value',
          needsToContinueInApp: true,
        );

        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('successful and failed results are not equal', () {
        const successful = AppIntentResult(success: true);
        const failed = AppIntentResult(success: false);

        expect(successful, isNot(equals(failed)));
      });

      test('results with different values are not equal', () {
        const result1 = AppIntentResult(success: true, value: 'Value 1');

        const result2 = AppIntentResult(success: true, value: 'Value 2');

        expect(result1, isNot(equals(result2)));
      });

      test('results with different error messages are not equal', () {
        const result1 = AppIntentResult(success: false, error: 'Error 1');

        const result2 = AppIntentResult(success: false, error: 'Error 2');

        expect(result1, isNot(equals(result2)));
      });
    });

    group('round-trip conversion', () {
      test('toMap and fromMap preserve successful result', () {
        final original = AppIntentResult.successful(
          value: 'Roundtrip test value',
          needsToContinueInApp: true,
          opensIntent: 'roundtrip_intent',
        );

        final map = original.toMap();
        final reconstructed = AppIntentResult.fromMap(map);

        expect(reconstructed, equals(original));
      });

      test('toMap and fromMap preserve failed result', () {
        final original = AppIntentResult.failed(
          error: 'Roundtrip test error message',
        );

        final map = original.toMap();
        final reconstructed = AppIntentResult.fromMap(map);

        expect(reconstructed, equals(original));
      });

      test('toMap and fromMap preserve complex values', () {
        final complexValue = {
          'nested_object': {
            'inner_key': 'inner_value',
            'inner_array': [1, 2, 3],
          },
          'top_level_array': ['a', 'b', 'c'],
          'boolean_value': true,
          'numeric_value': 42.5,
        };

        final original = AppIntentResult(success: true, value: complexValue);

        final map = original.toMap();
        final reconstructed = AppIntentResult.fromMap(map);

        expect(reconstructed, equals(original));
        expect(reconstructed.value, equals(complexValue));
      });

      test('toMap and fromMap preserve null values', () {
        const original = AppIntentResult(success: true);

        final map = original.toMap();
        final reconstructed = AppIntentResult.fromMap(map);

        expect(reconstructed, equals(original));
      });
    });

    group('factory methods behavior', () {
      test('successful factory creates proper result', () {
        final result = AppIntentResult.successful(
          value: 'Factory test',
          needsToContinueInApp: true,
          opensIntent: 'test_intent',
        );

        expect(result.success, isTrue);
        expect(result.value, equals('Factory test'));
        expect(result.error, isNull);
        expect(result.needsToContinueInApp, isTrue);
        expect(result.opensIntent, equals('test_intent'));
      });

      test('failed factory creates proper result', () {
        final result = AppIntentResult.failed(error: 'Factory test error');

        expect(result.success, isFalse);
        expect(result.value, isNull);
        expect(result.error, equals('Factory test error'));
        expect(result.needsToContinueInApp, isFalse);
        expect(result.opensIntent, isNull);
      });
    });
  });
}
