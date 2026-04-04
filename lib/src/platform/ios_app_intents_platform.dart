import 'dart:io';

import 'package:flutter_app_intents/src/models/app_intent.dart';
import 'package:flutter_app_intents/src/models/app_intent_result.dart';
import 'package:flutter_app_intents/src/models/intent_donation.dart';
import 'package:flutter_app_intents/src/platform/app_intents_platform.dart';
import 'package:flutter_app_intents/src/services/flutter_app_intents_service.dart'
    as service;

/// iOS implementation of AppIntentsPlatform
///
/// Wraps the existing FlutterAppIntentsService to provide platform
/// abstraction. Supports iOS 16+ with App Intents framework.
class IOSAppIntentsPlatform extends AppIntentsPlatform {
  /// Store intent handlers for routing
  final Map<String, IntentHandler> _handlers = {};

  /// Whether the handler has been set up
  bool _handlerInitialized = false;

  /// Cached iOS version (null until first check)
  int? _iosVersion;

  /// Cached support status (null until first check)
  bool? _isSupportedCache;

  @override
  String get platformName => 'iOS';

  @override
  bool get isSupported {
    // Return cached value if available, otherwise assume iOS is supported
    // (actual iOS version check happens asynchronously on first method call)
    return _isSupportedCache ?? Platform.isIOS;
  }

  /// Check if the platform is supported (async version)
  ///
  /// This method queries the native iOS code for the actual iOS version.
  Future<bool> _checkSupport() async {
    if (_isSupportedCache != null) {
      return _isSupportedCache!;
    }

    if (!Platform.isIOS) {
      _isSupportedCache = false;
      return false;
    }

    try {
      final iosVersion = await service.FlutterAppIntentsService.getIOSVersion();
      _iosVersion = iosVersion;
      _isSupportedCache = iosVersion != null && iosVersion >= 16;
      return _isSupportedCache!;
    } on Object {
      // If method call fails, assume not supported
      _isSupportedCache = false;
      return false;
    }
  }

  @override
  Future<bool> registerIntent(
    AppIntent intent,
    IntentHandler handler,
  ) async {
    await _ensureSupported();

    // Store the handler
    _handlers[intent.identifier] = handler;

    // Set up global handler if first registration
    _ensureHandlerInitialized();

    // Register with iOS system
    return _invokeServiceMethod(
      () => service.FlutterAppIntentsService.registerIntent(intent),
    );
  }

  @override
  Future<bool> registerIntents(
    List<AppIntent> intents,
    Map<String, IntentHandler> handlers,
  ) async {
    await _ensureSupported();

    // Store all handlers
    _handlers.addAll(handlers);

    // Set up global handler if first registration
    _ensureHandlerInitialized();

    // Register with iOS system
    return _invokeServiceMethod(
      () => service.FlutterAppIntentsService.registerIntents(intents),
    );
  }

  @override
  Future<bool> unregisterIntent(String identifier) async {
    await _ensureSupported();

    final result = await _invokeServiceMethod(
      () => service.FlutterAppIntentsService.unregisterIntent(identifier),
    );

    // Only remove the local handler after the service call succeeds
    _handlers.remove(identifier);

    return result;
  }

  @override
  Future<List<AppIntent>> getRegisteredIntents() async {
    await _ensureSupported();

    return _invokeServiceMethod(
      service.FlutterAppIntentsService.getRegisteredIntents,
    );
  }

  @override
  Future<bool> updateShortcuts() async {
    await _ensureSupported();

    return _invokeServiceMethod(
      service.FlutterAppIntentsService.updateShortcuts,
    );
  }

  @override
  Future<bool> donateIntent(
    String identifier,
    Map<String, dynamic> parameters, {
    double relevanceScore = 1.0,
  }) async {
    if (relevanceScore < 0.0 || relevanceScore > 1.0) {
      throw ArgumentError.value(
        relevanceScore,
        'relevanceScore',
        'Must be between 0.0 and 1.0',
      );
    }

    await _ensureSupported();

    return _invokeServiceMethod(
      () => service.FlutterAppIntentsService.donateIntentWithMetadata(
        identifier,
        parameters,
        relevanceScore: relevanceScore,
      ),
    );
  }

  @override
  Future<bool> donateIntentBatch(
    List<IntentDonation> donations,
  ) async {
    await _ensureSupported();

    // Both platform and service now use the same IntentDonation model
    return _invokeServiceMethod(
      () => service.FlutterAppIntentsService.donateIntentBatch(donations),
    );
  }

  /// Ensures that the platform is supported before proceeding.
  /// Throws [UnsupportedError] if not supported.
  Future<void> _ensureSupported() async {
    final supported = await _checkSupport();
    if (!supported) {
      final versionInfo = _iosVersion != null ? ' (iOS $_iosVersion)' : '';
      throw UnsupportedError(
        'iOS App Intents require iOS 16 or higher$versionInfo',
      );
    }
  }

  /// Initializes the intent handler if not already initialized.
  /// This sets up the handler to receive intent invocations from iOS.
  void _ensureHandlerInitialized() {
    if (!_handlerInitialized) {
      service.FlutterAppIntentsService.setIntentHandler(_handleIntent);
      _handlerInitialized = true;
    }
  }

  /// Invokes a service method with standardized error handling.
  ///
  /// Wraps FlutterAppIntentsException from the service layer and re-throws
  /// it as a platform-level exception with the same message and code.
  Future<T> _invokeServiceMethod<T>(
    Future<T> Function() serviceCall,
  ) async {
    try {
      return await serviceCall();
    } on service.FlutterAppIntentsException catch (e) {
      throw FlutterAppIntentsException(e.message, e.code);
    }
  }

  /// Internal handler that routes to registered handlers
  Future<AppIntentResult> _handleIntent(
    String identifier,
    Map<String, dynamic> parameters,
  ) async {
    final handler = _handlers[identifier];
    if (handler == null) {
      return AppIntentResult.failed(
        error: 'No handler registered for intent: $identifier',
      );
    }

    try {
      return await handler(parameters);
    } on Object catch (e) {
      return AppIntentResult.failed(
        error: 'Intent handler failed: $e',
      );
    }
  }
}
