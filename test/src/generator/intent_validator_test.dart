import 'package:flutter_app_intents/src/generator/intent_extractor.dart';
import 'package:flutter_app_intents/src/generator/intent_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(IntentValidator, () {
    group('Android validation', () {
      late IntentValidator validator;

      setUp(() {
        validator = IntentValidator(targetPlatform: 'android');
      });

      test('validates required fields', () {
        final intent = ExtractedIntent()
          ..identifier = 'test_intent'
          ..title = 'Test Intent'
          ..description = 'A test intent'
          ..category = 'general';

        final errors = validator.validate(intent);

        expect(errors, isEmpty);
      });

      test('reports error when identifier is missing', () {
        final intent = ExtractedIntent()
          ..title = 'Test Intent'
          ..description = 'A test intent'
          ..category = 'general';

        final errors = validator.validate(intent);

        expect(errors, hasLength(1));
        expect(errors.first.message, contains('identifier'));
        expect(errors.first.hint, contains('.identifier('));
      });

      test('reports error when title is missing', () {
        final intent = ExtractedIntent()
          ..identifier = 'test_intent'
          ..description = 'A test intent'
          ..category = 'general';

        final errors = validator.validate(intent);

        expect(errors, hasLength(1));
        expect(errors.first.message, contains('title'));
        expect(errors.first.hint, contains('.title('));
      });

      test('reports error when description is missing', () {
        final intent = ExtractedIntent()
          ..identifier = 'test_intent'
          ..title = 'Test Intent'
          ..category = 'general';

        final errors = validator.validate(intent);

        expect(errors, hasLength(1));
        expect(errors.first.message, contains('description'));
        expect(errors.first.hint, contains('.description('));
      });

      test('reports error when category is missing for Android', () {
        final intent = ExtractedIntent()
          ..identifier = 'test_intent'
          ..title = 'Test Intent'
          ..description = 'A test intent';

        final errors = validator.validate(intent);

        expect(errors, hasLength(1));
        expect(errors.first.message, contains('Category is required'));
        expect(errors.first.hint, contains('category'));
        expect(errors.first.hint, contains('optional for iOS'));
      });

      test('reports multiple errors when multiple fields missing', () {
        final intent = ExtractedIntent();

        final errors = validator.validate(intent);

        expect(errors.length, greaterThanOrEqualTo(3));
        expect(
          errors.any((e) => e.message.contains('identifier')),
          isTrue,
        );
        expect(
          errors.any((e) => e.message.contains('title')),
          isTrue,
        );
        expect(
          errors.any((e) => e.message.contains('description')),
          isTrue,
        );
      });
    });

    group('iOS validation', () {
      late IntentValidator validator;

      setUp(() {
        validator = IntentValidator(targetPlatform: 'ios');
      });

      test('validates intent without category for iOS', () {
        final intent = ExtractedIntent()
          ..identifier = 'test_intent'
          ..title = 'Test Intent'
          ..description = 'A test intent';

        final errors = validator.validate(intent);

        expect(errors, isEmpty);
      });

      test('still validates required core fields for iOS', () {
        final intent = ExtractedIntent()..category = 'general';

        final errors = validator.validate(intent);

        expect(errors.length, greaterThanOrEqualTo(3));
      });
    });

    group('Duplicate identifier detection', () {
      test('detects duplicate identifiers across intents', () {
        final validator = IntentValidator(targetPlatform: 'android');
        final intents = [
          ExtractedIntent()
            ..identifier = 'duplicate_id'
            ..title = 'First Intent'
            ..description = 'First'
            ..category = 'general',
          ExtractedIntent()
            ..identifier = 'duplicate_id'
            ..title = 'Second Intent'
            ..description = 'Second'
            ..category = 'fitness',
        ];

        final errors = validator.validateAll(intents);

        expect(
          errors.any((e) => e.message.contains('Duplicate intent identifier')),
          isTrue,
        );
        expect(
          errors
              .firstWhere((e) => e.message.contains('Duplicate'))
              .message
              .contains('2 occurrences'),
          isTrue,
        );
      });

      test('provides helpful hint for duplicate identifiers', () {
        final validator = IntentValidator(targetPlatform: 'android');
        final intents = [
          ExtractedIntent()
            ..identifier = 'same_id'
            ..title = 'First'
            ..description = 'First'
            ..category = 'general',
          ExtractedIntent()
            ..identifier = 'same_id'
            ..title = 'Second'
            ..description = 'Second'
            ..category = 'general',
        ];

        final errors = validator.validateAll(intents);

        final duplicateError = errors.firstWhere(
          (e) => e.message.contains('Duplicate'),
        );
        expect(duplicateError.hint, contains('unique identifier'));
        expect(duplicateError.hint, contains('rename'));
      });

      test('detects multiple duplicates correctly', () {
        final validator = IntentValidator(targetPlatform: 'android');
        final intents = [
          ExtractedIntent()
            ..identifier = 'dup1'
            ..title = 'A'
            ..description = 'A'
            ..category = 'general',
          ExtractedIntent()
            ..identifier = 'dup1'
            ..title = 'B'
            ..description = 'B'
            ..category = 'general',
          ExtractedIntent()
            ..identifier = 'dup2'
            ..title = 'C'
            ..description = 'C'
            ..category = 'general',
          ExtractedIntent()
            ..identifier = 'dup2'
            ..title = 'D'
            ..description = 'D'
            ..category = 'general',
        ];

        final errors = validator.validateAll(intents);

        final duplicateErrors = errors.where(
          (e) => e.message.contains('Duplicate'),
        );
        expect(duplicateErrors.length, equals(2));
      });

      test('does not report error for unique identifiers', () {
        final validator = IntentValidator(targetPlatform: 'android');
        final intents = [
          ExtractedIntent()
            ..identifier = 'intent_one'
            ..title = 'First'
            ..description = 'First'
            ..category = 'general',
          ExtractedIntent()
            ..identifier = 'intent_two'
            ..title = 'Second'
            ..description = 'Second'
            ..category = 'general',
        ];

        final errors = validator.validateAll(intents);

        expect(
          errors.any((e) => e.message.contains('Duplicate')),
          isFalse,
        );
      });

      test('handles intents with null identifiers gracefully', () {
        final validator = IntentValidator(targetPlatform: 'android');
        final intents = [
          ExtractedIntent()
            ..title = 'No ID 1'
            ..description = 'First'
            ..category = 'general',
          ExtractedIntent()
            ..title = 'No ID 2'
            ..description = 'Second'
            ..category = 'general',
        ];

        // Should not crash, but should report missing identifiers
        final errors = validator.validateAll(intents);

        expect(
          errors.where((e) => e.message.contains('identifier')).length,
          equals(2),
        );
      });
    });

    group('validateAll', () {
      test('combines individual and duplicate validation errors', () {
        final validator = IntentValidator(targetPlatform: 'android');
        final intents = [
          ExtractedIntent()
            ..identifier = 'missing_fields'
            ..category = 'general',
          ExtractedIntent()
            ..identifier = 'duplicate'
            ..title = 'First'
            ..description = 'First'
            ..category = 'general',
          ExtractedIntent()
            ..identifier = 'duplicate'
            ..title = 'Second'
            ..description = 'Second'
            ..category = 'general',
        ];

        final errors = validator.validateAll(intents);

        // Should have errors for missing fields AND duplicates
        expect(
          errors.any((e) => e.message.contains('title')),
          isTrue,
        );
        expect(
          errors.any((e) => e.message.contains('Duplicate')),
          isTrue,
        );
      });

      test('returns empty list for valid intents', () {
        final validator = IntentValidator(targetPlatform: 'android');
        final intents = [
          ExtractedIntent()
            ..identifier = 'intent_one'
            ..title = 'First'
            ..description = 'First'
            ..category = 'general',
          ExtractedIntent()
            ..identifier = 'intent_two'
            ..title = 'Second'
            ..description = 'Second'
            ..category = 'fitness',
        ];

        final errors = validator.validateAll(intents);

        expect(errors, isEmpty);
      });

      test('handles empty intent list', () {
        final validator = IntentValidator(targetPlatform: 'android');

        final errors = validator.validateAll([]);

        expect(errors, isEmpty);
      });
    });

    group('Error information', () {
      test('includes intent identifier in error', () {
        final validator = IntentValidator(targetPlatform: 'android');
        final intent = ExtractedIntent()
          ..identifier = 'test_intent'
          ..category = 'general';

        final errors = validator.validate(intent);

        expect(errors.first.intent, contains('test_intent'));
      });

      test('includes helpful hints in errors', () {
        final validator = IntentValidator(targetPlatform: 'android');
        final intent = ExtractedIntent()..identifier = 'test';

        final errors = validator.validate(intent);

        expect(
          errors.every((e) => e.hint != null && e.hint!.isNotEmpty),
          isTrue,
        );
      });
    });
  });
}
