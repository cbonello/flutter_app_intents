import 'dart:async';

import 'package:flutter_app_intents/src/models/app_intent.dart';
import 'package:flutter_app_intents/src/models/app_intent_result.dart';
import 'package:flutter_app_intents/src/models/intent_donation.dart';

/// Signature for intent handler callbacks
typedef IntentHandler = Future<AppIntentResult> Function(
  Map<String, dynamic> parameters,
);

/// Abstract platform interface for App Intents functionality.
///
/// This provides a common API for both iOS (Siri/App Intents) and
/// Android (Google Assistant/App Actions).
///
/// Platform-specific implementations:
/// - iOS: `IOSAppIntentsPlatform`
/// - Android: `AndroidAppActionsPlatform`
abstract class AppIntentsPlatform {
  /// Platform name for debugging and logging
  String get platformName;

  /// Whether this platform supports voice intents
  ///
  /// Returns false if the current OS/version doesn't support
  /// the required APIs.
  bool get isSupported;

  /// Register a single intent with its handler
  ///
  /// The [intent] defines the voice command structure and parameters.
  /// The [handler] is called when the intent is invoked by the user.
  ///
  /// Returns true if registration succeeded.
  ///
  /// Throws [UnsupportedError] if the platform doesn't support intents.
  /// Throws [FlutterAppIntentsException] if registration fails.
  Future<bool> registerIntent(
    AppIntent intent,
    IntentHandler handler,
  );

  /// Register multiple intents with their handlers
  ///
  /// The [intents] list defines all voice commands to register.
  /// The [handlers] map provides the callback for each intent identifier.
  ///
  /// Returns true if all registrations succeeded.
  ///
  /// Throws [UnsupportedError] if the platform doesn't support intents.
  /// Throws [FlutterAppIntentsException] if any registration fails.
  Future<bool> registerIntents(
    List<AppIntent> intents,
    Map<String, IntentHandler> handlers,
  );

  /// Unregister an intent by its identifier
  ///
  /// Removes the intent from the system and its associated handler.
  ///
  /// Returns true if unregistration succeeded.
  Future<bool> unregisterIntent(String identifier);

  /// Get all currently registered intents
  ///
  /// Returns a list of all intents that have been registered
  /// and are currently active on this platform.
  Future<List<AppIntent>> getRegisteredIntents();

  /// Force refresh of system shortcuts/intents
  ///
  /// This tells the system to re-index available intents.
  /// Useful after bulk registration or when debugging.
  ///
  /// Returns true if refresh succeeded.
  Future<bool> updateShortcuts();

  /// Donate an intent execution for ML learning
  ///
  /// Notifies the system that the user performed an action,
  /// helping it learn patterns and provide better predictions.
  ///
  /// The [identifier] is the intent that was executed.
  /// The [parameters] are the values used in this execution.
  /// The [relevanceScore] indicates how relevant this execution was (0.0-1.0).
  ///
  /// Platform differences:
  /// - iOS: Creates an INInteraction donation
  /// - Android: Creates a Shortcut usage report
  Future<bool> donateIntent(
    String identifier,
    Map<String, dynamic> parameters, {
    double relevanceScore = 1.0,
  });

  /// Batch donate multiple intent executions
  ///
  /// More efficient than calling [donateIntent] multiple times.
  ///
  /// The [donations] list contains all executions to donate.
  ///
  /// Returns true if all donations succeeded.
  Future<bool> donateIntentBatch(
    List<IntentDonation> donations,
  );
}

/// Exception thrown when platform operations fail
class FlutterAppIntentsException implements Exception {
  const FlutterAppIntentsException(this.message, [this.code]);

  final String message;
  final String? code;

  @override
  String toString() {
    if (code != null) {
      return 'FlutterAppIntentsException($code): $message';
    }
    return 'FlutterAppIntentsException: $message';
  }
}
