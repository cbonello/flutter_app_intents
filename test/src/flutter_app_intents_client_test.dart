import 'package:flutter_app_intents/src/flutter_app_intents_client.dart';
import 'package:flutter_app_intents/src/models/app_intent.dart';
import 'package:flutter_app_intents/src/models/app_intent_parameter.dart';
import 'package:flutter_app_intents/src/models/app_intent_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(FlutterAppIntentsClient, () {
    late FlutterAppIntentsClient client;

    setUp(() {
      // Get fresh instance for each test
      client = FlutterAppIntentsClient.instance;
    });

    group('singleton behavior', () {
      test('returns same instance on multiple calls', () {
        final instance1 = FlutterAppIntentsClient.instance;
        final instance2 = FlutterAppIntentsClient.instance;

        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('public API', () {
      test('registerIntent returns a result', () async {
        const intent = AppIntent(
          identifier: 'test_intent',
          title: 'Test Intent',
          description: 'A test intent',
        );

        Future<AppIntentResult> handler(Map<String, dynamic> parameters) async {
          return AppIntentResult.successful(value: 'Handler executed');
        }

        // This will throw UnsupportedError on non-iOS platforms
        expect(
          () => client.registerIntent(intent, handler),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('registerIntents accepts multiple intents', () async {
        const intent1 = AppIntent(
          identifier: 'intent_1',
          title: 'Intent 1',
          description: 'First intent',
        );

        const intent2 = AppIntent(
          identifier: 'intent_2',
          title: 'Intent 2',
          description: 'Second intent',
        );

        Future<AppIntentResult> handler1(Map<String, dynamic> params) async {
          return AppIntentResult.successful(value: 'Handler 1');
        }

        Future<AppIntentResult> handler2(Map<String, dynamic> params) async {
          return AppIntentResult.successful(value: 'Handler 2');
        }

        final intentsWithHandlers = {intent1: handler1, intent2: handler2};

        expect(
          () => client.registerIntents(intentsWithHandlers),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('unregisterIntent accepts identifier', () async {
        expect(
          () => client.unregisterIntent('test_intent'),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('getRegisteredIntents returns future list', () async {
        expect(client.getRegisteredIntents(), throwsA(isA<UnsupportedError>()));
      });

      test('updateShortcuts returns future bool', () async {
        expect(client.updateShortcuts(), throwsA(isA<UnsupportedError>()));
      });

      test('donateIntent accepts parameters', () async {
        expect(
          () => client.donateIntent('test_intent', {'key': 'value'}),
          throwsA(isA<UnsupportedError>()),
        );
      });
    });
  });

  group(AppIntentBuilder, () {
    group('basic building', () {
      test('builds intent with required fields', () {
        final builder = AppIntentBuilder()
          ..identifier('test_intent')
          ..title('Test Intent')
          ..description('A test intent');

        final intent = builder.build();

        expect(intent.identifier, equals('test_intent'));
        expect(intent.title, equals('Test Intent'));
        expect(intent.description, equals('A test intent'));
        expect(intent.parameters, isEmpty);
        expect(intent.isEligibleForSearch, isTrue);
        expect(intent.isEligibleForPrediction, isTrue);
        expect(intent.authenticationPolicy, equals(AuthenticationPolicy.none));
      });

      test('builds intent with all optional fields', () {
        const parameter = AppIntentParameter(
          name: 'amount',
          title: 'Amount',
          type: AppIntentParameterType.integer,
          defaultValue: 1,
        );

        final builder = AppIntentBuilder()
          ..identifier('complex_intent')
          ..title('Complex Intent')
          ..description('A complex test intent')
          ..parameter(parameter)
          ..eligibleForSearch(eligible: false)
          ..eligibleForPrediction(eligible: false)
          ..authenticationPolicy(AuthenticationPolicy.requiresAuthentication);

        final intent = builder.build();

        expect(intent.identifier, equals('complex_intent'));
        expect(intent.title, equals('Complex Intent'));
        expect(intent.description, equals('A complex test intent'));
        expect(intent.parameters, hasLength(1));
        expect(intent.parameters.first, equals(parameter));
        expect(intent.isEligibleForSearch, isFalse);
        expect(intent.isEligibleForPrediction, isFalse);
        expect(
          intent.authenticationPolicy,
          equals(AuthenticationPolicy.requiresAuthentication),
        );
      });

      test('builds intent with multiple parameters', () {
        const param1 = AppIntentParameter(
          name: 'amount',
          title: 'Amount',
          type: AppIntentParameterType.integer,
        );

        const param2 = AppIntentParameter(
          name: 'message',
          title: 'Message',
          type: AppIntentParameterType.string,
        );

        final builder = AppIntentBuilder()
          ..identifier('multi_param_intent')
          ..title('Multi Parameter Intent')
          ..description('Intent with multiple parameters')
          ..parameter(param1)
          ..parameter(param2);

        final intent = builder.build();

        expect(intent.parameters, hasLength(2));
        expect(intent.parameters[0], equals(param1));
        expect(intent.parameters[1], equals(param2));
      });
    });

    group('validation', () {
      test('throws when identifier is missing', () {
        final builder = AppIntentBuilder()
          ..title('Test Intent')
          ..description('A test intent');

        expect(
          builder.build,
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'Identifier, title, and description are required',
            ),
          ),
        );
      });

      test('throws when title is missing', () {
        final builder = AppIntentBuilder()
          ..identifier('test_intent')
          ..description('A test intent');

        expect(builder.build, throwsA(isA<ArgumentError>()));
      });

      test('throws when description is missing', () {
        final builder = AppIntentBuilder()
          ..identifier('test_intent')
          ..title('Test Intent');

        expect(builder.build, throwsA(isA<ArgumentError>()));
      });
    });

    group('builder reuse', () {
      test('can reuse builder for multiple intents', () {
        final builder = AppIntentBuilder()
          ..identifier('base_intent')
          ..title('Base Intent')
          ..description('Base description');

        final intent1 = builder.build();

        // Modify for second intent
        builder
          ..identifier('modified_intent')
          ..title('Modified Intent');

        final intent2 = builder.build();

        expect(intent1.identifier, equals('base_intent'));
        expect(intent1.title, equals('Base Intent'));

        expect(intent2.identifier, equals('modified_intent'));
        expect(intent2.title, equals('Modified Intent'));
        expect(intent2.description, equals('Base description')); // unchanged
      });

      test('preserves parameters across builds', () {
        const parameter = AppIntentParameter(
          name: 'test_param',
          title: 'Test Parameter',
          type: AppIntentParameterType.string,
        );

        final builder = AppIntentBuilder()
          ..identifier('intent_1')
          ..title('Intent 1')
          ..description('First intent')
          ..parameter(parameter);

        final intent1 = builder.build();

        builder
          ..identifier('intent_2')
          ..title('Intent 2')
          ..description('Second intent');

        final intent2 = builder.build();

        expect(intent1.parameters, hasLength(1));
        expect(intent2.parameters, hasLength(1));
        expect(intent1.parameters.first, equals(parameter));
        expect(intent2.parameters.first, equals(parameter));
      });
    });

    group('authentication policies', () {
      test('sets each authentication policy correctly', () {
        final policies = [
          AuthenticationPolicy.none,
          AuthenticationPolicy.requiresAuthentication,
          AuthenticationPolicy.requiresUnlockedDevice,
        ];

        for (final policy in policies) {
          final builder = AppIntentBuilder()
            ..identifier('policy_test')
            ..title('Policy Test')
            ..description('Testing authentication policy')
            ..authenticationPolicy(policy);

          final intent = builder.build();
          expect(intent.authenticationPolicy, equals(policy));
        }
      });
    });

    group('fluent API behavior', () {
      test('builder methods return builder for chaining', () {
        final builder = AppIntentBuilder();

        // Test that each method returns the builder for chaining
        final result1 = builder.identifier('test');
        final result2 = builder.title('Test');
        final result3 = builder.description('Test description');

        expect(identical(result1, builder), isTrue);
        expect(identical(result2, builder), isTrue);
        expect(identical(result3, builder), isTrue);
      });

      test('supports method chaining', () {
        final intent = AppIntentBuilder()
            .identifier('chained_intent')
            .title('Chained Intent')
            .description('Built with method chaining')
            .eligibleForSearch(eligible: false)
            .authenticationPolicy(AuthenticationPolicy.requiresAuthentication)
            .build();

        expect(intent.identifier, equals('chained_intent'));
        expect(intent.title, equals('Chained Intent'));
        expect(intent.isEligibleForSearch, isFalse);
        expect(
          intent.authenticationPolicy,
          equals(AuthenticationPolicy.requiresAuthentication),
        );
      });
    });
  });
}
