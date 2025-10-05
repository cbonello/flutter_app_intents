// Static methods are used for better readability and to provide a more
// expressive API for creating results.
// ignore_for_file: prefer_constructors_over_static_methods

import 'package:equatable/equatable.dart';

/// Represents the result of executing an App Intent, which can be either
/// successful or failed.
class AppIntentResult extends Equatable {
  /// Creates a new [AppIntentResult].
  ///
  /// It is recommended to use the [AppIntentResult.successful] and
  /// [AppIntentResult.failed] factory methods instead of this constructor.
  const AppIntentResult({
    required this.success,
    this.value,
    this.error,
    this.needsToContinueInApp = false,
    this.opensIntent,
  });

  /// Whether the intent execution was successful.
  final bool success;

  /// The result value, if the operation was successful.
  final dynamic value;

  /// A description of the error, if the operation failed.
  final String? error;

  /// Whether the intent needs to continue in the app to complete the action.
  ///
  /// If true, the system may open the app.
  final bool needsToContinueInApp;

  /// An optional intent to open if the action needs to continue in the app.
  ///
  /// This can be used to navigate to a specific screen in the app.
  final String? opensIntent;

  @override
  List<Object?> get props => [
        success,
        value,
        error,
        needsToContinueInApp,
        opensIntent,
      ];

  /// Creates a successful result, optionally with a [value].
  ///
  /// Use [needsToContinueInApp] to indicate that the app should be opened
  /// to fully complete the action.
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

  /// Creates a failed result with a required [error] message.
  static AppIntentResult failed({required String error}) {
    return AppIntentResult(success: false, error: error);
  }

  /// Converts this object to a map suitable for platform channel communication.
  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'value': value,
      'error': error,
      'needsToContinueInApp': needsToContinueInApp,
      'opensIntent': opensIntent,
    };
  }

  /// Creates an [AppIntentResult] from a map, typically received from a
  /// platform channel.
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
