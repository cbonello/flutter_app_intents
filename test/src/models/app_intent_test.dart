import 'package:flutter_app_intents/src/models/app_intent.dart';
import 'package:flutter_app_intents/src/models/app_intent_parameter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(AppIntent, () {
    group('constructor', () {
      test('creates AppIntent with required fields', () {
        const intent = AppIntent(
          identifier: 'test_intent',
          title: 'Test Intent',
          description: 'A test intent for testing',
        );

        expect(intent.identifier, equals('test_intent'));
        expect(intent.title, equals('Test Intent'));
        expect(intent.description, equals('A test intent for testing'));
        expect(intent.parameters, isEmpty);
        expect(intent.isEligibleForSearch, isTrue);
        expect(intent.isEligibleForPrediction, isTrue);
        expect(intent.authenticationPolicy, equals(AuthenticationPolicy.none));
      });

      test('creates AppIntent with all optional fields', () {
        const parameter = AppIntentParameter(
          name: 'amount',
          title: 'Amount',
          type: AppIntentParameterType.integer,
          defaultValue: 1,
        );

        const intent = AppIntent(
          identifier: 'complex_intent',
          title: 'Complex Intent',
          description: 'A complex intent for testing',
          parameters: [parameter],
          isEligibleForSearch: false,
          isEligibleForPrediction: false,
          authenticationPolicy: AuthenticationPolicy.requiresAuthentication,
        );

        expect(intent.identifier, equals('complex_intent'));
        expect(intent.title, equals('Complex Intent'));
        expect(intent.description, equals('A complex intent for testing'));
        expect(intent.parameters, hasLength(1));
        expect(intent.parameters.first, equals(parameter));
        expect(intent.isEligibleForSearch, isFalse);
        expect(intent.isEligibleForPrediction, isFalse);
        expect(
          intent.authenticationPolicy,
          equals(AuthenticationPolicy.requiresAuthentication),
        );
      });
    });

    group(AppIntent.fromMap, () {
      test('creates AppIntent from valid map', () {
        final map = <String, dynamic>{
          'identifier': 'from_map_intent',
          'title': 'From Map Intent',
          'description': 'Created from map',
          'parameters': <Map<String, dynamic>>[
            {
              'name': 'test_param',
              'title': 'Test Parameter',
              'type': 'string',
              'isOptional': true,
              'defaultValue': 'default',
            },
          ],
          'isEligibleForSearch': false,
          'isEligibleForPrediction': true,
          'authenticationPolicy': 'requiresUnlockedDevice',
        };

        final intent = AppIntent.fromMap(map);

        expect(intent.identifier, equals('from_map_intent'));
        expect(intent.title, equals('From Map Intent'));
        expect(intent.description, equals('Created from map'));
        expect(intent.parameters, hasLength(1));
        expect(intent.parameters.first.name, equals('test_param'));
        expect(intent.isEligibleForSearch, isFalse);
        expect(intent.isEligibleForPrediction, isTrue);
        expect(
          intent.authenticationPolicy,
          equals(AuthenticationPolicy.requiresUnlockedDevice),
        );
      });

      test('creates AppIntent with defaults when optional fields missing', () {
        final map = <String, dynamic>{
          'identifier': 'minimal_intent',
          'title': 'Minimal Intent',
          'description': 'Minimal map',
        };

        final intent = AppIntent.fromMap(map);

        expect(intent.identifier, equals('minimal_intent'));
        expect(intent.title, equals('Minimal Intent'));
        expect(intent.description, equals('Minimal map'));
        expect(intent.parameters, isEmpty);
        expect(intent.isEligibleForSearch, isTrue);
        expect(intent.isEligibleForPrediction, isTrue);
        expect(intent.authenticationPolicy, equals(AuthenticationPolicy.none));
      });

      test('handles unknown authentication policy', () {
        final map = <String, dynamic>{
          'identifier': 'test_intent',
          'title': 'Test Intent',
          'description': 'Test description',
          'authenticationPolicy': 'unknown_policy',
        };

        final intent = AppIntent.fromMap(map);

        expect(intent.authenticationPolicy, equals(AuthenticationPolicy.none));
      });

      test('handles null parameters list', () {
        final map = <String, dynamic>{
          'identifier': 'test_intent',
          'title': 'Test Intent',
          'description': 'Test description',
          'parameters': null,
        };

        final intent = AppIntent.fromMap(map);

        expect(intent.parameters, isEmpty);
      });
    });

    group('toMap()', () {
      test('converts AppIntent to map correctly', () {
        const parameter = AppIntentParameter(
          name: 'amount',
          title: 'Amount',
          type: AppIntentParameterType.integer,
        );

        const intent = AppIntent(
          identifier: 'test_intent',
          title: 'Test Intent',
          description: 'A test intent',
          parameters: [parameter],
          isEligibleForSearch: false,
          authenticationPolicy: AuthenticationPolicy.requiresAuthentication,
        );

        final map = intent.toMap();

        expect(
          map,
          equals({
            'identifier': 'test_intent',
            'title': 'Test Intent',
            'description': 'A test intent',
            'parameters': [parameter.toMap()],
            'isEligibleForSearch': false,
            'isEligibleForPrediction': true,
            'authenticationPolicy': 'requiresAuthentication',
          }),
        );
      });

      test('converts AppIntent with empty parameters', () {
        const intent = AppIntent(
          identifier: 'simple_intent',
          title: 'Simple Intent',
          description: 'Simple description',
        );

        final map = intent.toMap();

        expect(map['parameters'], isEmpty);
      });
    });

    group('copyWith()', () {
      test('creates copy with modified fields', () {
        const original = AppIntent(
          identifier: 'original_intent',
          title: 'Original Title',
          description: 'Original description',
        );

        final copy = original.copyWith(
          title: 'Modified Title',
          isEligibleForSearch: false,
        );

        expect(copy.identifier, equals('original_intent'));
        expect(copy.title, equals('Modified Title'));
        expect(copy.description, equals('Original description'));
        expect(copy.isEligibleForSearch, isFalse);
        expect(copy.isEligibleForPrediction, isTrue);
      });

      test('creates identical copy when no changes specified', () {
        const original = AppIntent(
          identifier: 'original_intent',
          title: 'Original Title',
          description: 'Original description',
          isEligibleForSearch: false,
        );

        final copy = original.copyWith();

        expect(copy.identifier, equals(original.identifier));
        expect(copy.title, equals(original.title));
        expect(copy.description, equals(original.description));
        expect(copy.isEligibleForSearch, equals(original.isEligibleForSearch));
      });
    });

    group('equality', () {
      test('two AppIntents with same properties are equal', () {
        const intent1 = AppIntent(
          identifier: 'test_intent',
          title: 'Test Intent',
          description: 'Test description',
        );

        const intent2 = AppIntent(
          identifier: 'test_intent',
          title: 'Test Intent',
          description: 'Test description',
        );

        expect(intent1, equals(intent2));
        expect(intent1.hashCode, equals(intent2.hashCode));
      });

      test('two AppIntents with different properties are not equal', () {
        const intent1 = AppIntent(
          identifier: 'test_intent_1',
          title: 'Test Intent',
          description: 'Test description',
        );

        const intent2 = AppIntent(
          identifier: 'test_intent_2',
          title: 'Test Intent',
          description: 'Test description',
        );

        expect(intent1, isNot(equals(intent2)));
      });
    });

    group('round-trip conversion', () {
      test('toMap and fromMap preserve all data', () {
        const parameter = AppIntentParameter(
          name: 'amount',
          title: 'Amount',
          type: AppIntentParameterType.double,
          description: 'Amount to use',
          isOptional: true,
          defaultValue: 5.5,
        );

        const original = AppIntent(
          identifier: 'roundtrip_intent',
          title: 'Roundtrip Intent',
          description: 'Testing roundtrip conversion',
          parameters: [parameter],
          isEligibleForSearch: false,
          isEligibleForPrediction: false,
          authenticationPolicy: AuthenticationPolicy.requiresUnlockedDevice,
        );

        final map = original.toMap();
        final reconstructed = AppIntent.fromMap(map);

        expect(reconstructed, equals(original));
      });
    });
  });

  group(AuthenticationPolicy, () {
    test('has correct values', () {
      expect(AuthenticationPolicy.values, hasLength(3));
      expect(AuthenticationPolicy.values, contains(AuthenticationPolicy.none));
      expect(
        AuthenticationPolicy.values,
        contains(AuthenticationPolicy.requiresAuthentication),
      );
      expect(
        AuthenticationPolicy.values,
        contains(AuthenticationPolicy.requiresUnlockedDevice),
      );
    });

    test('enum names are correct', () {
      expect(AuthenticationPolicy.none.name, equals('none'));
      expect(
        AuthenticationPolicy.requiresAuthentication.name,
        equals('requiresAuthentication'),
      );
      expect(
        AuthenticationPolicy.requiresUnlockedDevice.name,
        equals('requiresUnlockedDevice'),
      );
    });
  });
}
