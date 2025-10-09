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
        // donateIntent silently succeeds on non-iOS platforms (returns true)
        final result = await client.donateIntent(
          'test_intent',
          {'key': 'value'},
        );
        expect(result, isTrue);
      });
    });
  });

  group(AppIntentBuilder, () {
    group('basic building', () {
      test('builds intent with required fields', () {
        final intent = AppIntentBuilder()
            .identifier('test_intent')
            .title('Test Intent')
            .description('A test intent')
            .build();

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

        final intent = AppIntentBuilder()
            .identifier('complex_intent')
            .title('Complex Intent')
            .description('A complex test intent')
            .parameter(parameter)
            .eligibleForSearch(eligible: false)
            .eligibleForPrediction(eligible: false)
            .authenticationPolicy(AuthenticationPolicy.requiresAuthentication)
            .build();

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

        final intent = AppIntentBuilder()
            .identifier('multi_param_intent')
            .title('Multi Parameter Intent')
            .description('Intent with multiple parameters')
            .parameter(param1)
            .parameter(param2)
            .build();

        expect(intent.parameters, hasLength(2));
        expect(intent.parameters[0], equals(param1));
        expect(intent.parameters[1], equals(param2));
      });
    });

    group('validation', () {
      test('throws when identifier is missing', () {
        final builder = AppIntentBuilder()
            .title('Test Intent')
            .description('A test intent');

        expect(
          builder.build,
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('identifier'),
            ),
          ),
        );
      });

      test('throws when title is missing', () {
        final builder = AppIntentBuilder()
            .identifier('test_intent')
            .description('A test intent');

        expect(builder.build, throwsA(isA<ArgumentError>()));
      });

      test('throws when description is missing', () {
        final builder = AppIntentBuilder()
            .identifier('test_intent')
            .title('Test Intent');

        expect(builder.build, throwsA(isA<ArgumentError>()));
      });
    });

    group('immutability', () {
      test('returns new instance on each method call', () {
        final builder1 = AppIntentBuilder();
        final builder2 = builder1.identifier('test_intent');
        final builder3 = builder2.title('Test Intent');

        // Each method call should return a new instance
        expect(identical(builder1, builder2), isFalse);
        expect(identical(builder2, builder3), isFalse);
        expect(identical(builder1, builder3), isFalse);
      });

      test('original builder remains unchanged after method calls', () {
        final builder1 = AppIntentBuilder()
            .identifier('intent_1')
            .title('Title 1')
            .description('Description 1');

        final intent1 = builder1.build();

        // Create a new builder from builder1 with different values
        final builder2 = builder1
            .identifier('intent_2')
            .title('Title 2');

        final intent2 = builder2.build();

        // builder1's values should be unchanged
        expect(intent1.identifier, equals('intent_1'));
        expect(intent1.title, equals('Title 1'));
        expect(intent1.description, equals('Description 1'));

        // builder2 should have new values
        expect(intent2.identifier, equals('intent_2'));
        expect(intent2.title, equals('Title 2'));
        expect(intent2.description, equals('Description 1')); // unchanged from builder1
      });

      test('parameters are immutable - adding parameter creates new builder', () {
        const param1 = AppIntentParameter(
          name: 'param1',
          title: 'Parameter 1',
          type: AppIntentParameterType.string,
        );

        const param2 = AppIntentParameter(
          name: 'param2',
          title: 'Parameter 2',
          type: AppIntentParameterType.integer,
        );

        final builder1 = AppIntentBuilder()
            .identifier('test_intent')
            .title('Test Intent')
            .description('Test description')
            .parameter(param1);

        final intent1 = builder1.build();

        final builder2 = builder1.parameter(param2);
        final intent2 = builder2.build();

        // Original builder should only have one parameter
        expect(intent1.parameters, hasLength(1));
        expect(intent1.parameters.first, equals(param1));

        // New builder should have both parameters
        expect(intent2.parameters, hasLength(2));
        expect(intent2.parameters[0], equals(param1));
        expect(intent2.parameters[1], equals(param2));
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
          final intent = AppIntentBuilder()
              .identifier('policy_test')
              .title('Policy Test')
              .description('Testing authentication policy')
              .authenticationPolicy(policy)
              .build();

          expect(intent.authenticationPolicy, equals(policy));
        }
      });
    });

    group('fluent API behavior', () {
      test('builder methods return new builder instance for chaining', () {
        final builder = AppIntentBuilder();

        // Test that each method returns a new builder instance
        final result1 = builder.identifier('test');
        final result2 = result1.title('Test');
        final result3 = result2.description('Test description');

        // Each should be a different instance
        expect(identical(result1, builder), isFalse);
        expect(identical(result2, result1), isFalse);
        expect(identical(result3, result2), isFalse);

        // But they should all be AppIntentBuilder instances
        expect(result1, isA<AppIntentBuilder>());
        expect(result2, isA<AppIntentBuilder>());
        expect(result3, isA<AppIntentBuilder>());
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
