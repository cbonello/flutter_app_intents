// Unit tests for navigation intent parameter handling logic
//
// Tests the core logic for processing App Intent parameters including
// extraction, validation, default value handling, and result creation.
// These are pure logic tests without UI dependencies.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_intents/flutter_app_intents.dart';

void main() {
  group('Parameter Logic Tests', () {
    group('Profile Intent Parameters', () {
      test('should extract userId from parameters', () {
        final parameters = {'userId': 'user123'};
        final userId = parameters['userId'] ?? 'current';

        expect(userId, equals('user123'));
      });

      test('should default userId when missing', () {
        final parameters = <String, dynamic>{};
        final userId = parameters['userId'] as String? ?? 'current';

        expect(userId, equals('current'));
      });

      test('should default userId when null', () {
        final parameters = {'userId': null};
        final userId = parameters['userId'] as String? ?? 'current';

        expect(userId, equals('current'));
      });
    });

    group('Chat Intent Parameters', () {
      test('should extract contactName from parameters', () {
        final parameters = {'contactName': 'Alice'};
        final contactName = parameters['contactName'] ?? 'Unknown';

        expect(contactName, equals('Alice'));
      });

      test('should default contactName when missing', () {
        final parameters = <String, dynamic>{};
        final contactName = parameters['contactName'] as String? ?? 'Unknown';

        expect(contactName, equals('Unknown'));
      });

      test('should handle empty contactName', () {
        final parameters = {'contactName': ''};
        final contactName = parameters['contactName'] ?? 'Unknown';

        expect(contactName, equals(''));
      });
    });

    group('Search Intent Parameters', () {
      test('should extract query from parameters', () {
        final parameters = {'query': 'flutter tutorials'};
        final query = parameters['query'] ?? '';

        expect(query, equals('flutter tutorials'));
      });

      test('should default query when missing', () {
        final parameters = <String, dynamic>{};
        final query = parameters['query'] as String? ?? '';

        expect(query, equals(''));
      });

      test('should handle null query', () {
        final parameters = {'query': null};
        final query = parameters['query'] as String? ?? '';

        expect(query, equals(''));
      });
    });

    group('Intent Result Creation', () {
      test('should create successful profile result', () {
        final userId = 'user123';
        final result = AppIntentResult.successful(
          value: 'Opening profile for user $userId',
          needsToContinueInApp: true,
        );

        expect(result.success, isTrue);
        expect(result.value, equals('Opening profile for user user123'));
        expect(result.needsToContinueInApp, isTrue);
      });

      test('should create successful chat result', () {
        final contactName = 'Alice';
        final result = AppIntentResult.successful(
          value: 'Opening chat with $contactName',
          needsToContinueInApp: true,
        );

        expect(result.success, isTrue);
        expect(result.value, equals('Opening chat with Alice'));
        expect(result.needsToContinueInApp, isTrue);
      });

      test('should create successful search result', () {
        final query = 'flutter tutorials';
        final result = AppIntentResult.successful(
          value: 'Searching for "$query"',
          needsToContinueInApp: true,
        );

        expect(result.success, isTrue);
        expect(result.value, equals('Searching for "flutter tutorials"'));
        expect(result.needsToContinueInApp, isTrue);
      });

      test('should create successful settings result', () {
        final result = AppIntentResult.successful(
          value: 'Opening settings',
          needsToContinueInApp: true,
        );

        expect(result.success, isTrue);
        expect(result.value, equals('Opening settings'));
        expect(result.needsToContinueInApp, isTrue);
      });
    });

    group('Route Arguments Creation', () {
      test('should create profile route arguments', () {
        final userId = 'user123';
        final arguments = {'userId': userId};

        expect(arguments['userId'], equals('user123'));
      });

      test('should create chat route arguments', () {
        final contactName = 'Alice';
        final arguments = {'contactName': contactName};

        expect(arguments['contactName'], equals('Alice'));
      });

      test('should create search route arguments', () {
        final query = 'flutter tutorials';
        final arguments = {'query': query};

        expect(arguments['query'], equals('flutter tutorials'));
      });

      test('should handle empty route arguments for settings', () {
        final arguments = <String, dynamic>{};

        expect(arguments.isEmpty, isTrue);
      });
    });
  });
}
