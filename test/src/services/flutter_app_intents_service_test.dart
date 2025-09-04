import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_intents/src/models/app_intent.dart';
import 'package:flutter_app_intents/src/models/app_intent_parameter.dart';
import 'package:flutter_app_intents/src/models/app_intent_result.dart';
import 'package:flutter_app_intents/src/services/flutter_app_intents_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(FlutterAppIntentsService, () {
    const channel = MethodChannel('flutter_app_intents');
    final methodCalls = <MethodCall>[];

    setUp(() {
      methodCalls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            methodCalls.add(methodCall);

            switch (methodCall.method) {
              case 'registerIntent':
              case 'registerIntents':
              case 'unregisterIntent':
              case 'updateShortcuts':
              case 'donateIntent':
              case 'donateIntentWithMetadata':
              case 'donateIntentBatch':
                return true;
              case 'getRegisteredIntents':
                return <Map<String, dynamic>>[
                  {
                    'identifier': 'test_intent',
                    'title': 'Test Intent',
                    'description': 'A test intent',
                    'parameters': <Map<String, dynamic>>[],
                    'isEligibleForSearch': true,
                    'isEligibleForPrediction': true,
                    'authenticationPolicy': 'none',
                  },
                ];
              default:
                return null;
            }
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    group('Platform validation', () {
      test('throws UnsupportedError on non-iOS platforms', () async {
        // This test assumes we're running on a non-iOS
        // platform (macOS/Linux/Windows)
        if (!Platform.isIOS) {
          const intent = AppIntent(
            identifier: 'test_intent',
            title: 'Test Intent',
            description: 'Test description',
          );

          expect(
            () => FlutterAppIntentsService.registerIntent(intent),
            throwsA(
              isA<UnsupportedError>().having(
                (e) => e.message,
                'message',
                'App Intents are only supported on iOS',
              ),
            ),
          );

          expect(
            () => FlutterAppIntentsService.registerIntents([intent]),
            throwsA(isA<UnsupportedError>()),
          );

          expect(
            () => FlutterAppIntentsService.unregisterIntent('test_intent'),
            throwsA(isA<UnsupportedError>()),
          );

          expect(
            FlutterAppIntentsService.getRegisteredIntents,
            throwsA(isA<UnsupportedError>()),
          );

          expect(
            FlutterAppIntentsService.updateShortcuts,
            throwsA(isA<UnsupportedError>()),
          );

          expect(
            () => FlutterAppIntentsService.donateIntent('test_intent', {}),
            throwsA(isA<UnsupportedError>()),
          );
        }
      });
    });

    group('Method channel communication', () {
      setUp(() {
        // Mock iOS platform for testing
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      });

      tearDown(() {
        debugDefaultTargetPlatformOverride = null;
      });

      group(FlutterAppIntentsService.registerIntent, () {
        test('calls platform method with correct arguments', () async {
          const intent = AppIntent(
            identifier: 'test_intent',
            title: 'Test Intent',
            description: 'A test intent for testing',
            isEligibleForSearch: false,
          );

          final result = await FlutterAppIntentsService.registerIntent(intent);

          expect(result, isTrue);
          expect(methodCalls, hasLength(1));
          expect(methodCalls.first.method, equals('registerIntent'));

          final arguments = Map<String, dynamic>.from(
            methodCalls.first.arguments as Map<Object?, Object?>,
          );
          expect(arguments['identifier'], equals('test_intent'));
          expect(arguments['title'], equals('Test Intent'));
          expect(arguments['description'], equals('A test intent for testing'));
          expect(arguments['isEligibleForSearch'], isFalse);
        });

        test('handles platform exception', () async {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
                throw PlatformException(code: 'ERROR', message: 'Test error');
              });

          const intent = AppIntent(
            identifier: 'test_intent',
            title: 'Test Intent',
            description: 'Test description',
          );

          expect(
            () => FlutterAppIntentsService.registerIntent(intent),
            throwsA(
              isA<FlutterAppIntentsException>()
                  .having(
                    (e) => e.message,
                    'message',
                    'Failed to register intent: Test error',
                  )
                  .having((e) => e.code, 'code', 'ERROR'),
            ),
          );
        });

        test('handles null response', () async {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                channel,
                (MethodCall methodCall) async => null,
              );

          const intent = AppIntent(
            identifier: 'test_intent',
            title: 'Test Intent',
            description: 'Test description',
          );

          final result = await FlutterAppIntentsService.registerIntent(intent);
          expect(result, isFalse);
        });
      });

      group(FlutterAppIntentsService.registerIntents, () {
        test('calls platform method with multiple intents', () async {
          final intents = [
            const AppIntent(
              identifier: 'intent_1',
              title: 'Intent 1',
              description: 'First intent',
            ),
            const AppIntent(
              identifier: 'intent_2',
              title: 'Intent 2',
              description: 'Second intent',
            ),
          ];

          final result = await FlutterAppIntentsService.registerIntents(
            intents,
          );

          expect(result, isTrue);
          expect(methodCalls, hasLength(1));
          expect(methodCalls.first.method, equals('registerIntents'));

          final arguments = Map<String, dynamic>.from(
            methodCalls.first.arguments as Map<Object?, Object?>,
          );
          final intentsList = arguments['intents'] as List<dynamic>;
          expect(intentsList, hasLength(2));
          final intent1Map = Map<String, dynamic>.from(
            intentsList[0] as Map<Object?, Object?>,
          );
          expect(intent1Map['identifier'], equals('intent_1'));

          final intent2Map = Map<String, dynamic>.from(
            intentsList[1] as Map<Object?, Object?>,
          );
          expect(intent2Map['identifier'], equals('intent_2'));
        });

        test('handles empty intents list', () async {
          final result = await FlutterAppIntentsService.registerIntents([]);

          expect(result, isTrue);
          expect(methodCalls, hasLength(1));

          final arguments = Map<String, dynamic>.from(
            methodCalls.first.arguments as Map<Object?, Object?>,
          );
          final intentsList = arguments['intents'] as List<dynamic>;
          expect(intentsList, isEmpty);
        });
      });

      group(FlutterAppIntentsService.unregisterIntent, () {
        test('calls platform method with identifier', () async {
          final result = await FlutterAppIntentsService.unregisterIntent(
            'test_intent',
          );

          expect(result, isTrue);
          expect(methodCalls, hasLength(1));
          expect(methodCalls.first.method, equals('unregisterIntent'));

          final arguments = Map<String, dynamic>.from(
            methodCalls.first.arguments as Map<Object?, Object?>,
          );
          expect(arguments['identifier'], equals('test_intent'));
        });
      });

      group(FlutterAppIntentsService.getRegisteredIntents, () {
        test('returns parsed intents list', () async {
          final intents = await FlutterAppIntentsService.getRegisteredIntents();

          expect(intents, hasLength(1));
          expect(intents.first.identifier, equals('test_intent'));
          expect(intents.first.title, equals('Test Intent'));
          expect(intents.first.description, equals('A test intent'));
          expect(methodCalls, hasLength(1));
          expect(methodCalls.first.method, equals('getRegisteredIntents'));
        });

        test('returns empty list when null response', () async {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                channel,
                (MethodCall methodCall) async => null,
              );

          final intents = await FlutterAppIntentsService.getRegisteredIntents();

          expect(intents, isEmpty);
        });

        test('handles complex intent data', () async {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                channel,
                (MethodCall methodCall) async => <Map<String, dynamic>>[
                  <String, dynamic>{
                    'identifier': 'complex_intent',
                    'title': 'Complex Intent',
                    'description': 'A complex test intent',
                    'parameters': <Map<String, dynamic>>[
                      <String, dynamic>{
                        'name': 'amount',
                        'title': 'Amount',
                        'type': 'integer',
                        'isOptional': true,
                        'defaultValue': 42,
                      },
                    ],
                    'isEligibleForSearch': false,
                    'isEligibleForPrediction': true,
                    'authenticationPolicy': 'requiresAuthentication',
                  },
                ],
              );

          final intents = await FlutterAppIntentsService.getRegisteredIntents();

          expect(intents, hasLength(1));
          final intent = intents.first;
          expect(intent.identifier, equals('complex_intent'));
          expect(intent.parameters, hasLength(1));
          expect(intent.parameters.first.name, equals('amount'));
          expect(
            intent.parameters.first.type,
            equals(AppIntentParameterType.integer),
          );
          expect(intent.isEligibleForSearch, isFalse);
          expect(
            intent.authenticationPolicy,
            equals(AuthenticationPolicy.requiresAuthentication),
          );
        });
      });

      group(FlutterAppIntentsService.updateShortcuts, () {
        test('calls platform method', () async {
          final result = await FlutterAppIntentsService.updateShortcuts();

          expect(result, isTrue);
          expect(methodCalls, hasLength(1));
          expect(methodCalls.first.method, equals('updateShortcuts'));
          expect(methodCalls.first.arguments, isNull);
        });
      });

      group(FlutterAppIntentsService.donateIntent, () {
        test('calls platform method with parameters', () async {
          final parameters = <String, dynamic>{
            'amount': 5,
            'type': 'increment',
          };

          final result = await FlutterAppIntentsService.donateIntent(
            'test_intent',
            parameters,
          );

          expect(result, isTrue);
          expect(methodCalls, hasLength(1));
          expect(methodCalls.first.method, equals('donateIntentWithMetadata'));

          final arguments = Map<String, dynamic>.from(
            methodCalls.first.arguments as Map<Object?, Object?>,
          );
          expect(arguments['identifier'], equals('test_intent'));
          expect(arguments['parameters'], equals(parameters));

          // Verify metadata structure (since donateIntent now calls
          // donateIntentWithMetadata)
          final metadata = Map<String, dynamic>.from(
            arguments['metadata'] as Map<Object?, Object?>,
          );
          expect(
            metadata['relevanceScore'],
            equals(1.0),
          ); // Default relevance score
          expect(metadata['context'], isEmpty); // Default empty context
        });

        test('handles empty parameters', () async {
          final result = await FlutterAppIntentsService.donateIntent(
            'simple_intent',
            {},
          );

          expect(result, isTrue);
          expect(methodCalls, hasLength(1));
          expect(methodCalls.first.method, equals('donateIntentWithMetadata'));

          final arguments = Map<String, dynamic>.from(
            methodCalls.first.arguments as Map<Object?, Object?>,
          );
          expect(arguments['identifier'], equals('simple_intent'));
          expect(arguments['parameters'], isEmpty);

          // Verify metadata structure (since donateIntent now calls
          // donateIntentWithMetadata)
          final metadata = Map<String, dynamic>.from(
            arguments['metadata'] as Map<Object?, Object?>,
          );
          expect(
            metadata['relevanceScore'],
            equals(1.0),
          ); // Default relevance score
          expect(metadata['context'], isEmpty); // Default empty context
        });
      });

      group(FlutterAppIntentsService.donateIntentWithMetadata, () {
        test('calls platform method with enhanced metadata', () async {
          final parameters = <String, dynamic>{
            'amount': 5,
            'type': 'increment',
          };

          final result =
              await FlutterAppIntentsService.donateIntentWithMetadata(
                'enhanced_intent',
                parameters,
                relevanceScore: 0.8,
                context: {'feature': 'counter', 'userAction': true},
                timestamp: DateTime.fromMillisecondsSinceEpoch(1000000),
              );

          expect(result, isTrue);
          expect(methodCalls, hasLength(1));
          expect(methodCalls.first.method, equals('donateIntentWithMetadata'));

          final arguments = Map<String, dynamic>.from(
            methodCalls.first.arguments as Map<Object?, Object?>,
          );
          expect(arguments['identifier'], equals('enhanced_intent'));
          expect(arguments['parameters'], equals(parameters));

          final metadata = Map<String, dynamic>.from(
            arguments['metadata'] as Map<Object?, Object?>,
          );
          expect(metadata['relevanceScore'], equals(0.8));
          expect(
            metadata['context'],
            equals({'feature': 'counter', 'userAction': true}),
          );
          expect(metadata['timestamp'], equals(1000000));
        });

        test('handles default values correctly', () async {
          final result =
              await FlutterAppIntentsService.donateIntentWithMetadata(
                'simple_intent',
                {},
              );

          expect(result, isTrue);
          final arguments = Map<String, dynamic>.from(
            methodCalls.first.arguments as Map<Object?, Object?>,
          );

          final metadata = Map<String, dynamic>.from(
            arguments['metadata'] as Map<Object?, Object?>,
          );
          expect(metadata['relevanceScore'], equals(1.0));
          expect(metadata['context'], isEmpty);
          expect(metadata['timestamp'], isA<int>());
        });

        test('validates relevance score range', () async {
          expect(
            () => FlutterAppIntentsService.donateIntentWithMetadata(
              'invalid_intent',
              {},
              relevanceScore: 1.5,
            ),
            throwsArgumentError,
          );

          expect(
            () => FlutterAppIntentsService.donateIntentWithMetadata(
              'invalid_intent',
              {},
              relevanceScore: -0.1,
            ),
            throwsArgumentError,
          );
        });
      });

      group(FlutterAppIntentsService.donateIntentBatch, () {
        test('calls platform method with batch data', () async {
          const donations = [
            IntentDonation.highRelevance(
              identifier: 'intent1',
              parameters: {'value': 1},
              context: {'type': 'user'},
            ),
            IntentDonation.mediumRelevance(
              identifier: 'intent2',
              parameters: {'value': 2},
            ),
          ];

          final result = await FlutterAppIntentsService.donateIntentBatch(
            donations,
          );

          expect(result, isTrue);
          expect(methodCalls, hasLength(1));
          expect(methodCalls.first.method, equals('donateIntentBatch'));

          final arguments = Map<String, dynamic>.from(
            methodCalls.first.arguments as Map<Object?, Object?>,
          );
          final donationsData = arguments['donations'] as List<dynamic>;

          expect(donationsData, hasLength(2));

          final firstDonation = Map<String, dynamic>.from(
            donationsData[0] as Map<Object?, Object?>,
          );
          expect(firstDonation['identifier'], equals('intent1'));
          expect(firstDonation['parameters'], equals({'value': 1}));

          final firstMetadata = Map<String, dynamic>.from(
            firstDonation['metadata'] as Map<Object?, Object?>,
          );
          expect(firstMetadata['relevanceScore'], equals(1.0));
          expect(firstMetadata['context'], equals({'type': 'user'}));
        });

        test('handles empty batch correctly', () async {
          final result = await FlutterAppIntentsService.donateIntentBatch([]);

          expect(result, isTrue);
          final arguments = Map<String, dynamic>.from(
            methodCalls.first.arguments as Map<Object?, Object?>,
          );
          final donationsData = arguments['donations'] as List<dynamic>;
          expect(donationsData, isEmpty);
        });
      });

      group(FlutterAppIntentsService.setIntentHandler, () {
        test('sets up method call handler', () async {
          var handlerCalled = false;
          String? receivedIdentifier;
          Map<String, dynamic>? receivedParameters;

          FlutterAppIntentsService.setIntentHandler((
            identifier,
            parameters,
          ) async {
            handlerCalled = true;
            receivedIdentifier = identifier;
            receivedParameters = parameters;
            return AppIntentResult.successful(value: 'Handler called');
          });

          // Simulate platform calling back
          await TestDefaultBinaryMessengerBinding
              .instance
              .defaultBinaryMessenger
              .handlePlatformMessage(
                'flutter_app_intents',
                const StandardMethodCodec().encodeMethodCall(
                  const MethodCall('handleIntent', {
                    'identifier': 'test_intent',
                    'parameters': {'key': 'value'},
                  }),
                ),
                (data) {},
              );

          expect(handlerCalled, isTrue);
          expect(receivedIdentifier, equals('test_intent'));
          expect(receivedParameters, equals({'key': 'value'}));
        });

        test('handles missing arguments gracefully', () async {
          var handlerCalled = false;

          FlutterAppIntentsService.setIntentHandler((
            identifier,
            parameters,
          ) async {
            handlerCalled = true;
            return AppIntentResult.successful();
          });

          // Simulate platform call with null arguments
          await TestDefaultBinaryMessengerBinding
              .instance
              .defaultBinaryMessenger
              .handlePlatformMessage(
                'flutter_app_intents',
                const StandardMethodCodec().encodeMethodCall(
                  const MethodCall('handleIntent'),
                ),
                (data) {},
              );

          expect(handlerCalled, isFalse);
        });

        test('handles malformed arguments', () async {
          var handlerCalled = false;

          FlutterAppIntentsService.setIntentHandler((
            identifier,
            parameters,
          ) async {
            handlerCalled = true;
            return AppIntentResult.successful();
          });

          // Simulate platform call with malformed arguments
          await TestDefaultBinaryMessengerBinding
              .instance
              .defaultBinaryMessenger
              .handlePlatformMessage(
                'flutter_app_intents',
                const StandardMethodCodec().encodeMethodCall(
                  const MethodCall('handleIntent', {
                    'identifier': null,
                    'parameters': null,
                  }),
                ),
                (data) {},
              );

          expect(handlerCalled, isFalse);
        });

        test('handles handler exceptions', () async {
          FlutterAppIntentsService.setIntentHandler((
            identifier,
            parameters,
          ) async {
            throw Exception('Handler error');
          });

          // This should not throw and should return error result
          await TestDefaultBinaryMessengerBinding
              .instance
              .defaultBinaryMessenger
              .handlePlatformMessage(
                'flutter_app_intents',
                const StandardMethodCodec().encodeMethodCall(
                  const MethodCall('handleIntent', {
                    'identifier': 'test_intent',
                    'parameters': <String, dynamic>{},
                  }),
                ),
                (data) {},
              );

          // Test passes if no exception is thrown
        });
      });
    });
  });

  group(FlutterAppIntentsException, () {
    test('creates exception with message only', () {
      const exception = FlutterAppIntentsException('Test error');

      expect(exception.message, equals('Test error'));
      expect(exception.code, isNull);
      expect(
        exception.toString(),
        equals('FlutterAppIntentsException: Test error'),
      );
    });

    test('creates exception with message and code', () {
      const exception = FlutterAppIntentsException('Test error', 'ERROR_CODE');

      expect(exception.message, equals('Test error'));
      expect(exception.code, equals('ERROR_CODE'));
      expect(
        exception.toString(),
        equals('FlutterAppIntentsException: Test error (ERROR_CODE)'),
      );
    });

    test('implements Exception interface', () {
      const exception = FlutterAppIntentsException('Test');
      expect(exception, isA<Exception>());
    });
  });
}
