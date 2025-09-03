import 'package:flutter_app_intents/flutter_app_intents.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Intent Donation Enhancement Tests', () {
    group('IntentDonation Factory Constructors', () {
      test('creates high relevance donation correctly', () {
        final donation = IntentDonation.highRelevance(
          identifier: 'test_intent',
          parameters: {'value': 42},
          context: {'source': 'user'},
        );

        expect(donation.identifier, equals('test_intent'));
        expect(donation.parameters, equals({'value': 42}));
        expect(donation.relevanceScore, equals(1.0));
        expect(donation.context, equals({'source': 'user'}));
        expect(donation.timestamp, isNull);
      });

      test('creates medium relevance donation correctly', () {
        final donation = IntentDonation.mediumRelevance(
          identifier: 'medium_intent',
          parameters: {'count': 10},
        );

        expect(donation.identifier, equals('medium_intent'));
        expect(donation.parameters, equals({'count': 10}));
        expect(donation.relevanceScore, equals(0.7));
        expect(donation.context, isEmpty);
      });

      test('creates low relevance donation correctly', () {
        final donation = IntentDonation.lowRelevance(
          identifier: 'low_intent',
          parameters: {'data': 'test'},
        );

        expect(donation.relevanceScore, equals(0.3));
      });

      test('creates user initiated donation correctly', () {
        final donation = IntentDonation.userInitiated(
          identifier: 'user_intent',
          parameters: {},
        );

        expect(donation.relevanceScore, equals(0.9));
      });

      test('creates automated donation correctly', () {
        final donation = IntentDonation.automated(
          identifier: 'auto_intent',
          parameters: {},
        );

        expect(donation.relevanceScore, equals(0.5));
      });

      test('handles custom timestamp correctly', () {
        final now = DateTime.now();
        final donation = IntentDonation.highRelevance(
          identifier: 'timed_intent',
          parameters: {},
          timestamp: now,
        );

        expect(donation.timestamp, equals(now));
      });
    });

    group('IntentDonation Equality and Hashing', () {
      test('equal donations have same hash code', () {
        final donation1 = IntentDonation.highRelevance(
          identifier: 'test',
          parameters: {'key': 'value'},
        );

        final donation2 = IntentDonation.highRelevance(
          identifier: 'test',
          parameters: {'key': 'value'},
        );

        expect(donation1, equals(donation2));
        expect(donation1.hashCode, equals(donation2.hashCode));
      });

      test('different donations are not equal', () {
        final donation1 = IntentDonation.highRelevance(
          identifier: 'test1',
          parameters: {},
        );

        final donation2 = IntentDonation.highRelevance(
          identifier: 'test2',
          parameters: {},
        );

        expect(donation1, isNot(equals(donation2)));
        expect(donation1.hashCode, isNot(equals(donation2.hashCode)));
      });

      test('donations with different relevance scores are not equal', () {
        final donation1 = IntentDonation.highRelevance(
          identifier: 'test',
          parameters: {},
        );

        final donation2 = IntentDonation.mediumRelevance(
          identifier: 'test',
          parameters: {},
        );

        expect(donation1, isNot(equals(donation2)));
      });
    });

    group('IntentDonation toString', () {
      test('includes all properties in string representation', () {
        final now = DateTime.now();
        final donation = IntentDonation(
          identifier: 'test_intent',
          parameters: {'count': 5},
          relevanceScore: 0.8,
          context: {'app': 'test'},
          timestamp: now,
        );

        final str = donation.toString();
        expect(str, contains('test_intent'));
        expect(str, contains('count: 5'));
        expect(str, contains('0.8'));
        expect(str, contains('app: test'));
        expect(str, contains(now.toString()));
      });
    });

    group('Enhanced Donation Service Methods', () {
      test(
        'donateIntentWithMetadata validates relevance score range',
        () async {
          // Test invalid relevance scores (should throw ArgumentError before
          //platform check)
          expect(
            () => FlutterAppIntentsService.donateIntentWithMetadata(
              'test_intent',
              {},
              relevanceScore: -0.1,
            ),
            throwsArgumentError,
          );

          expect(
            () => FlutterAppIntentsService.donateIntentWithMetadata(
              'test_intent',
              {},
              relevanceScore: 1.1,
            ),
            throwsArgumentError,
          );

          // Test valid relevance scores (should throw UnsupportedError on
          // non-iOS)
          expect(
            () => FlutterAppIntentsService.donateIntentWithMetadata(
              'test_intent',
              {},
              relevanceScore: 0,
            ),
            throwsA(isA<UnsupportedError>()),
          );

          expect(
            () => FlutterAppIntentsService.donateIntentWithMetadata(
              'test_intent',
              {},
              // relevanceScore: 1,
            ),
            throwsA(isA<UnsupportedError>()),
          );

          expect(
            () => FlutterAppIntentsService.donateIntentWithMetadata(
              'test_intent',
              {},
              relevanceScore: 0.5,
            ),
            throwsA(isA<UnsupportedError>()),
          );
        },
      );

      test('donateIntentWithMetadata handles default parameters correctly', () {
        // Should throw UnsupportedError on non-iOS platforms
        expect(
          () => FlutterAppIntentsService.donateIntentWithMetadata(
            'test_intent',
            {'param': 'value'},
          ),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('donateIntentBatch handles empty list correctly', () {
        expect(
          () => FlutterAppIntentsService.donateIntentBatch([]),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('donateIntentBatch handles multiple donations correctly', () {
        final donations = [
          IntentDonation.highRelevance(
            identifier: 'intent1',
            parameters: {'value': 1},
          ),
          IntentDonation.mediumRelevance(
            identifier: 'intent2',
            parameters: {'value': 2},
          ),
          IntentDonation.lowRelevance(
            identifier: 'intent3',
            parameters: {'value': 3},
          ),
        ];

        expect(
          () => FlutterAppIntentsService.donateIntentBatch(donations),
          throwsA(isA<UnsupportedError>()),
        );
      });
    });

    group('Platform Support', () {
      test('enhanced donation methods throw UnsupportedError on non-iOS', () {
        // All enhanced donation methods should throw UnsupportedError on
        // non-iOS
        expect(
          () => FlutterAppIntentsService.donateIntentWithMetadata(
            'test_intent',
            {},
          ),
          throwsA(isA<UnsupportedError>()),
        );

        expect(
          () => FlutterAppIntentsService.donateIntentBatch([
            IntentDonation.highRelevance(
              identifier: 'test',
              parameters: {},
            ),
          ]),
          throwsA(isA<UnsupportedError>()),
        );
      });
    });

    group('Metadata Handling', () {
      test('donation metadata is properly structured', () {
        final now = DateTime.now();
        final donation = IntentDonation(
          identifier: 'complex_intent',
          parameters: {
            'stringParam': 'test',
            'intParam': 42,
            'boolParam': true,
            'listParam': [1, 2, 3],
            'mapParam': {'nested': 'value'},
          },
          relevanceScore: 0.75,
          context: {
            'userAction': true,
            'sessionId': 'abc123',
            'feature': 'counter',
          },
          timestamp: now,
        );

        expect(donation.parameters['stringParam'], equals('test'));
        expect(donation.parameters['intParam'], equals(42));
        expect(donation.parameters['boolParam'], isTrue);
        expect(donation.parameters['listParam'], equals([1, 2, 3]));
        expect(donation.parameters['mapParam'], equals({'nested': 'value'}));

        expect(donation.context['userAction'], isTrue);
        expect(donation.context['sessionId'], equals('abc123'));
        expect(donation.context['feature'], equals('counter'));

        expect(donation.relevanceScore, equals(0.75));
        expect(donation.timestamp, equals(now));
      });

      test('handles null and empty metadata gracefully', () {
        const donation = IntentDonation(
          identifier: 'minimal_intent',
          parameters: {},
        );

        expect(donation.parameters, isEmpty);
        expect(donation.context, isEmpty);
        expect(donation.relevanceScore, equals(1.0));
        expect(donation.timestamp, isNull);
      });
    });

    group('Performance and Edge Cases', () {
      test('handles large parameter maps correctly', () {
        final largeParams = <String, dynamic>{};
        for (var i = 0; i < 100; i++) {
          largeParams['param$i'] = 'value$i';
        }

        final donation = IntentDonation(
          identifier: 'large_intent',
          parameters: largeParams,
        );

        expect(donation.parameters.length, equals(100));
        expect(donation.parameters['param0'], equals('value0'));
        expect(donation.parameters['param99'], equals('value99'));
      });

      test('handles special characters in identifiers and parameters', () {
        const donation = IntentDonation(
          identifier: 'special-intent_with.characters',
          parameters: {
            'param with spaces': 'value with spaces',
            'param-with-dashes': 'value-with-dashes',
            'param_with_underscores': 'value_with_underscores',
            'param.with.dots': 'value.with.dots',
            'unicode_param_🚀': 'unicode_value_🎉',
          },
        );

        expect(donation.identifier, equals('special-intent_with.characters'));
        expect(
          donation.parameters['param with spaces'],
          equals('value with spaces'),
        );
        expect(
          donation.parameters['unicode_param_🚀'],
          equals('unicode_value_🎉'),
        );
      });

      test('batch donation with mixed relevance scores', () {
        final donations = List.generate(10, (index) {
          final relevance = index / 10.0; // 0.0 to 0.9
          return IntentDonation(
            identifier: 'intent_$index',
            parameters: {'index': index},
            relevanceScore: relevance,
          );
        });

        expect(donations.length, equals(10));
        expect(donations.first.relevanceScore, equals(0.0));
        expect(donations.last.relevanceScore, equals(0.9));

        // On non-iOS platforms, should throw UnsupportedError
        expect(
          () => FlutterAppIntentsService.donateIntentBatch(donations),
          throwsA(isA<UnsupportedError>()),
        );
      });
    });

    group('Integration with Existing APIs', () {
      test('legacy donateIntent throws UnsupportedError on non-iOS', () {
        expect(
          () => FlutterAppIntentsService.donateIntent('legacy_intent', {}),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('enhanced donation has same error handling as legacy', () {
        // Both should throw UnsupportedError on non-iOS
        expect(
          () => FlutterAppIntentsService.donateIntent('intent', {}),
          throwsA(isA<UnsupportedError>()),
        );

        expect(
          () => FlutterAppIntentsService.donateIntentWithMetadata(
            'intent',
            {},
          ),
          throwsA(isA<UnsupportedError>()),
        );
      });
    });
  });
}
