import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Platform-specific hints for intent configuration
///
/// Allows advanced developers to provide platform-specific customizations
/// while keeping the core intent definition platform-agnostic.
///
/// Example:
/// ```dart
/// final intent = AppIntentBuilder()
///     .identifier('start_workout')
///     .title('Start Workout')
///     .category(IntentCategory.fitness)
///     .hints(PlatformHints(
///       iosSuggestedPhrase: 'Begin my workout routine',
///       androidBIIOverride: 'actions.intent.START_EXERCISE',
///       androidExtras: {'custom_param': 'value'},
///     ))
///     .build();
/// ```
@immutable
class PlatformHints extends Equatable {
  const PlatformHints({
    this.iosSuggestedPhrase,
    this.androidBIIOverride,
    this.androidExtras,
  });

  /// Create from map
  factory PlatformHints.fromMap(Map<String, dynamic> map) {
    return PlatformHints(
      iosSuggestedPhrase: map['iosSuggestedPhrase'] as String?,
      androidBIIOverride: map['androidBIIOverride'] as String?,
      androidExtras: map['androidExtras'] != null
          ? (map['androidExtras'] is Map<String, dynamic>
              ? map['androidExtras'] as Map<String, dynamic>
              : Map<String, dynamic>.from(
                  map['androidExtras'] as Map<Object?, Object?>,
                ))
          : null,
    );
  }

  /// Suggested Siri phrase for iOS App Shortcuts
  ///
  /// If provided, this phrase will be suggested to users when they
  /// add the intent to Siri.
  ///
  /// Example: "Start my morning routine"
  ///
  /// Platform: iOS only (ignored on Android)
  final String? iosSuggestedPhrase;

  /// Override the automatic BII mapping for Android
  ///
  /// By default, the category determines the BII action.
  /// Use this to specify a different BII action manually.
  ///
  /// Example: "actions.intent.CUSTOM_ACTION"
  ///
  /// Platform: Android only (ignored on iOS)
  final String? androidBIIOverride;

  /// Additional Android-specific parameters
  ///
  /// Custom key-value pairs to include in the shortcuts.xml
  /// for advanced Android App Actions configuration.
  ///
  /// Platform: Android only (ignored on iOS)
  final Map<String, dynamic>? androidExtras;

  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      if (iosSuggestedPhrase != null) 'iosSuggestedPhrase': iosSuggestedPhrase,
      if (androidBIIOverride != null) 'androidBIIOverride': androidBIIOverride,
      if (androidExtras != null) 'androidExtras': androidExtras,
    };
  }

  /// Create a copy with updated fields
  PlatformHints copyWith({
    String? iosSuggestedPhrase,
    String? androidBIIOverride,
    Map<String, dynamic>? androidExtras,
  }) {
    return PlatformHints(
      iosSuggestedPhrase: iosSuggestedPhrase ?? this.iosSuggestedPhrase,
      androidBIIOverride: androidBIIOverride ?? this.androidBIIOverride,
      androidExtras: androidExtras ?? this.androidExtras,
    );
  }

  @override
  List<Object?> get props => [
        iosSuggestedPhrase,
        androidBIIOverride,
        androidExtras,
      ];
}
