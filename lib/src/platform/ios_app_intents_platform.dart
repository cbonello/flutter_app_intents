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
    // Return cached value if available
    if (_isSupportedCache != null) {
      return _isSupportedCache!;
    }

    if (!Platform.isIOS) {
      _isSupportedCache = false;
      return false;
    }

    // Check will be performed asynchronously on first method call
    // For now, assume supported if on iOS
    return true;
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
    final supported = await _checkSupport();
    if (!supported) {
      final versionInfo = _iosVersion != null ? ' (iOS $_iosVersion)' : '';
      throw UnsupportedError(
        'iOS App Intents require iOS 16 or higher$versionInfo',
      );
    }

    // Store the handler
    _handlers[intent.identifier] = handler;

    // Set up global handler if first registration
    if (!_handlerInitialized) {
      service.FlutterAppIntentsService.setIntentHandler(_handleIntent);
      _handlerInitialized = true;
    }

    // Register with iOS system
    try {
      return await service.FlutterAppIntentsService.registerIntent(intent);
    } on service.FlutterAppIntentsException catch (e) {
      throw FlutterAppIntentsException(e.message, e.code);
    }
  }

  @override
  Future<bool> registerIntents(
    List<AppIntent> intents,
    Map<String, IntentHandler> handlers,
  ) async {
    final supported = await _checkSupport();
    if (!supported) {
      final versionInfo = _iosVersion != null ? ' (iOS $_iosVersion)' : '';
      throw UnsupportedError(
        'iOS App Intents require iOS 16 or higher$versionInfo',
      );
    }

    // Store all handlers
    _handlers.addAll(handlers);

    // Set up global handler if first registration
    if (!_handlerInitialized) {
      service.FlutterAppIntentsService.setIntentHandler(_handleIntent);
      _handlerInitialized = true;
    }

    // Register with iOS system
    try {
      return await service.FlutterAppIntentsService.registerIntents(intents);
    } on service.FlutterAppIntentsException catch (e) {
      throw FlutterAppIntentsException(e.message, e.code);
    }
  }

  @override
  Future<bool> unregisterIntent(String identifier) async {
    final supported = await _checkSupport();
    if (!supported) {
      final versionInfo = _iosVersion != null ? ' (iOS $_iosVersion)' : '';
      throw UnsupportedError(
        'iOS App Intents require iOS 16 or higher$versionInfo',
      );
    }

    _handlers.remove(identifier);

    try {
      return await service.FlutterAppIntentsService.unregisterIntent(
        identifier,
      );
    } on service.FlutterAppIntentsException catch (e) {
      throw FlutterAppIntentsException(e.message, e.code);
    }
  }

  @override
  Future<List<AppIntent>> getRegisteredIntents() async {
    final supported = await _checkSupport();
    if (!supported) {
      final versionInfo = _iosVersion != null ? ' (iOS $_iosVersion)' : '';
      throw UnsupportedError(
        'iOS App Intents require iOS 16 or higher$versionInfo',
      );
    }

    try {
      return await service.FlutterAppIntentsService.getRegisteredIntents();
    } on service.FlutterAppIntentsException catch (e) {
      throw FlutterAppIntentsException(e.message, e.code);
    }
  }

  @override
  Future<bool> updateShortcuts() async {
    final supported = await _checkSupport();
    if (!supported) {
      final versionInfo = _iosVersion != null ? ' (iOS $_iosVersion)' : '';
      throw UnsupportedError(
        'iOS App Intents require iOS 16 or higher$versionInfo',
      );
    }

    try {
      return await service.FlutterAppIntentsService.updateShortcuts();
    } on service.FlutterAppIntentsException catch (e) {
      throw FlutterAppIntentsException(e.message, e.code);
    }
  }

  @override
  Future<bool> donateIntent(
    String identifier,
    Map<String, dynamic> parameters, {
    double relevanceScore = 1.0,
  }) async {
    final supported = await _checkSupport();
    if (!supported) {
      final versionInfo = _iosVersion != null ? ' (iOS $_iosVersion)' : '';
      throw UnsupportedError(
        'iOS App Intents require iOS 16 or higher$versionInfo',
      );
    }

    try {
      return await service.FlutterAppIntentsService.donateIntentWithMetadata(
        identifier,
        parameters,
        relevanceScore: relevanceScore,
      );
    } on service.FlutterAppIntentsException catch (e) {
      throw FlutterAppIntentsException(e.message, e.code);
    }
  }

  @override
  Future<bool> donateIntentBatch(
    List<IntentDonation> donations,
  ) async {
    final supported = await _checkSupport();
    if (!supported) {
      final versionInfo = _iosVersion != null ? ' (iOS $_iosVersion)' : '';
      throw UnsupportedError(
        'iOS App Intents require iOS 16 or higher$versionInfo',
      );
    }

    try {
      // Both platform and service now use the same IntentDonation model
      return await service.FlutterAppIntentsService.donateIntentBatch(
        donations,
      );
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
