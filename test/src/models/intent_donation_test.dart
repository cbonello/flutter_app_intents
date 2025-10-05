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
  });
}
