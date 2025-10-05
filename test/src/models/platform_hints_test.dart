import 'package:flutter_app_intents/src/models/platform_hints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(PlatformHints, () {
    test('fromMap() creates correct object', () {
      final map = {
        'iosSuggestedPhrase': 'Test phrase',
        'androidBIIOverride': 'test.BII',
        'androidExtras': {'key': 'value'},
      };
      final hints = PlatformHints.fromMap(map);

      expect(hints.iosSuggestedPhrase, 'Test phrase');
      expect(hints.androidBIIOverride, 'test.BII');
      expect(hints.androidExtras, {'key': 'value'});
    });

    test('toMap() creates correct map', () {
      const hints = PlatformHints(
        iosSuggestedPhrase: 'Test phrase',
        androidBIIOverride: 'test.BII',
        androidExtras: {'key': 'value'},
      );
      final map = hints.toMap();

      expect(map['iosSuggestedPhrase'], 'Test phrase');
      expect(map['androidBIIOverride'], 'test.BII');
      expect(map['androidExtras'], {'key': 'value'});
    });

    test('toMap() omits null values', () {
      const hints = PlatformHints();
      final map = hints.toMap();

      expect(map.containsKey('iosSuggestedPhrase'), isFalse);
      expect(map.containsKey('androidBIIOverride'), isFalse);
      expect(map.containsKey('androidExtras'), isFalse);
    });

    test('copyWith() creates correct object', () {
      const hints1 = PlatformHints(
        iosSuggestedPhrase: 'Original phrase',
        androidBIIOverride: 'original.BII',
      );

      final hints2 = hints1.copyWith(androidBIIOverride: 'new.BII');

      expect(hints2.iosSuggestedPhrase, 'Original phrase');
      expect(hints2.androidBIIOverride, 'new.BII');
      expect(hints2.androidExtras, isNull);
    });

    test('props[] are correct for equatable', () {
      const hints1 = PlatformHints(
        iosSuggestedPhrase: 'Test phrase',
        androidBIIOverride: 'test.BII',
        androidExtras: {'key': 'value'},
      );
      const hints2 = PlatformHints(
        iosSuggestedPhrase: 'Test phrase',
        androidBIIOverride: 'test.BII',
        androidExtras: {'key': 'value'},
      );
      expect(hints1, equals(hints2));
    });
  });
}
