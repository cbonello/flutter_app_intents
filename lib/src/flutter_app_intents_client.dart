// ignore_for_file: prefer_constructors_over_static_methods

import 'dart:async';

import 'package:flutter_app_intents/src/models/app_intent.dart';
import 'package:flutter_app_intents/src/models/app_intent_parameter.dart';
import 'package:flutter_app_intents/src/models/app_intent_result.dart';
import 'package:flutter_app_intents/src/models/intent_category.dart';
import 'package:flutter_app_intents/src/models/intent_donation.dart';
import 'package:flutter_app_intents/src/models/platform_hints.dart';
import 'package:flutter_app_intents/src/models/result_layout.dart';
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

  /// Get the singleton instance of the App Intents client
  ///
  /// Returns the same instance across your app, ensuring consistent state
  /// management for registered intents and handlers.
  ///
  /// Example:
  /// ```dart
  /// final client = FlutterAppIntentsClient.instance;
  /// ```
  static final FlutterAppIntentsClient instance = FlutterAppIntentsClient._();

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
    if (_intentHandlers.isNotEmpty) {
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
    _intentHandlers.addEntries(
      intentsWithHandlers.entries.map(
        (entry) => MapEntry(entry.key.identifier, entry.value),
      ),
    );

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
  /// **Deprecated:** Use [donateIntentWithMetadata] instead for better control
  /// over relevance score, context, and timestamp.
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
  @Deprecated(
    'Use donateIntentWithMetadata instead for better control over metadata. '
    'This method will be removed in v1.0.0.',
  )
  Future<bool> donateIntent(
    String identifier,
    Map<String, dynamic> parameters,
  ) async {
    return FlutterAppIntentsService.donateIntent(identifier, parameters);
  }

  /// Donate an intent with enhanced metadata for better Siri learning
  ///
  /// Call this method after successfully executing an intent to teach Siri
  /// when and how users typically invoke your intents. This improves:
  /// - Proactive Siri suggestions at relevant times/locations
  /// - Better voice recognition and user experience
  /// - More accurate predictions in Shortcuts app
  /// - Enhanced user experience through learning
  ///
  /// This method provides enhanced control compared to [donateIntent]:
  /// - Custom relevance scores for fine-tuning prediction importance
  /// - Contextual metadata for location/time-based learning
  /// - Custom timestamps for accurate pattern tracking
  ///
  /// Best practices:
  /// - Donate immediately after successful intent execution
  /// - Include actual parameter values used (not placeholders)
  /// - Don't donate sensitive data that shouldn't be learned
  /// - Donate consistently for all intent invocations
  /// - Use appropriate relevance scores based on user intent
  ///
  /// Example:
  /// ```dart
  /// // After incrementing counter by 5 with high relevance
  /// await client.donateIntentWithMetadata(
  ///   'increment_counter',
  ///   {'amount': 5},
  ///   relevanceScore: 0.9,
  /// );
  ///
  /// // After opening profile with context
  /// await client.donateIntentWithMetadata(
  ///   'open_profile',
  ///   {'userId': 'user123'},
  ///   relevanceScore: 0.8,
  ///   context: {'source': 'notification'},
  /// );
  /// ```
  ///
  /// Parameters:
  /// - identifier: The intent identifier that was executed
  /// - parameters: The actual parameter values used in execution
  /// - relevanceScore: Score from 0.0 to 1.0 indicating importance
  ///   (default: 1.0)
  /// - context: Additional contextual information for learning
  /// - timestamp: When the intent was executed (default: now)
  ///
  /// Returns: true if donation succeeded, false if it failed
  Future<bool> donateIntentWithMetadata(
    String identifier,
    Map<String, dynamic> parameters, {
    double relevanceScore = 1.0,
    Map<String, dynamic>? context,
    DateTime? timestamp,
  }) async {
    return FlutterAppIntentsService.donateIntentWithMetadata(
      identifier,
      parameters,
      relevanceScore: relevanceScore,
      context: context,
      timestamp: timestamp,
    );
  }

  /// Donate multiple intent executions in a single batch
  ///
  /// More efficient than calling [donateIntentWithMetadata] multiple times
  /// when you need to donate several intent executions at once. This is
  /// particularly useful for:
  /// - Batch processing of queued intent executions
  /// - Bulk import of historical user actions
  /// - Syncing intent history across devices
  /// - Reducing platform channel overhead
  ///
  /// On iOS, batch donations are processed atomically with better performance.
  /// On Android and other platforms, this silently succeeds (no-op) since
  /// intent donation is an iOS-specific optimization feature.
  ///
  /// Example:
  /// ```dart
  /// final donations = [
  ///   IntentDonation.userInitiated(
  ///     identifier: 'increment_counter',
  ///     parameters: {'amount': 5},
  ///   ),
  ///   IntentDonation.userInitiated(
  ///     identifier: 'reset_counter',
  ///     parameters: {},
  ///   ),
  ///   IntentDonation.automated(
  ///     identifier: 'check_counter',
  ///     parameters: {},
  ///     context: {'trigger': 'scheduled'},
  ///   ),
  /// ];
  ///
  /// await client.donateIntents(donations);
  /// ```
  ///
  /// Parameters:
  /// - donations: List of intent donations with their metadata
  ///
  /// Returns: true if batch donation succeeded, false if it failed
  Future<bool> donateIntents(List<IntentDonation> donations) async {
    return FlutterAppIntentsService.donateIntentBatch(donations);
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
    }
    // Intentionally catch all throwable objects (Error, Exception, etc.)
    // for maximum robustness in intent handling
    // ignore: avoid_catches_without_on_clauses
    catch (e, s) {
      // Using print for debugging - helps developers troubleshoot failures
      // ignore: avoid_print
      print('Intent handler for $identifier failed with error: $e');
      // ignore: avoid_print
      print(s);
      return AppIntentResult.failed(error: 'Intent handler failed: $e');
    }
  }
}

/// Builder for creating App Intents with a fluent API
///
/// This builder uses an immutable pattern where each method returns a new
/// instance with the updated value. This prevents accidental mutations and
/// makes the API more predictable and thread-safe.
class AppIntentBuilder {
  /// Public constructor creates a builder with default values
  AppIntentBuilder()
      : _identifier = null,
        _title = null,
        _description = null,
        _parameters = const [],
        _category = null,
        _hints = null,
        _isEligibleForSearch = true,
        _isEligibleForPrediction = true,
        _authenticationPolicy = AuthenticationPolicy.none,
        _presentsResult = false,
        _resultLayout = null;

  /// Private constructor for creating modified copies
  const AppIntentBuilder._({
    required String? identifier,
    required String? title,
    required String? description,
    required List<AppIntentParameter> parameters,
    required IntentCategory? category,
    required PlatformHints? hints,
    required bool isEligibleForSearch,
    required bool isEligibleForPrediction,
    required AuthenticationPolicy authenticationPolicy,
    required bool presentsResult,
    required ResultLayout? resultLayout,
  })  : _identifier = identifier,
        _title = title,
        _description = description,
        _parameters = parameters,
        _category = category,
        _hints = hints,
        _isEligibleForSearch = isEligibleForSearch,
        _isEligibleForPrediction = isEligibleForPrediction,
        _authenticationPolicy = authenticationPolicy,
        _presentsResult = presentsResult,
        _resultLayout = resultLayout;

  final String? _identifier;
  final String? _title;
  final String? _description;
  final List<AppIntentParameter> _parameters;
  final IntentCategory? _category;
  final PlatformHints? _hints;
  final bool _isEligibleForSearch;
  final bool _isEligibleForPrediction;
  final AuthenticationPolicy _authenticationPolicy;
  final bool _presentsResult;
  final ResultLayout? _resultLayout;

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
  ///
  /// Returns a new builder instance with the identifier set.
  AppIntentBuilder identifier(String identifier) {
    return AppIntentBuilder._(
      identifier: identifier,
      title: _title,
      description: _description,
      parameters: _parameters,
      category: _category,
      hints: _hints,
      isEligibleForSearch: _isEligibleForSearch,
      isEligibleForPrediction: _isEligibleForPrediction,
      authenticationPolicy: _authenticationPolicy,
      presentsResult: _presentsResult,
      resultLayout: _resultLayout,
    );
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
  ///
  /// Returns a new builder instance with the title set.
  AppIntentBuilder title(String title) {
    return AppIntentBuilder._(
      identifier: _identifier,
      title: title,
      description: _description,
      parameters: _parameters,
      category: _category,
      hints: _hints,
      isEligibleForSearch: _isEligibleForSearch,
      isEligibleForPrediction: _isEligibleForPrediction,
      authenticationPolicy: _authenticationPolicy,
      presentsResult: _presentsResult,
      resultLayout: _resultLayout,
    );
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
  ///
  /// Returns a new builder instance with the description set.
  AppIntentBuilder description(String description) {
    return AppIntentBuilder._(
      identifier: _identifier,
      title: _title,
      description: description,
      parameters: _parameters,
      category: _category,
      hints: _hints,
      isEligibleForSearch: _isEligibleForSearch,
      isEligibleForPrediction: _isEligibleForPrediction,
      authenticationPolicy: _authenticationPolicy,
      presentsResult: _presentsResult,
      resultLayout: _resultLayout,
    );
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
  ///
  /// Returns a new builder instance with the parameter added.
  AppIntentBuilder parameter(AppIntentParameter parameter) {
    return AppIntentBuilder._(
      identifier: _identifier,
      title: _title,
      description: _description,
      parameters: [..._parameters, parameter],
      category: _category,
      hints: _hints,
      isEligibleForSearch: _isEligibleForSearch,
      isEligibleForPrediction: _isEligibleForPrediction,
      authenticationPolicy: _authenticationPolicy,
      presentsResult: _presentsResult,
      resultLayout: _resultLayout,
    );
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
  ///
  /// Returns a new builder instance with search eligibility set.
  AppIntentBuilder eligibleForSearch({required bool eligible}) {
    return AppIntentBuilder._(
      identifier: _identifier,
      title: _title,
      description: _description,
      parameters: _parameters,
      category: _category,
      hints: _hints,
      isEligibleForSearch: eligible,
      isEligibleForPrediction: _isEligibleForPrediction,
      authenticationPolicy: _authenticationPolicy,
      presentsResult: _presentsResult,
      resultLayout: _resultLayout,
    );
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
  ///
  /// Returns a new builder instance with prediction eligibility set.
  AppIntentBuilder eligibleForPrediction({required bool eligible}) {
    return AppIntentBuilder._(
      identifier: _identifier,
      title: _title,
      description: _description,
      parameters: _parameters,
      category: _category,
      hints: _hints,
      isEligibleForSearch: _isEligibleForSearch,
      isEligibleForPrediction: eligible,
      authenticationPolicy: _authenticationPolicy,
      presentsResult: _presentsResult,
      resultLayout: _resultLayout,
    );
  }

  /// Set the category for this intent
  ///
  /// The category helps classify the intent and determines which
  /// platform-specific capabilities are used:
  ///
  /// - iOS: Provides semantic meaning for Siri integration (optional)
  /// - Android: Maps to Google Built-in Intents (BII) - required for Android
  ///
  /// Example categories:
  /// - IntentCategory.general: Default for custom actions
  /// - IntentCategory.fitness: Exercise and workout related
  /// - IntentCategory.messaging: Send messages, communicate
  /// - IntentCategory.music: Media playback
  ///
  /// Optional for iOS-only apps. Required when generating Android shortcuts.xml
  /// (validated at build-time by code generator).
  ///
  /// Default: null (uses IntentCategory.general on Android if not specified)
  ///
  /// Returns a new builder instance with the category set.
  AppIntentBuilder category(IntentCategory category) {
    return AppIntentBuilder._(
      identifier: _identifier,
      title: _title,
      description: _description,
      parameters: _parameters,
      category: category,
      hints: _hints,
      isEligibleForSearch: _isEligibleForSearch,
      isEligibleForPrediction: _isEligibleForPrediction,
      authenticationPolicy: _authenticationPolicy,
      presentsResult: _presentsResult,
      resultLayout: _resultLayout,
    );
  }

  /// Set platform-specific hints for advanced customization
  ///
  /// Allows you to provide platform-specific optimizations while keeping
  /// the core intent definition platform-agnostic.
  ///
  /// Example:
  /// ```dart
  /// .hints(PlatformHints(
  ///   iosSuggestedPhrase: 'Start my morning workout',
  ///   androidBIIOverride: 'actions.intent.START_EXERCISE',
  /// ))
  /// ```
  ///
  /// Optional: Only needed for advanced platform-specific customization
  ///
  /// Returns a new builder instance with the hints set.
  AppIntentBuilder hints(PlatformHints hints) {
    return AppIntentBuilder._(
      identifier: _identifier,
      title: _title,
      description: _description,
      parameters: _parameters,
      category: _category,
      hints: hints,
      isEligibleForSearch: _isEligibleForSearch,
      isEligibleForPrediction: _isEligibleForPrediction,
      authenticationPolicy: _authenticationPolicy,
      presentsResult: _presentsResult,
      resultLayout: _resultLayout,
    );
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
  ///
  /// Returns a new builder instance with the authentication policy set.
  AppIntentBuilder authenticationPolicy(AuthenticationPolicy policy) {
    return AppIntentBuilder._(
      identifier: _identifier,
      title: _title,
      description: _description,
      parameters: _parameters,
      category: _category,
      hints: _hints,
      isEligibleForSearch: _isEligibleForSearch,
      isEligibleForPrediction: _isEligibleForPrediction,
      authenticationPolicy: policy,
      presentsResult: _presentsResult,
      resultLayout: _resultLayout,
    );
  }

  /// Set whether this intent presents its result in a dialog (iOS only)
  ///
  /// **Platform Support:**
  /// - ✅ **iOS**: Shows result in a dialog
  /// - ❌ **Android**: Not yet supported (always opens app)
  ///
  /// Controls the UX when the intent is executed from Shortcuts or Siri:
  /// - `false` (default): Action intents that open the app silently
  ///   (e.g., "Increment Counter", "Start Timer", "Send Message")
  /// - `true`: Query intents that display a result to the user
  ///   (e.g., "Get Counter Value", "Check Weather", "Get Balance")
  ///
  /// Action intents provide better UX by opening the app immediately without
  /// showing a dialog. Query intents show the result value in a dialog before
  /// optionally opening the app.
  ///
  /// **Note:** Android inline fulfillment requires Android Widgets, which is
  /// planned for a future release. For now, all Android App Actions open the
  /// app.
  ///
  /// Example:
  /// ```dart
  /// AppIntentBuilder()
  ///   .identifier('get_status')
  ///   .title('Get Status')
  ///   .presentsResult(true)  // iOS: Shows result in dialog
  ///   .build()
  /// ```
  ///
  /// Returns a new builder instance with presentsResult set.
  AppIntentBuilder presentsResult({required bool presents}) {
    return AppIntentBuilder._(
      identifier: _identifier,
      title: _title,
      description: _description,
      parameters: _parameters,
      category: _category,
      hints: _hints,
      isEligibleForSearch: _isEligibleForSearch,
      isEligibleForPrediction: _isEligibleForPrediction,
      authenticationPolicy: _authenticationPolicy,
      presentsResult: presents,
      resultLayout: _resultLayout,
    );
  }

  /// Set the layout for displaying the intent result
  ///
  /// **Platform Support:**
  /// - ✅ **iOS**: Configures IntentDialog presentation
  /// - ✅ **Android**: Generates app widget using RemoteViews
  ///
  /// Defines how the result should be displayed when the intent is executed.
  /// This works in conjunction with `presentsResult(true)` to show rich
  /// results:
  ///
  /// - **Simple text**: Use `ResultLayout.text(value: 'resultKey')` for plain
  ///   text results
  /// - **Card layout**: Use `ResultLayout.card()` for title + description +
  ///   optional image
  /// - **List layout**: Use `ResultLayout.list()` for multiple items with
  ///   titles and subtitles
  ///
  /// For Android, this generates an AppWidgetProvider and layout XML files
  /// that display the result in a widget after intent execution.
  /// For iOS, this configures the IntentDialog presentation format.
  ///
  /// Example with intent definition:
  /// ```dart
  /// AppIntentBuilder()
  ///   .identifier('get_weather')
  ///   .title('Get Weather')
  ///   .presentsResult(presents: true)
  ///   .resultLayout(
  ///     ResultLayout.card(
  ///       title: 'temperature',
  ///       description: 'conditions',
  ///       image: 'weatherIcon',
  ///     ),
  ///   )
  ///   .build()
  /// ```
  ///
  /// Example intent handler return value:
  /// ```dart
  /// // In your intent handler:
  /// return AppIntentResult.successful(
  ///   value: {
  ///     'temperature': '72°F',
  ///     'conditions': 'Sunny',
  ///     'weatherIcon': 'sun.max.fill', // SF Symbol name on iOS
  ///   },
  /// );
  /// ```
  ///
  /// **Note:** The keys specified in the layout (e.g., 'temperature',
  /// 'conditions') must match the keys in the Map returned by your intent
  /// handler in `AppIntentResult.successful(value: {...})`.
  ///
  /// Returns a new builder instance with the result layout set.
  AppIntentBuilder resultLayout(ResultLayout layout) {
    return AppIntentBuilder._(
      identifier: _identifier,
      title: _title,
      description: _description,
      parameters: _parameters,
      category: _category,
      hints: _hints,
      isEligibleForSearch: _isEligibleForSearch,
      isEligibleForPrediction: _isEligibleForPrediction,
      authenticationPolicy: _authenticationPolicy,
      presentsResult: _presentsResult,
      resultLayout: layout,
    );
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
  /// Optional fields:
  /// - category: Intent category (required for Android, optional for iOS)
  /// - hints: Platform-specific customization
  ///
  /// Throws ArgumentError if any required fields are missing.
  ///
  /// Returns: A configured AppIntent ready for registration
  AppIntent build() {
    // Validate required fields with helpful error messages
    if (_identifier == null || _title == null || _description == null) {
      final missing = <String>[];
      if (_identifier == null) missing.add('identifier');
      if (_title == null) missing.add('title');
      if (_description == null) missing.add('description');

      throw ArgumentError(
        'Missing required fields: ${missing.join(', ')}. '
        'Use .identifier(), .title(), and .description() methods to set them.',
      );
    }

    return AppIntent(
      identifier: _identifier,
      title: _title,
      description: _description,
      parameters: _parameters,
      category: _category,
      hints: _hints,
      isEligibleForSearch: _isEligibleForSearch,
      isEligibleForPrediction: _isEligibleForPrediction,
      authenticationPolicy: _authenticationPolicy,
      presentsResult: _presentsResult,
      resultLayout: _resultLayout,
    );
  }
}
