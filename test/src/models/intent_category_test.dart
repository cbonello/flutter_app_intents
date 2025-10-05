import 'package:flutter_app_intents/src/models/intent_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(IntentCategory, () {
    test('androidBII returns non-empty string for all categories', () {
      for (final category in IntentCategory.values) {
        expect(category.androidBII, isNotEmpty);
      }
    });

    test('displayName returns non-empty string for all categories', () {
      for (final category in IntentCategory.values) {
        expect(category.displayName, isNotEmpty);
      }
    });

    test('androidBII returns correct values', () {
      expect(
        IntentCategory.general.androidBII,
        equals('actions.intent.OPEN_APP_FEATURE'),
      );
      expect(
        IntentCategory.fitness.androidBII,
        equals('actions.intent.START_EXERCISE'),
      );
      expect(
        IntentCategory.messaging.androidBII,
        equals('actions.intent.SEND_MESSAGE'),
      );
    });
  });
}
