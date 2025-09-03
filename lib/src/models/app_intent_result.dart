import 'package:equatable/equatable.dart';

/// Represents the result of executing an App Intent
class AppIntentResult extends Equatable {
  const AppIntentResult({
    required this.success,
    this.value,
    this.error,
    this.needsToContinueInApp = false,
    this.opensIntent,
  });

  /// Whether the intent execution was successful
  final bool success;

  /// The result value (if successful)
  final dynamic value;

  /// Error message (if failed)
  final String? error;

  /// Whether the intent needs to continue in the app
  final bool needsToContinueInApp;

  /// An intent to open if needed
  final String? opensIntent;

  @override
  List<Object?> get props => [
    success,
    value,
    error,
    needsToContinueInApp,
    opensIntent,
  ];

  /// Create a successful result
  static AppIntentResult successful({
    dynamic value,
    bool needsToContinueInApp = false,
    String? opensIntent,
  }) {
    return AppIntentResult(
      success: true,
      value: value,
      needsToContinueInApp: needsToContinueInApp,
      opensIntent: opensIntent,
    );
  }

  /// Create a failed result
  static AppIntentResult failed({required String error}) {
    return AppIntentResult(success: false, error: error);
  }

  /// Convert to a map for platform channel communication
  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'value': value,
      'error': error,
      'needsToContinueInApp': needsToContinueInApp,
      'opensIntent': opensIntent,
    };
  }

  /// Create AppIntentResult from map
  static AppIntentResult fromMap(Map<String, dynamic> map) {
    return AppIntentResult(
      success: map['success'] as bool,
      value: map['value'],
      error: map['error'] as String?,
      needsToContinueInApp: map['needsToContinueInApp'] as bool? ?? false,
      opensIntent: map['opensIntent'] as String?,
    );
  }
}
