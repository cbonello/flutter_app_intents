import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_app_intents/src/platform/android_app_actions_platform.dart';
import 'package:flutter_app_intents/src/platform/app_intents_platform.dart';
import 'package:flutter_app_intents/src/platform/ios_app_intents_platform.dart';
import 'package:meta/meta.dart';

/// Cached platform instance (singleton per platform)
AppIntentsPlatform? _platformInstance;

/// Factory function to get the correct platform implementation
///
/// Automatically selects the appropriate platform based on [Platform.isIOS]
/// and [Platform.isAndroid].
///
/// Returns a singleton instance for the current platform.
///
/// Throws [UnsupportedError] if called on an unsupported platform
/// (web, desktop, etc).
AppIntentsPlatform getPlatformInstance() {
  if (_platformInstance != null) return _platformInstance!;

  if (kIsWeb) {
    throw UnsupportedError(
      'App Intents are not supported on the web platform.',
    );
  }

  _platformInstance = Platform.isIOS
      ? IOSAppIntentsPlatform()
      : Platform.isAndroid
          ? AndroidAppActionsPlatform()
          : throw UnsupportedError(
              'App Intents are only supported on iOS and Android. '
              'Current platform: ${Platform.operatingSystem}',
            );

  return _platformInstance!;
}

/// Resets the platform instance singleton.
///
/// This is intended for testing purposes only.
@visibleForTesting
void resetPlatformInstance() {
  _platformInstance = null;
}

/// Singleton accessor for the platform instance
///
/// Usage:
/// ```dart
/// final platform = appIntentsPlatform;
/// await platform.registerIntent(intent, handler);
/// ```
AppIntentsPlatform get appIntentsPlatform => getPlatformInstance();
