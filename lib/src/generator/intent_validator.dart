import 'package:flutter_app_intents/src/generator/android/resource_naming.dart';
import 'package:flutter_app_intents/src/generator/shared/intent_extractor.dart';

/// Validates intent definitions for platform-specific requirements.
class IntentValidator {
  /// Creates a new validator for a specific [targetPlatform].
  IntentValidator({required this.targetPlatform});

  /// The platform to validate against, e.g., 'android' or 'ios'.
  final String targetPlatform;

  /// Validates a list of intents, checking for both individual errors and
  /// cross-intent issues like duplicate identifiers.
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

  /// Validates a single intent for required fields and platform-specific rules.
  List<ValidationError> validate(ExtractedIntent intent) {
    final errors = <ValidationError>[];

    // Required fields — check for null and empty/whitespace-only strings
    if (intent.identifier == null || intent.identifier!.trim().isEmpty) {
      errors.add(
        ValidationError(
          intent: intent.toString(),
          message: 'Missing required field: identifier',
          hint: 'Add .identifier("my_intent_id") to your AppIntentBuilder',
        ),
      );
    }

    if (intent.title == null || intent.title!.trim().isEmpty) {
      errors.add(
        ValidationError(
          intent: intent.toString(),
          message: 'Missing required field: title',
          hint: 'Add .title("My Intent Title") to your AppIntentBuilder',
        ),
      );
    }

    if (intent.description == null || intent.description!.trim().isEmpty) {
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

    // Identifier must be a valid Android resource name
    final identifier = intent.identifier;
    if (identifier != null &&
        !ResourceNaming.isValidResourceName(identifier)) {
      errors.add(
        ValidationError(
          intent: identifier,
          message: 'Identifier "$identifier" is not a valid Android resource '
              'name. Must contain only lowercase letters (a-z), digits (0-9), '
              'and underscores, and must start with a letter or underscore.',
          hint: 'Rename to something like '
              '"${_suggestValidIdentifier(identifier)}".',
        ),
      );
    }

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

  /// Suggests a valid Android resource name from an invalid identifier.
  String _suggestValidIdentifier(String identifier) {
    // Convert camelCase/PascalCase to snake_case, strip invalid chars
    final snaked = identifier
        .replaceAllMapped(
          RegExp('([a-z])([A-Z])'),
          (m) => '${m[1]}_${m[2]}',
        )
        .toLowerCase()
        .replaceAll(RegExp('[^a-z0-9_]'), '_')
        .replaceAll(RegExp('_+'), '_');

    // Ensure it starts with a letter or underscore
    if (snaked.isNotEmpty && RegExp('[0-9]').hasMatch(snaked[0])) {
      return '_$snaked';
    }
    return snaked.isEmpty ? 'my_intent' : snaked;
  }

  /// iOS-specific validation
  List<ValidationError> _validateIOS(ExtractedIntent intent) {
    // iOS doesn't have additional requirements beyond the core fields
    return [];
  }
}

/// Represents a single validation error found in an intent definition.
class ValidationError {
  /// Creates a new validation error.
  ValidationError({
    required this.intent,
    required this.message,
    this.hint,
  });

  /// The identifier of the intent that has an error.
  final String intent;

  /// A description of the validation error.
  final String message;

  /// An optional hint on how to fix the error.
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
