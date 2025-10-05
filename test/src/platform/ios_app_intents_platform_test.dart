import 'package:flutter/services.dart';
import 'package:flutter_app_intents/src/models/app_intent.dart';
import 'package:flutter_app_intents/src/models/app_intent_result.dart';
import 'package:flutter_app_intents/src/platform/ios_app_intents_platform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('IOSAppIntentsPlatform', () {
    late IOSAppIntentsPlatform platform;
    late MethodChannel channel;

    setUp(() {
      platform = IOSAppIntentsPlatform();
      channel = const MethodChannel('flutter_app_intents');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'getIOSVersion') {
            return 16;
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

    test('platformName returns iOS', () {
      expect(platform.platformName, equals('iOS'));
    });

    test('isSupported returns false on non-iOS platforms', () {
      // On non-iOS platforms during testing (like macOS),
      // isSupported returns false
      expect(platform.isSupported, isFalse);
    });

    // Note: The following tests would fail on non-iOS platforms because
    // Platform.isIOS is false. In a real iOS environment, these would
    // work correctly. For comprehensive testing, these should be run as
    // integration tests on actual iOS devices.
    //
    // Skipping these tests as they rely on Platform.isIOS being true.
    test(
      'registerIntent throws UnsupportedError on non-iOS platforms',
      () async {
        const intent = AppIntent(
          identifier: 'test',
          title: 'Test',
          description: 'Test',
        );

        // On non-iOS platforms (like macOS during testing),
        // this should throw UnsupportedError
        expect(
          () => platform.registerIntent(
            intent,
            (_) async => const AppIntentResult(success: true),
          ),
          throwsUnsupportedError,
        );
      },
      skip: 'Tests run on host platform, not iOS',
    );

    test(
      'donateIntent throws UnsupportedError on non-iOS platforms',
      () async {
        expect(
          () => platform.donateIntent('test_id', {'param': 'value'}),
          throwsUnsupportedError,
        );
      },
      skip: 'Tests run on host platform, not iOS',
    );
  });
}
