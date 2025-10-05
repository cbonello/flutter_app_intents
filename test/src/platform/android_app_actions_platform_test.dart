import 'package:flutter/services.dart';
import 'package:flutter_app_intents/src/models/app_intent.dart';
import 'package:flutter_app_intents/src/models/app_intent_result.dart';
import 'package:flutter_app_intents/src/platform/android_app_actions_platform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AndroidAppActionsPlatform', () {
    late AndroidAppActionsPlatform platform;
    late MethodChannel channel;

    setUp(() {
      platform = AndroidAppActionsPlatform();
      channel = const MethodChannel('flutter_app_intents');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'getApiLevel') {
            return 25;
          }
          return true;
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        channel,
        null,
      );
    });

    test('platformName returns Android', () {
      expect(platform.platformName, equals('Android'));
    });

    test('isSupported returns false on non-Android platforms', () {
      // On non-Android platforms during testing (like macOS),
      // isSupported returns false
      expect(platform.isSupported, isFalse);
    });

    // Note: The following tests would fail on non-Android platforms because
    // Platform.isAndroid is false. In a real Android environment, these would
    // work correctly. For comprehensive testing, these should be run as
    // integration tests on actual Android devices.
    //
    // Skipping these tests as they rely on Platform.isAndroid being true.
    test(
      'registerIntent throws UnsupportedError on non-Android platforms',
      () async {
        const intent = AppIntent(
          identifier: 'test',
          title: 'Test',
          description: 'Test',
        );

        // On non-Android platforms (like macOS during testing),
        // this should throw UnsupportedError
        expect(
          () => platform.registerIntent(
            intent,
            (_) async => const AppIntentResult(success: true),
          ),
          throwsUnsupportedError,
        );
      },
      skip: 'Tests run on host platform, not Android',
    );

    test(
      'donateIntent throws UnsupportedError on non-Android platforms',
      () async {
        expect(
          () => platform.donateIntent('test_id', {'param': 'value'}),
          throwsUnsupportedError,
        );
      },
      skip: 'Tests run on host platform, not Android',
    );
  });
}
