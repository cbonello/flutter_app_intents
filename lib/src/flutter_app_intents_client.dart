// ignore_for_file: avoid_returning_this - AppIntentBuilder uses fluent
// interface pattern where methods return `this` to enable method chaining.
// ignore_for_file: prefer_constructors_over_static_methods

import 'dart:async';

import 'package:flutter_app_intents/src/models/app_intent.dart';
import 'package:flutter_app_intents/src/models/app_intent_parameter.dart';
import 'package:flutter_app_intents/src/models/app_intent_result.dart';
import 'package:flutter_app_intents/src/services/flutter_app_intents_service.dart';

/// Main client for managing App Intents in Flutter applications
///
/// This singleton class provides a high-level API for integrating iOS App
/// Intents
/// with Flutter apps. It handles intent registration, execution, and system
/// integration.
///
/// Key features:
/// - Register intents with custom handlers
/// - Automatic routing from iOS to Flutter handlers
/// - Intent donation for Siri learning
/// - Shortcuts app integration
/// - Parameter handling and validation
///
/// Usage:
/// ```dart
/// final client = FlutterAppIntentsClient.instance;
///
/// // Create and register an intent
/// final intent = AppIntentBuilder()
///   .identifier('my_action')
///   .title('My Action')
///   .description('Does something useful')
///   .build();
///
/// await client.registerIntent(intent, (parameters) async {
///   // Your intent handler logic
///   return AppIntentResult.successful(value: 'Done!');
/// });
/// ```
class FlutterAppIntentsClient {
  FlutterAppIntentsClient._();

  static FlutterAppIntentsClient? _instance;

  /// Get the singleton instance of the App Intents client
  ///
  /// Returns the same instance across your app, ensuring consistent state
  /// management for registered intents and handlers.
  ///
  /// Example:
  /// ```dart
  /// final client = FlutterAppIntentsClient.instance;
  /// ```
  static FlutterAppIntentsClient get instance =>
      _instance ??= FlutterAppIntentsClient._();

  final Map<String, Future<AppIntentResult> Function(Map<String, dynamic>)>
      _intentHandlers = {};

  /// Register a single intent with its execution handler
  ///
  /// Associates an AppIntent configuration with a Flutter function that
  /// will be called when the intent is invoked from iOS (via Siri, Shortcuts,
  /// or other system integrations).
  ///
  /// The handler function receives parameters from the intent invocation and
  /// should return an AppIntentResult indicating success or failure.
  ///
  /// Example:
  /// ```dart
  /// final intent = AppIntentBuilder()
  ///   .identifier('increment_counter')
  ///   .title('Increment Counter')
  ///   .parameter(AppIntentParameter(
  ///     name: 'amount',
  ///     type: AppIntentParameterType.integer
  ///   ))
  ///   .build();
  ///
  /// await client.registerIntent(intent, (parameters) async {
  ///   final amount = parameters['amount'] as int? ?? 1;
  ///   // Your increment logic here
  ///   return AppIntentResult.successful(value: 'Incremented by $amount');
  /// });
  /// ```
  ///
  /// Parameters:
  /// - intent: The AppIntent configuration to register
  /// - handler: Function that executes when the intent is invoked
  ///
  /// Returns: true if registration succeeded, false otherwise
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

  /// Register multiple intents with their handlers in a single call
  ///
  /// More efficient than calling registerIntent() multiple times, as this
  /// method batches the registration with the iOS system.
  ///
  /// Each intent is mapped to its corresponding handler function that will
  /// be called when the intent is invoked.
  ///
  /// Example:
  /// ```dart
  /// await client.registerIntents({
  ///   incrementIntent: (params) async {
  ///     final amount = params['amount'] as int? ?? 1;
  ///     return AppIntentResult.successful(value: 'Incremented by $amount');
  ///   },
  ///   resetIntent: (params) async {
  ///     return AppIntentResult.successful(value: 'Counter reset');
  ///   },
  ///   queryIntent: (params) async {
  ///     return AppIntentResult.successful(value: 'Current value: 42');
  ///   },
  /// });
  /// ```
  ///
  /// Parameters:
  /// - intentsWithHandlers: Map of AppIntent to handler function pairs
  ///
  /// Returns: true if all registrations succeeded, false otherwise
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

  /// Remove an intent from the system and stop handling its invocations
  ///
  /// Unregisters the intent from iOS and removes its handler from Flutter.
  /// After unregistration, the intent will no longer appear in:
  /// - Siri suggestions
  /// - Shortcuts app
  /// - Spotlight search
  /// - System settings
  ///
  /// Example:
  /// ```dart
  /// // Remove a specific intent
  /// await client.unregisterIntent('increment_counter');
  /// ```
  ///
  /// Parameters:
  /// - identifier: The unique identifier of the intent to unregister
  ///
  /// Returns: true if unregistration succeeded, false otherwise
  Future<bool> unregisterIntent(String identifier) async {
    _intentHandlers.remove(identifier);

    return FlutterAppIntentsService.unregisterIntent(identifier);
  }

  /// Retrieve a list of all currently registered intents
  ///
  /// Returns all intents that have been successfully registered with the
  /// iOS system and are available for invocation. Useful for:
  /// - Debugging and verification
  /// - Displaying available actions to users
  /// - Dynamic UI that shows registered capabilities
  ///
  /// Example:
  /// ```dart
  /// final intents = await client.getRegisteredIntents();
  /// for (final intent in intents) {
  ///   print('Available: ${intent.title} (${intent.identifier})');
  /// }
  /// ```
  ///
  /// Returns: List of AppIntent objects currently registered with the system
  Future<List<AppIntent>> getRegisteredIntents() async {
    return FlutterAppIntentsService.getRegisteredIntents();
  }

  /// Refresh the system's shortcuts with latest registered intents
  ///
  /// Forces iOS to update its shortcuts database with any changes made to
  /// your registered intents. This includes:
  /// - New intents that were registered
  /// - Modified intent configurations
  /// - Updated parameters or configurations
  /// - Changes to eligibility settings
  ///
  /// Typically called automatically after intent registration, but can be
  /// called manually when needed for immediate updates.
  ///
  /// Use cases:
  /// - After modifying intent configurations at runtime
  /// - When you want to ensure shortcuts are immediately available
  /// - For debugging when shortcuts don't appear as expected
  ///
  /// Example:
  /// ```dart
  /// // Force shortcuts refresh
  /// await client.updateShortcuts();
  /// ```
  ///
  /// Returns: true if shortcuts update succeeded, false otherwise
  Future<bool> updateShortcuts() async {
    return FlutterAppIntentsService.updateShortcuts();
  }

  /// Donate an intent execution to help Siri learn user patterns
  ///
  /// Call this method after successfully executing an intent to teach Siri
  /// when and how users typically invoke your intents. This improves:
  /// - Proactive Siri suggestions at relevant times/locations
  /// - Better voice recognition and user experience
  /// - More accurate predictions in Shortcuts app
  /// - Enhanced user experience through learning
  ///
  /// Best practices:
  /// - Donate immediately after successful intent execution
  /// - Include actual parameter values used (not placeholders)
  /// - Don't donate sensitive data that shouldn't be learned
  /// - Donate consistently for all intent invocations
  ///
  /// Example:
  /// ```dart
  /// // After incrementing counter by 5
  /// await client.donateIntent('increment_counter', {'amount': 5});
  ///
  /// // After opening profile for user123
  /// await client.donateIntent('open_profile', {'userId': 'user123'});
  /// ```
  ///
  /// Parameters:
  /// - identifier: The intent identifier that was executed
  /// - parameters: The actual parameter values used in execution
  ///
  /// Returns: true if donation succeeded, false if it failed
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

  /// Set the unique identifier for this intent
  ///
  /// The identifier must be unique across your app and is used internally
  /// by iOS to track and execute the intent. Use reverse domain notation
  /// for best practices (e.g., 'com.myapp.increment_counter').
  ///
  /// This identifier is used for:
  /// - Intent registration and execution
  /// - Intent donation and analytics
  /// - Debugging and logging
  ///
  /// Required field - intent creation will fail without it.
  AppIntentBuilder identifier(String identifier) {
    _identifier = identifier;

    return this;
  }

  /// Set the display title for this intent
  ///
  /// The title is shown to users in:
  /// - Shortcuts app as the action name
  /// - Siri suggestions and search results
  /// - System settings and intent lists
  /// - Voice commands based on the intent title
  ///
  /// Should be concise, descriptive, and user-friendly (e.g., 'Increment
  /// Counter', 'Send Message', 'Start Workout').
  ///
  /// Required field - intent creation will fail without it.
  AppIntentBuilder title(String title) {
    _title = title;

    return this;
  }

  /// Set a detailed description of what this intent does
  ///
  /// The description helps users understand the intent's purpose and is
  /// shown in:
  /// - Shortcuts app when browsing available actions
  /// - System accessibility features
  /// - Developer documentation and debugging
  ///
  /// Should clearly explain what the intent accomplishes (e.g., 'Increments
  /// the app counter by a specified amount', 'Sends a message to a contact').
  ///
  /// Required field - intent creation will fail without it.
  AppIntentBuilder description(String description) {
    _description = description;

    return this;
  }

  /// Add a parameter that users can provide to this intent
  ///
  /// Parameters allow intents to accept input from users, making them more
  /// flexible and powerful. Each parameter has:
  /// - Name and type (string, integer, boolean, etc.)
  /// - Optional vs required status
  /// - Default values for optional parameters
  /// - User-friendly title and description
  ///
  /// Examples:
  /// - Amount parameter for increment intent
  /// - Message text for messaging intent
  /// - Contact name for calling intent
  ///
  /// Can be called multiple times to add multiple parameters.
  AppIntentBuilder parameter(AppIntentParameter parameter) {
    _parameters.add(parameter);

    return this;
  }

  /// Set whether the intent can appear in Spotlight search results
  ///
  /// When enabled (true), users can find and invoke this intent through:
  /// - iOS Spotlight search (swipe down on home screen)
  /// - Search within the Shortcuts app
  /// - System-wide search functionality
  ///
  /// Search eligibility makes intents more discoverable but may not be
  /// suitable for:
  /// - Private or sensitive actions
  /// - Internal/developer-only intents
  /// - Actions that require specific app context
  ///
  /// Default: true (recommended for user-facing intents)
  AppIntentBuilder eligibleForSearch({required bool eligible}) {
    _isEligibleForSearch = eligible;
    return this;
  }

  /// Set whether the intent is eligible for Siri's proactive predictions
  ///
  /// When enabled (true), Siri learns user patterns and suggests this intent
  /// at relevant times/locations. Shows up in:
  /// - Siri Suggestions widget and lock screen shortcuts
  /// - Spotlight search with higher priority
  /// - Control Center suggestions
  /// - Shortcuts app recommendations
  ///
  /// Disable (false) for sensitive intents, context-specific actions, or
  /// intents with side effects that shouldn't be triggered accidentally.
  ///
  /// Default: true (recommended for most intents)
  AppIntentBuilder eligibleForPrediction({required bool eligible}) {
    _isEligibleForPrediction = eligible;

    return this;
  }

  /// Set the authentication requirements for this intent
  ///
  /// Controls what level of device security is required before the intent
  /// can be executed. Options:
  ///
  /// - AuthenticationPolicy.none: No authentication required
  ///   * Intent runs immediately when invoked
  ///   * Suitable for safe, non-sensitive actions
  ///
  /// - AuthenticationPolicy.requiresAuthentication: User must be authenticated
  ///   * Requires Face ID, Touch ID, or passcode
  ///   * Good for personal but non-critical actions
  ///
  /// - AuthenticationPolicy.requiresUnlockedDevice: Device must be unlocked
  ///   * Highest security level
  ///   * Required for sensitive data access or critical operations
  ///
  /// Default: AuthenticationPolicy.none (no authentication required)
  AppIntentBuilder authenticationPolicy(AuthenticationPolicy policy) {
    _authenticationPolicy = policy;

    return this;
  }

  /// Build the final AppIntent from the configured properties
  ///
  /// Creates an immutable AppIntent instance with all the properties
  /// that have been set on this builder.
  ///
  /// Required fields that must be set before calling build():
  /// - identifier: Unique intent identifier
  /// - title: User-facing display name
  /// - description: Explanation of what the intent does
  ///
  /// Throws ArgumentError if any required fields are missing.
  ///
  /// Returns: A configured AppIntent ready for registration
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
