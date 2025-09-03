import 'package:flutter_app_intents/flutter_app_intents.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Flutter App Intents Library', () {
    group('exports', () {
      test('exports FlutterAppIntentsClient', () {
        final client = FlutterAppIntentsClient.instance;
        expect(client, isA<FlutterAppIntentsClient>());
      });

      test('exports AppIntent', () {
        const intent = AppIntent(
          identifier: 'test_intent',
          title: 'Test Intent',
          description: 'Test description',
        );
        expect(intent, isA<AppIntent>());
      });

      test('exports AppIntentParameter', () {
        const parameter = AppIntentParameter(
          name: 'test_param',
          title: 'Test Parameter',
          type: AppIntentParameterType.string,
        );
        expect(parameter, isA<AppIntentParameter>());
      });

      test('exports AppIntentResult', () {
        const result = AppIntentResult(success: true);
        expect(result, isA<AppIntentResult>());
      });

      test('exports AppIntentBuilder', () {
        final builder = AppIntentBuilder();
        expect(builder, isA<AppIntentBuilder>());
      });

      test('exports AuthenticationPolicy enum', () {
        expect(AuthenticationPolicy.none, isA<AuthenticationPolicy>());
        expect(
          AuthenticationPolicy.requiresAuthentication,
          isA<AuthenticationPolicy>(),
        );
        expect(
          AuthenticationPolicy.requiresUnlockedDevice,
          isA<AuthenticationPolicy>(),
        );
      });

      test('exports AppIntentParameterType enum', () {
        expect(AppIntentParameterType.string, isA<AppIntentParameterType>());
        expect(AppIntentParameterType.integer, isA<AppIntentParameterType>());
        expect(AppIntentParameterType.boolean, isA<AppIntentParameterType>());
        expect(AppIntentParameterType.double, isA<AppIntentParameterType>());
        expect(AppIntentParameterType.date, isA<AppIntentParameterType>());
        expect(AppIntentParameterType.url, isA<AppIntentParameterType>());
        expect(AppIntentParameterType.file, isA<AppIntentParameterType>());
        expect(AppIntentParameterType.entity, isA<AppIntentParameterType>());
      });

      test('exports FlutterAppIntentsService', () {
        expect(FlutterAppIntentsService.registerIntent, isA<Function>());
        expect(FlutterAppIntentsService.registerIntents, isA<Function>());
        expect(FlutterAppIntentsService.unregisterIntent, isA<Function>());
        expect(FlutterAppIntentsService.getRegisteredIntents, isA<Function>());
        expect(FlutterAppIntentsService.updateShortcuts, isA<Function>());
        expect(FlutterAppIntentsService.donateIntent, isA<Function>());
        expect(FlutterAppIntentsService.setIntentHandler, isA<Function>());
      });

      test('exports FlutterAppIntentsException', () {
        const exception = FlutterAppIntentsException('Test error');
        expect(exception, isA<FlutterAppIntentsException>());
        expect(exception, isA<Exception>());
      });
    });

    group('integration', () {
      test('can create complete intent using exported components', () {
        const parameter = AppIntentParameter(
          name: 'amount',
          title: 'Amount',
          type: AppIntentParameterType.integer,
          defaultValue: 1,
        );

        final intent = AppIntentBuilder()
          ..identifier('integration_test_intent')
          ..title('Integration Test Intent')
          ..description('Testing complete workflow')
          ..parameter(parameter)
          ..authenticationPolicy(AuthenticationPolicy.requiresAuthentication)
          ..eligibleForSearch(eligible: false);

        final builtIntent = intent.build();

        expect(builtIntent.identifier, equals('integration_test_intent'));
        expect(builtIntent.title, equals('Integration Test Intent'));
        expect(builtIntent.description, equals('Testing complete workflow'));
        expect(builtIntent.parameters, hasLength(1));
        expect(builtIntent.parameters.first, equals(parameter));
        expect(
          builtIntent.authenticationPolicy,
          equals(AuthenticationPolicy.requiresAuthentication),
        );
        expect(builtIntent.isEligibleForSearch, isFalse);
      });

      test('can create intent result using exported components', () {
        final successResult = AppIntentResult.successful(
          value: 'Operation completed',
          needsToContinueInApp: true,
          opensIntent: 'next_step_intent',
        );

        expect(successResult.success, isTrue);
        expect(successResult.value, equals('Operation completed'));
        expect(successResult.needsToContinueInApp, isTrue);
        expect(successResult.opensIntent, equals('next_step_intent'));

        final failureResult = AppIntentResult.failed(
          error: 'Something went wrong',
        );

        expect(failureResult.success, isFalse);
        expect(failureResult.error, equals('Something went wrong'));
      });

      test('can access client singleton through exports', () {
        final client1 = FlutterAppIntentsClient.instance;
        final client2 = FlutterAppIntentsClient.instance;

        expect(identical(client1, client2), isTrue);
      });

      test('exported types support round-trip serialization', () {
        const originalParameter = AppIntentParameter(
          name: 'test_param',
          title: 'Test Parameter',
          type: AppIntentParameterType.double,
          description: 'A test parameter',
          isOptional: true,
          defaultValue: 3.14,
        );

        final parameterMap = originalParameter.toMap();
        final reconstructedParameter = AppIntentParameter.fromMap(parameterMap);

        expect(reconstructedParameter, equals(originalParameter));

        const originalIntent = AppIntent(
          identifier: 'test_intent',
          title: 'Test Intent',
          description: 'Test description',
          parameters: [originalParameter],
          isEligibleForSearch: false,
          authenticationPolicy: AuthenticationPolicy.requiresUnlockedDevice,
        );

        final intentMap = originalIntent.toMap();
        final reconstructedIntent = AppIntent.fromMap(intentMap);

        expect(reconstructedIntent, equals(originalIntent));

        final originalResult = AppIntentResult.successful(
          value: 'Test value',
          needsToContinueInApp: true,
          opensIntent: 'test_next',
        );

        final resultMap = originalResult.toMap();
        final reconstructedResult = AppIntentResult.fromMap(resultMap);

        expect(reconstructedResult, equals(originalResult));
      });
    });
  });
}
