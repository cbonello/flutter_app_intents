// ignore_for_file: avoid_returning_this
// ignore_for_file: prefer_constructors_over_static_methods

import 'dart:async';

import 'package:flutter_app_intents/src/models/app_intent.dart';
import 'package:flutter_app_intents/src/models/app_intent_parameter.dart';
import 'package:flutter_app_intents/src/models/app_intent_result.dart';
import 'package:flutter_app_intents/src/services/flutter_app_intents_service.dart';

/// High-level client for managing App Intents
class FlutterAppIntentsClient {
  FlutterAppIntentsClient._();

  static FlutterAppIntentsClient? _instance;

  /// Get the singleton instance
  static FlutterAppIntentsClient get instance =>
      _instance ??= FlutterAppIntentsClient._();

  final Map<String, Future<AppIntentResult> Function(Map<String, dynamic>)>
  _intentHandlers = {};

  /// Register an intent with a handler function
  Future<bool> registerIntent(
    AppIntent intent,
    Future<AppIntentResult> Function(Map<String, dynamic> parameters) handler,
  ) async {
    // Store the handler
    _intentHandlers[intent.identifier] = handler;

    // Set up the global handler if not already done
    if (_intentHandlers.length == 1) {
      FlutterAppIntentsService.setIntentHandler(_handleIntent);
    }

    // Register with the iOS system
    return FlutterAppIntentsService.registerIntent(intent);
  }

  /// Register multiple intents
  Future<bool> registerIntents(
    Map<AppIntent, Future<AppIntentResult> Function(Map<String, dynamic>)>
    intentsWithHandlers,
  ) async {
    // Store all handlers
    for (final entry in intentsWithHandlers.entries) {
      _intentHandlers[entry.key.identifier] = entry.value;
    }

    // Set up the global handler if not already done
    if (_intentHandlers.isNotEmpty) {
      FlutterAppIntentsService.setIntentHandler(_handleIntent);
    }

    // Register with the iOS system
    return FlutterAppIntentsService.registerIntents(
      intentsWithHandlers.keys.toList(),
    );
  }

  /// Unregister an intent
  Future<bool> unregisterIntent(String identifier) async {
    _intentHandlers.remove(identifier);

    return FlutterAppIntentsService.unregisterIntent(identifier);
  }

  /// Get all registered intents
  Future<List<AppIntent>> getRegisteredIntents() async {
    return FlutterAppIntentsService.getRegisteredIntents();
  }

  /// Update app shortcuts
  Future<bool> updateShortcuts() async {
    return FlutterAppIntentsService.updateShortcuts();
  }

  /// Donate an intent execution to help Siri learn
  Future<bool> donateIntent(
    String identifier,
    Map<String, dynamic> parameters,
  ) async {
    return FlutterAppIntentsService.donateIntent(identifier, parameters);
  }

  /// Internal handler that routes to the appropriate intent handler
  Future<AppIntentResult> _handleIntent(
    String identifier,
    Map<String, dynamic> parameters,
  ) async {
    final handler = _intentHandlers[identifier];
    if (handler == null) {
      return AppIntentResult.failed(
        error: 'No handler registered for intent: $identifier',
      );
    }

    try {
      return await handler(parameters);
    } on Object catch (e) {
      return AppIntentResult.failed(error: 'Intent handler failed: $e');
    }
  }
}

/// Builder for creating App Intents with a fluent API
class AppIntentBuilder {
  String? _identifier;
  String? _title;
  String? _description;
  final List<AppIntentParameter> _parameters = [];
  bool _isEligibleForSearch = true;
  bool _isEligibleForPrediction = true;
  AuthenticationPolicy _authenticationPolicy = AuthenticationPolicy.none;

  /// Set the intent identifier
  AppIntentBuilder identifier(String identifier) {
    _identifier = identifier;
    return this;
  }

  /// Set the intent title
  AppIntentBuilder title(String title) {
    _title = title;
    return this;
  }

  /// Set the intent description
  AppIntentBuilder description(String description) {
    _description = description;
    return this;
  }

  /// Add a parameter to the intent
  AppIntentBuilder parameter(AppIntentParameter parameter) {
    _parameters.add(parameter);
    return this;
  }

  /// Set whether the intent is eligible for search
  AppIntentBuilder eligibleForSearch({required bool eligible}) {
    _isEligibleForSearch = eligible;
    return this;
  }

  /// Set whether the intent is eligible for prediction
  AppIntentBuilder eligibleForPrediction({required bool eligible}) {
    _isEligibleForPrediction = eligible;
    return this;
  }

  /// Set the authentication policy
  AppIntentBuilder authenticationPolicy(AuthenticationPolicy policy) {
    _authenticationPolicy = policy;
    return this;
  }

  /// Build the AppIntent
  AppIntent build() {
    if (_identifier == null || _title == null || _description == null) {
      throw ArgumentError('Identifier, title, and description are required');
    }

    return AppIntent(
      identifier: _identifier!,
      title: _title!,
      description: _description!,
      parameters: _parameters,
      isEligibleForSearch: _isEligibleForSearch,
      isEligibleForPrediction: _isEligibleForPrediction,
      authenticationPolicy: _authenticationPolicy,
    );
  }
}
