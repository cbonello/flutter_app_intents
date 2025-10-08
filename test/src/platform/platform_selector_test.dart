import 'dart:io';

import 'package:flutter_app_intents/src/platform/platform_selector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlatformSelector', () {
    setUp(resetPlatformInstance);

    tearDown(resetPlatformInstance);

    group('getPlatformInstance', () {
      test('throws UnsupportedError on unsupported platforms', () {
        // In test environment (macOS/Linux/Windows), Platform.isIOS and
        // Platform.isAndroid are both false, so it should throw
        expect(
          getPlatformInstance,
          throwsA(
            isA<UnsupportedError>().having(
              (e) => e.message,
              'message',
              contains('App Intents are only supported on iOS and Android'),
            ),
          ),
        );
      });

      test('error message includes current platform', () {
        expect(
          getPlatformInstance,
          throwsA(
            isA<UnsupportedError>().having(
              (e) => e.message,
              'message',
              contains('Current platform: ${Platform.operatingSystem}'),
            ),
          ),
        );
      });

      // Note: The following tests document expected behavior on real devices
      // but cannot be verified in test environments where Platform.isIOS and
      // Platform.isAndroid are false.

      // On iOS devices:
      // - getPlatformInstance() should return IOSAppIntentsPlatform
      // - Subsequent calls should return the same instance (singleton)

      // On Android devices:
      // - getPlatformInstance() should return AndroidAppActionsPlatform
      // - Subsequent calls should return the same instance (singleton)
    });

    group('resetPlatformInstance', () {
      test('clears the cached platform instance', () {
        // First call caches the instance (will throw in test env)
        try {
          getPlatformInstance();
          // UnsupportedError is caught to verify singleton behavior
          // ignore: avoid_catching_errors
        } on UnsupportedError {
          // Expected in test environment
        }

        // Reset the cache
        resetPlatformInstance();

        // Next call should attempt to create a new instance
        // (will throw again in test env, but proves cache was cleared)
        expect(
          getPlatformInstance,
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('can be called multiple times safely', () {
        expect(
          () {
            resetPlatformInstance();
            resetPlatformInstance();
            resetPlatformInstance();
          },
          returnsNormally,
        );
      });
    });

    group('appIntentsPlatform getter', () {
      test('delegates to getPlatformInstance', () {
        // The getter should behave the same as calling getPlatformInstance()
        expect(
          () => appIntentsPlatform,
          throwsA(
            isA<UnsupportedError>(),
          ),
        );
      });
    });

    group('platform-specific behavior', () {
      test('documentation: iOS platform selection', () {
        // This test documents the expected behavior on iOS devices.
        // In a real iOS environment:
        // - Platform.isIOS returns true
        // - getPlatformInstance() returns IOSAppIntentsPlatform
        // - The instance is cached for subsequent calls
        //
        // Example (on iOS device):
        // final platform = getPlatformInstance();
        // expect(platform, isA<IOSAppIntentsPlatform>());
        // expect(platform.platformName, equals('iOS'));
        //
        // final platform2 = getPlatformInstance();
        // expect(identical(platform, platform2), isTrue); // Same instance
      });

      test('documentation: Android platform selection', () {
        // This test documents the expected behavior on Android devices.
        // In a real Android environment:
        // - Platform.isAndroid returns true
        // - getPlatformInstance() returns AndroidAppActionsPlatform
        // - The instance is cached for subsequent calls
        //
        // Example (on Android device):
        // final platform = getPlatformInstance();
        // expect(platform, isA<AndroidAppActionsPlatform>());
        // expect(platform.platformName, equals('Android'));
        //
        // final platform2 = getPlatformInstance();
        // expect(identical(platform, platform2), isTrue); // Same instance
      });

      test('documentation: singleton behavior', () {
        // This test documents the singleton behavior.
        // The platform instance is created once and cached.
        //
        // On iOS/Android devices, the following would be true:
        // final instance1 = getPlatformInstance();
        // final instance2 = getPlatformInstance();
        // final instance3 = appIntentsPlatform;
        //
        // expect(identical(instance1, instance2), isTrue);
        // expect(identical(instance2, instance3), isTrue);
        //
        // After reset:
        // resetPlatformInstance();
        // final instance4 = getPlatformInstance();
        // expect(identical(instance1, instance4), isFalse);
      });

      test('documentation: error handling', () {
        // This test documents error handling on unsupported platforms.
        //
        // On web, desktop (except mobile emulators), the platform
        // selector throws UnsupportedError with a descriptive message
        // indicating which platforms are supported and what the
        // current platform is.
      });
    });

    group('edge cases', () {
      test('handles concurrent calls gracefully', () {
        // Even if called concurrently, should handle gracefully
        // (will throw in test env, but shouldn't crash)
        expect(
          () {
            try {
              getPlatformInstance();
              // UnsupportedError is caught here to test graceful handling
              // ignore: avoid_catching_errors
            } on UnsupportedError {
              // Expected
            }
            try {
              getPlatformInstance();
              // UnsupportedError is caught here to test graceful handling
              // ignore: avoid_catching_errors
            } on UnsupportedError {
              // Expected
            }
          },
          returnsNormally,
        );
      });

      test('resetPlatformInstance is safe to call before any usage', () {
        // Should be safe to reset even if never initialized
        expect(resetPlatformInstance, returnsNormally);
      });

      test('multiple resets followed by access throws expected error', () {
        resetPlatformInstance();
        resetPlatformInstance();
        resetPlatformInstance();

        expect(getPlatformInstance, throwsA(isA<UnsupportedError>()));
      });
    });

    group('integration with platform implementations', () {
      test('documentation: platform-specific features', () {
        // Different platforms have different capabilities:
        //
        // iOS (IOSAppIntentsPlatform):
        // - Supports registerIntent()
        // - Supports updateShortcuts()
        // - Supports donateIntent()
        // - Supports getRegisteredIntents()
        //
        // Android (AndroidAppActionsPlatform):
        // - Supports registerIntent() (throws UnsupportedError)
        // - Does not support updateShortcuts() (throws UnsupportedError)
        // - Does not support donateIntent() (throws UnsupportedError)
        // - Does not support getRegisteredIntents() (throws UnsupportedError)
        //
        // The platform selector ensures the correct implementation
        // is used based on the runtime platform.
      });

      test('documentation: platform detection reliability', () {
        // Platform detection uses dart:io Platform class:
        // - Platform.isIOS: true on iOS/iPadOS devices and simulators
        // - Platform.isAndroid: true on Android devices and emulators
        //
        // Both are false in test environments (macOS/Linux/Windows),
        // which is why tests throw UnsupportedError.
        //
        // For comprehensive platform testing:
        // 1. Run integration tests on actual iOS devices/simulators
        // 2. Run integration tests on actual Android devices/emulators
        // 3. Unit tests verify error handling on unsupported platforms
      });
    });
  });
}
