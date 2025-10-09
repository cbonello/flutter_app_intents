import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_intents/src/models/app_intent.dart';
import 'package:flutter_app_intents/src/models/app_intent_result.dart';
import 'package:flutter_app_intents/src/models/intent_donation.dart';

/// Service for managing Apple App Intents integration
class FlutterAppIntentsService {
  /// Check if running on iOS platform (can be mocked in tests)
  static bool get _isIOS {
    if (kDebugMode && debugDefaultTargetPlatformOverride != null) {
      return debugDefaultTargetPlatformOverride == TargetPlatform.iOS;
    }
    return Platform.isIOS;
  }

  static const MethodChannel _channel = MethodChannel('flutter_app_intents');

  /// Helper method to invoke platform methods with consistent error handling
  ///
  /// Performs platform check and wraps PlatformException in
  /// FlutterAppIntentsException with a custom error message.
  static Future<T> _invokePlatformMethod<T>(
    String method,
    dynamic arguments, {
    required String errorMessage,
    T? defaultValue,
  }) async {
    if (!_isIOS) {
      throw UnsupportedError('App Intents are only supported on iOS');
    }

    try {
      final result = await _channel.invokeMethod<T>(method, arguments);
      return result ?? defaultValue as T;
    } on PlatformException catch (e) {
      throw FlutterAppIntentsException(
        '$errorMessage: ${e.message}',
        e.code,
      );
    }
  }

  /// Registers an App Intent with the system
  static Future<bool> registerIntent(AppIntent intent) async {
    return _invokePlatformMethod<bool>(
      'registerIntent',
      intent.toMap(),
      errorMessage: 'Failed to register intent',
      defaultValue: false,
    );
  }

  /// Registers multiple App Intents with the system
  static Future<bool> registerIntents(List<AppIntent> intents) async {
    return _invokePlatformMethod<bool>(
      'registerIntents',
      {
        'intents': intents.map((intent) => intent.toMap()).toList(),
      },
      errorMessage: 'Failed to register intents',
      defaultValue: false,
    );
  }

  /// Unregisters an App Intent from the system
  static Future<bool> unregisterIntent(String identifier) async {
    return _invokePlatformMethod<bool>(
      'unregisterIntent',
      {'identifier': identifier},
      errorMessage: 'Failed to unregister intent',
      defaultValue: false,
    );
  }

  /// Gets all registered App Intents
  static Future<List<AppIntent>> getRegisteredIntents() async {
    if (!_isIOS) {
      throw UnsupportedError('App Intents are only supported on iOS');
    }

    try {
      final result = await _channel.invokeListMethod<Map<dynamic, dynamic>>(
        'getRegisteredIntents',
      );

      return result
              ?.map(
                (intentMap) =>
                    AppIntent.fromMap(Map<String, dynamic>.from(intentMap)),
              )
              .toList() ??
          [];
    } on PlatformException catch (e) {
      throw FlutterAppIntentsException(
        'Failed to get registered intents: ${e.message}',
        e.code,
      );
    }
  }

  /// Sets up a handler for when an intent is invoked
  static void setIntentHandler(
    Future<AppIntentResult> Function(
      String identifier,
      Map<String, dynamic> parameters,
    ) handler,
  ) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'handleIntent') {
        return _handleIntentCall(call, handler);
      }
      return null;
    });
  }

  /// Handles an intent invocation from the platform channel
  ///
  /// Performs type-safe extraction and validation of intent arguments.
  static Future<Map<String, dynamic>> _handleIntentCall(
    MethodCall call,
    Future<AppIntentResult> Function(
      String identifier,
      Map<String, dynamic> parameters,
    ) handler,
  ) async {
    // Extract and validate arguments
    final arguments = call.arguments as Map<Object?, Object?>?;
    if (arguments == null) {
      return AppIntentResult.failed(
        error: 'Missing intent arguments',
      ).toMap();
    }

    final identifier = arguments['identifier'] as String?;
    final parametersRaw = arguments['parameters'] as Map<Object?, Object?>?;

    if (identifier == null || parametersRaw == null) {
      return AppIntentResult.failed(
        error: 'Invalid intent arguments',
      ).toMap();
    }

    // Convert to typed map
    final parameters = Map<String, dynamic>.from(parametersRaw);

    // Invoke handler with proper error handling
    try {
      final result = await handler(identifier, parameters);
      return result.toMap();
    } on Object catch (e) {
      return AppIntentResult.failed(
        error: 'Intent handler failed: $e',
      ).toMap();
    }
  }

  /// Updates the app shortcuts (for iOS 14+ App Shortcuts)
  static Future<bool> updateShortcuts() async {
    return _invokePlatformMethod<bool>(
      'updateShortcuts',
      null,
      errorMessage: 'Failed to update shortcuts',
      defaultValue: false,
    );
  }

  /// Donates an intent to the system (for prediction)
  ///
  /// **Deprecated:** Use [donateIntentWithMetadata] instead for better control
  /// over relevance score, context, and timestamp.
  @Deprecated(
    'Use donateIntentWithMetadata instead for better control over metadata. '
    'This method will be removed in v1.0.0.',
  )
  static Future<bool> donateIntent(
    String identifier,
    Map<String, dynamic> parameters,
  ) async {
    return donateIntentWithMetadata(
      identifier,
      parameters,
    );
  }

  /// Donates an intent with enhanced metadata for better Siri learning
  ///
  /// On iOS, this helps Siri learn user patterns and provide better
  /// predictions. On Android and other platforms, this is a no-op (silently
  /// ignored) since intent donation is an iOS-specific optimization feature.
  static Future<bool> donateIntentWithMetadata(
    String identifier,
    Map<String, dynamic> parameters, {
    double relevanceScore = 1.0,
    Map<String, dynamic>? context,
    DateTime? timestamp,
  }) async {
    // Validate relevance score first (before platform check)
    if (relevanceScore < 0.0 || relevanceScore > 1.0) {
      throw ArgumentError('Relevance score must be between 0.0 and 1.0');
    }

    if (!_isIOS) {
      // Silently return true (no-op) on non-iOS platforms
      // Intent donation is an iOS-specific optimization for Siri learning
      if (kDebugMode) {
        debugPrint(
          'Intent donation is iOS-only, '
          'ignoring on ${Platform.operatingSystem}',
        );
      }
      return true;
    }

    try {
      final donationData = {
        'identifier': identifier,
        'parameters': parameters,
        'metadata': {
          'relevanceScore': relevanceScore,
          'context': context ?? {},
          'timestamp': (timestamp ?? DateTime.now()).millisecondsSinceEpoch,
        },
      };

      final result = await _channel.invokeMethod<bool>(
        'donateIntentWithMetadata',
        donationData,
      );

      return result ?? false;
    } on PlatformException catch (e) {
      throw FlutterAppIntentsException(
        'Failed to donate intent: ${e.message}',
        e.code,
      );
    }
  }

  /// Donates multiple intents in a batch for better performance
  ///
  /// On iOS, this helps Siri learn user patterns and provide better
  /// predictions. On Android and other platforms, this is a no-op (silently
  /// ignored) since intent donation is an iOS-specific optimization feature.
  static Future<bool> donateIntentBatch(
    List<IntentDonation> donations,
  ) async {
    if (!_isIOS) {
      // Silently return true (no-op) on non-iOS platforms
      // Intent donation is an iOS-specific optimization for Siri learning
      if (kDebugMode) {
        debugPrint(
          'Intent donation is iOS-only, '
          'ignoring on ${Platform.operatingSystem}',
        );
      }
      return true;
    }

    try {
      final donationList = donations
          .map(
            (donation) => {
              'identifier': donation.identifier,
              'parameters': donation.parameters,
              'metadata': {
                'relevanceScore': donation.relevanceScore,
                'context': donation.context,
                'timestamp': (donation.timestamp ?? DateTime.now())
                    .millisecondsSinceEpoch,
              },
            },
          )
          .toList();

      final result = await _channel.invokeMethod<bool>(
        'donateIntentBatch',
        {'donations': donationList},
      );

      return result ?? false;
    } on PlatformException catch (e) {
      throw FlutterAppIntentsException(
        'Failed to donate intent batch: ${e.message}',
        e.code,
      );
    }
  }

  /// Gets the iOS major version number from native code
  static Future<int?> getIOSVersion() async {
    if (!_isIOS) {
      return null;
    }

    try {
      final result = await _channel.invokeMethod<int>('getIOSVersion');
      return result;
    } on PlatformException {
      // If method call fails, return null
      return null;
    }
  }
}

/// Exception thrown when Flutter App Intents operations fail
class FlutterAppIntentsException extends Equatable implements Exception {
  const FlutterAppIntentsException(this.message, [this.code]);

  /// Error message
  final String message;

  /// Platform-specific error code
  final String? code;

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() =>
      'FlutterAppIntentsException: $message${code != null ? ' ($code)' : ''}';
}
