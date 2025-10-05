import 'package:flutter_app_intents/src/generator/intent_extractor.dart';

/// Validates intent definitions for platform-specific requirements
class IntentValidator {
  IntentValidator({required this.targetPlatform});

  final String targetPlatform;

  /// Validate all intents
  List<ValidationError> validateAll(List<ExtractedIntent> intents) {
    final errors = <ValidationError>[];

    // Validate each intent individually
    for (final intent in intents) {
      errors.addAll(validate(intent));
    }

    // Check for duplicate identifiers across all intents
    final identifierMap = <String, List<ExtractedIntent>>{};
    for (final intent in intents) {
      final identifier = intent.identifier;
      if (identifier != null) {
        identifierMap.putIfAbsent(identifier, () => []).add(intent);
      }
    }

    // Report duplicates
    for (final entry in identifierMap.entries) {
      if (entry.value.length > 1) {
        errors.add(
          ValidationError(
            intent: entry.key,
            message: 'Duplicate intent identifier found '
                '(${entry.value.length} occurrences)',
            hint: 'Each intent must have a unique identifier. '
                'Please rename one of the duplicate intents.',
          ),
        );
      }
    }

    return errors;
  }

  /// Validate a single intent
  List<ValidationError> validate(ExtractedIntent intent) {
    final errors = <ValidationError>[];

    // Required fields
    if (intent.identifier == null) {
      errors.add(
        ValidationError(
          intent: intent.toString(),
          message: 'Missing required field: identifier',
          hint: 'Add .identifier("my_intent_id") to your AppIntentBuilder',
        ),
      );
    }

    if (intent.title == null) {
      errors.add(
        ValidationError(
          intent: intent.toString(),
          message: 'Missing required field: title',
          hint: 'Add .title("My Intent Title") to your AppIntentBuilder',
        ),
      );
    }

    if (intent.description == null) {
      errors.add(
        ValidationError(
          intent: intent.toString(),
          message: 'Missing required field: description',
          hint: 'Add .description("What this intent does") to your '
              'AppIntentBuilder',
        ),
      );
    }

    // Platform-specific validation
    if (targetPlatform == 'android') {
      errors.addAll(_validateAndroid(intent));
    } else if (targetPlatform == 'ios') {
      errors.addAll(_validateIOS(intent));
    }

    return errors;
  }

  /// Android-specific validation
  List<ValidationError> _validateAndroid(ExtractedIntent intent) {
    final errors = <ValidationError>[];

    // Category is required for Android (BII mapping)
    if (intent.category == null) {
      errors.add(
        ValidationError(
          intent: intent.identifier ?? 'unknown',
          message: 'Category is required for Android (BII mapping)',
          hint: 'Add .category(IntentCategory.general) or another category. '
              'Note: category is optional for iOS.',
        ),
      );
    }

    return errors;
  }

  /// iOS-specific validation
  List<ValidationError> _validateIOS(ExtractedIntent intent) {
    // iOS doesn't have additional requirements beyond the core fields
    return [];
  }
}

/// Represents a validation error
class ValidationError {
  ValidationError({
    required this.intent,
    required this.message,
    this.hint,
  });

  final String intent;
  final String message;
  final String? hint;

  @override
  String toString() {
    final buffer = StringBuffer('$intent: $message');
    if (hint != null) {
      buffer.write('\n  💡 $hint');
    }
    return buffer.toString();
  }
}
