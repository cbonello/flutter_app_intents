import 'package:equatable/equatable.dart';

import 'package:flutter_app_intents/src/models/app_intent_parameter.dart';
import 'package:flutter_app_intents/src/models/intent_category.dart';
import 'package:flutter_app_intents/src/models/platform_hints.dart';

/// Represents an App Intent that can be registered with voice assistants
///
/// Supports both iOS (Siri/App Intents) and Android (Google Assistant/App Actions).
class AppIntent extends Equatable {
  const AppIntent({
    required this.identifier,
    required this.title,
    required this.description,
    this.parameters = const [],
    this.category,
    this.hints,
    this.isEligibleForSearch = true,
    this.isEligibleForPrediction = true,
    this.authenticationPolicy = AuthenticationPolicy.none,
    this.presentsResult = false,
  });

  /// Creates AppIntent from a map representation
  AppIntent.fromMap(Map<String, dynamic> map)
      : identifier = map['identifier'] as String,
        title = map['title'] as String,
        description = map['description'] as String,
        parameters = (map['parameters'] as List<dynamic>?)?.map((p) {
              if (p is Map<String, dynamic>) {
                return AppIntentParameter.fromMap(p);
              } else {
                return AppIntentParameter.fromMap(
                  Map<String, dynamic>.from(p as Map<Object?, Object?>),
                );
              }
            }).toList() ??
            [],
        category = map['category'] != null
            ? IntentCategory.values.firstWhere(
                (c) => c.name == map['category'],
                orElse: () => IntentCategory.general,
              )
            : null,
        hints = map['hints'] != null
            ? PlatformHints.fromMap(
                map['hints'] as Map<String, dynamic>,
              )
            : null,
        isEligibleForSearch = map['isEligibleForSearch'] as bool? ?? true,
        isEligibleForPrediction =
            map['isEligibleForPrediction'] as bool? ?? true,
        authenticationPolicy = map['authenticationPolicy'] != null
            ? AuthenticationPolicy.values.firstWhere(
                (policy) => policy.name == map['authenticationPolicy'],
                orElse: () => AuthenticationPolicy.none,
              )
            : AuthenticationPolicy.none,
        presentsResult = map['presentsResult'] as bool? ?? false;

  /// Unique identifier for the intent
  final String identifier;

  /// Display title for the intent
  final String title;

  /// Description of what the intent does
  final String description;

  /// Parameters that can be passed to the intent
  final List<AppIntentParameter> parameters;

  /// Category for intent classification and BII mapping
  ///
  /// Optional for iOS (custom intents don't need categories).
  /// Required for Android when generating shortcuts.xml (validates at
  /// build-time).
  ///
  /// Defaults to [IntentCategory.general] if not specified on Android.
  final IntentCategory? category;

  /// Platform-specific customization hints
  ///
  /// Allows advanced configuration for each platform while keeping
  /// the core intent definition platform-agnostic.
  final PlatformHints? hints;

  /// Whether the intent can appear in Spotlight search results
  final bool isEligibleForSearch;

  /// Whether the intent can be predicted by Siri
  final bool isEligibleForPrediction;

  /// Authentication policy for the intent
  final AuthenticationPolicy authenticationPolicy;

  /// Whether the intent should present its result in a dialog (iOS only)
  ///
  /// **Platform Support:**
  /// - ✅ **iOS**: Supported - shows result in dialog or opens app silently
  /// - ❌ **Android**: Not supported - always opens app (widgets planned for future)
  ///
  /// - `false` (default): Action intents that just open the app silently
  ///   (e.g., "Increment Counter", "Send Message")
  /// - `true`: Query intents that display a result to the user
  ///   (e.g., "Get Counter Value", "Check Weather")
  ///
  /// This controls the iOS App Intent behavior:
  /// - Action intents return immediately and open the app
  /// - Query intents show a dialog with the result value
  final bool presentsResult;

  @override
  List<Object?> get props => [
        identifier,
        title,
        description,
        parameters,
        category,
        hints,
        isEligibleForSearch,
        isEligibleForPrediction,
        authenticationPolicy,
        presentsResult,
      ];

  /// Creates a copy of this AppIntent with the given fields replaced
  AppIntent copyWith({
    String? identifier,
    String? title,
    String? description,
    List<AppIntentParameter>? parameters,
    IntentCategory? category,
    PlatformHints? hints,
    bool? isEligibleForSearch,
    bool? isEligibleForPrediction,
    AuthenticationPolicy? authenticationPolicy,
    bool? presentsResult,
  }) {
    return AppIntent(
      identifier: identifier ?? this.identifier,
      title: title ?? this.title,
      description: description ?? this.description,
      parameters: parameters ?? this.parameters,
      category: category ?? this.category,
      hints: hints ?? this.hints,
      isEligibleForSearch: isEligibleForSearch ?? this.isEligibleForSearch,
      isEligibleForPrediction:
          isEligibleForPrediction ?? this.isEligibleForPrediction,
      authenticationPolicy: authenticationPolicy ?? this.authenticationPolicy,
      presentsResult: presentsResult ?? this.presentsResult,
    );
  }

  /// Convert to a map for platform channel communication
  Map<String, dynamic> toMap() {
    return {
      'identifier': identifier,
      'title': title,
      'description': description,
      'parameters': parameters.map((p) => p.toMap()).toList(),
      if (category != null) 'category': category!.name,
      if (hints != null) 'hints': hints!.toMap(),
      'isEligibleForSearch': isEligibleForSearch,
      'isEligibleForPrediction': isEligibleForPrediction,
      'authenticationPolicy': authenticationPolicy.name,
      'presentsResult': presentsResult,
    };
  }
}

/// Authentication policy for App Intents
enum AuthenticationPolicy {
  /// No authentication required
  none,

  /// User must be authenticated to the device
  requiresAuthentication,

  /// User must unlock the device to run the intent
  requiresUnlockedDevice,
}
