import 'package:flutter_app_intents/src/models/intent_donation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(IntentDonation, () {
    test('default constructor sets values correctly', () {
      final now = DateTime.now();
      final donation = IntentDonation(
        identifier: 'test',
        parameters: const {'key': 'value'},
        relevanceScore: 0.8,
        context: const {'contextKey': 'contextValue'},
        timestamp: now,
      );

      expect(donation.identifier, 'test');
      expect(donation.parameters, const {'key': 'value'});
      expect(donation.relevanceScore, 0.8);
      expect(donation.context, const {'contextKey': 'contextValue'});
      expect(donation.timestamp, now);
    });

    test('throws assertion error for invalid relevanceScore', () {
      expect(
        () => IntentDonation(
          identifier: 'test',
          parameters: const {},
          relevanceScore: -0.1,
        ),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => IntentDonation(
          identifier: 'test',
          parameters: const {},
          relevanceScore: 1.1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('highRelevance() constructor sets score to 1.0', () {
      const donation = IntentDonation.highRelevance(
        identifier: 'test',
        parameters: {},
      );
      expect(donation.relevanceScore, 1.0);
    });

    test('mediumRelevance() constructor sets score to 0.7', () {
      const donation = IntentDonation.mediumRelevance(
        identifier: 'test',
        parameters: {},
      );
      expect(donation.relevanceScore, 0.7);
    });

    test('lowRelevance constructor sets score to 0.3', () {
      const donation = IntentDonation.lowRelevance(
        identifier: 'test',
        parameters: {},
      );
      expect(donation.relevanceScore, 0.3);
    });

    test('userInitiated() constructor sets score to 0.9', () {
      const donation = IntentDonation.userInitiated(
        identifier: 'test',
        parameters: {},
      );
      expect(donation.relevanceScore, 0.9);
    });

    test('automated() constructor sets score to 0.5', () {
      const donation = IntentDonation.automated(
        identifier: 'test',
        parameters: {},
      );
      expect(donation.relevanceScore, 0.5);
    });

    test('props[] are correct for equatable', () {
      final now = DateTime.now();
      final donation1 = IntentDonation(
        identifier: 'test',
        parameters: const {'key': 'value'},
        timestamp: now,
      );
      final donation2 = IntentDonation(
        identifier: 'test',
        parameters: const {'key': 'value'},
        timestamp: now,
      );
      expect(donation1, equals(donation2));
    });

    test('toString() includes all properties', () {
      final now = DateTime.now();
      final donation = IntentDonation(
        identifier: 'test_intent',
        parameters: const {'param': 'value'},
        relevanceScore: 0.75,
        context: const {'ctx': 'data'},
        timestamp: now,
      );

      final str = donation.toString();
      expect(str, contains('IntentDonation('));
      expect(str, contains('identifier: test_intent'));
      expect(str, contains('parameters: {param: value}'));
      expect(str, contains('relevanceScore: 0.75'));
      expect(str, contains('context: {ctx: data}'));
      expect(str, contains('timestamp: $now'));
    });

    test('named constructors support context and timestamp', () {
      final now = DateTime.now();

      final highRel = IntentDonation.highRelevance(
        identifier: 'test',
        parameters: const {},
        context: const {'key': 'value'},
        timestamp: now,
      );
      expect(highRel.context, const {'key': 'value'});
      expect(highRel.timestamp, now);

      final mediumRel = IntentDonation.mediumRelevance(
        identifier: 'test',
        parameters: const {},
        context: const {'key': 'value'},
        timestamp: now,
      );
      expect(mediumRel.context, const {'key': 'value'});
      expect(mediumRel.timestamp, now);

      final lowRel = IntentDonation.lowRelevance(
        identifier: 'test',
        parameters: const {},
        context: const {'key': 'value'},
        timestamp: now,
      );
      expect(lowRel.context, const {'key': 'value'});
      expect(lowRel.timestamp, now);

      final userInit = IntentDonation.userInitiated(
        identifier: 'test',
        parameters: const {},
        context: const {'key': 'value'},
        timestamp: now,
      );
      expect(userInit.context, const {'key': 'value'});
      expect(userInit.timestamp, now);

      final auto = IntentDonation.automated(
        identifier: 'test',
        parameters: const {},
        context: const {'key': 'value'},
        timestamp: now,
      );
      expect(auto.context, const {'key': 'value'});
      expect(auto.timestamp, now);
    });

    test('default constructor uses correct default values', () {
      const donation = IntentDonation(
        identifier: 'test',
        parameters: <String, dynamic>{},
      );

      expect(donation.relevanceScore, 1.0);
      expect(donation.context, const <String, dynamic>{});
      expect(donation.timestamp, isNull);
    });

    test('equatable compares all fields correctly', () {
      final now = DateTime.now();
      final donation1 = IntentDonation(
        identifier: 'test',
        parameters: const {'key': 'value'},
        relevanceScore: 0.8,
        context: const {'ctx': 'val'},
        timestamp: now,
      );

      // Same values - should be equal
      final donation2 = IntentDonation(
        identifier: 'test',
        parameters: const {'key': 'value'},
        relevanceScore: 0.8,
        context: const {'ctx': 'val'},
        timestamp: now,
      );
      expect(donation1, equals(donation2));

      // Different identifier
      final donation3 = IntentDonation(
        identifier: 'different',
        parameters: const {'key': 'value'},
        relevanceScore: 0.8,
        context: const {'ctx': 'val'},
        timestamp: now,
      );
      expect(donation1, isNot(equals(donation3)));

      // Different parameters
      final donation4 = IntentDonation(
        identifier: 'test',
        parameters: const {'different': 'value'},
        relevanceScore: 0.8,
        context: const {'ctx': 'val'},
        timestamp: now,
      );
      expect(donation1, isNot(equals(donation4)));

      // Different relevance score
      final donation5 = IntentDonation(
        identifier: 'test',
        parameters: const {'key': 'value'},
        relevanceScore: 0.9,
        context: const {'ctx': 'val'},
        timestamp: now,
      );
      expect(donation1, isNot(equals(donation5)));

      // Different context
      final donation6 = IntentDonation(
        identifier: 'test',
        parameters: const {'key': 'value'},
        relevanceScore: 0.8,
        context: const {'different': 'val'},
        timestamp: now,
      );
      expect(donation1, isNot(equals(donation6)));

      // Different timestamp
      final donation7 = IntentDonation(
        identifier: 'test',
        parameters: const {'key': 'value'},
        relevanceScore: 0.8,
        context: const {'ctx': 'val'},
        timestamp: now.add(const Duration(seconds: 1)),
      );
      expect(donation1, isNot(equals(donation7)));
    });
  });
}
