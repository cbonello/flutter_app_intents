import 'package:flutter_app_intents/src/platform/app_intents_platform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(FlutterAppIntentsException, () {
    test('toString() includes message without code', () {
      const exception = FlutterAppIntentsException('Test message');
      expect(
        exception.toString(),
        equals('FlutterAppIntentsException: Test message'),
      );
    });

    test('toString() includes message and code', () {
      const exception = FlutterAppIntentsException('Test message', 'TEST_CODE');
      expect(
        exception.toString(),
        equals('FlutterAppIntentsException(TEST_CODE): Test message'),
      );
    });
  });
}
