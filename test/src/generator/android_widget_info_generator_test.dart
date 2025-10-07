import 'package:flutter_app_intents/src/generator/android_widget_info_generator.dart';
import 'package:flutter_app_intents/src/generator/intent_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(AndroidWidgetInfoGenerator, () {
    late AndroidWidgetInfoGenerator generator;

    setUp(() {
      generator = AndroidWidgetInfoGenerator();
    });

    group('generateWidgetInfo', () {
      test('returns null when presentsResult is false', () {
        final intent = ExtractedIntent()
          ..identifier = 'test_action'
          ..title = 'Test Action'
          ..presentsResult = false;

        final xml = generator.generateWidgetInfo(intent);

        expect(xml, isNull);
      });

      test('returns null when presentsResult is null', () {
        final intent = ExtractedIntent()
          ..identifier = 'test_action'
          ..title = 'Test Action';

        final xml = generator.generateWidgetInfo(intent);

        expect(xml, isNull);
      });

      test('generates XML when presentsResult is true', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..title = 'Get Weather'
          ..presentsResult = true;

        final xml = generator.generateWidgetInfo(intent);

        expect(xml, isNotNull);
        expect(xml, isA<String>());
      });

      test('generates correct XML structure', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..title = 'Get Weather'
          ..presentsResult = true;

        final xml = generator.generateWidgetInfo(intent);

        // Check XML declaration
        expect(xml, contains('<?xml version="1.0" encoding="utf-8"?>'));

        // Check root element (self-closing tag)
        expect(xml, contains('<appwidget-provider'));

        // Check namespace
        expect(
          xml,
          contains(
            'xmlns:android="http://schemas.android.com/apk/res/android"',
          ),
        );
      });

      test('includes correct layout reference', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..title = 'Get Weather'
          ..presentsResult = true;

        final xml = generator.generateWidgetInfo(intent);

        expect(
          xml,
          contains('android:initialLayout="@layout/widget_get_weather"'),
        );
      });

      test('includes correct widget dimensions', () {
        final intent = ExtractedIntent()
          ..identifier = 'test_intent'
          ..title = 'Test Intent'
          ..presentsResult = true;

        final xml = generator.generateWidgetInfo(intent);

        expect(xml, contains('android:minWidth="180dp"'));
        expect(xml, contains('android:minHeight="40dp"'));
      });

      test('includes correct update period', () {
        final intent = ExtractedIntent()
          ..identifier = 'test_intent'
          ..title = 'Test Intent'
          ..presentsResult = true;

        final xml = generator.generateWidgetInfo(intent);

        // Update period should be 0 (manual updates only)
        expect(xml, contains('android:updatePeriodMillis="0"'));
      });

      test('includes description string reference', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..title = 'Get Weather'
          ..presentsResult = true;

        final xml = generator.generateWidgetInfo(intent);

        expect(
          xml,
          contains(
            'android:description="@string/widget_get_weather_description"',
          ),
        );
      });

      test('includes widget category', () {
        final intent = ExtractedIntent()
          ..identifier = 'test_intent'
          ..title = 'Test Intent'
          ..presentsResult = true;

        final xml = generator.generateWidgetInfo(intent);

        expect(xml, contains('android:widgetCategory="home_screen"'));
      });

      test('includes resize mode', () {
        final intent = ExtractedIntent()
          ..identifier = 'test_intent'
          ..title = 'Test Intent'
          ..presentsResult = true;

        final xml = generator.generateWidgetInfo(intent);

        expect(xml, contains('android:resizeMode="horizontal|vertical"'));
      });

      test('generates valid XML for different intent identifiers', () {
        final intents = [
          ExtractedIntent()
            ..identifier = 'get_weather'
            ..title = 'Get Weather'
            ..presentsResult = true,
          ExtractedIntent()
            ..identifier = 'check_balance'
            ..title = 'Check Balance'
            ..presentsResult = true,
          ExtractedIntent()
            ..identifier = 'get_status'
            ..title = 'Get Status'
            ..presentsResult = true,
        ];

        for (final intent in intents) {
          final xml = generator.generateWidgetInfo(intent);

          expect(xml, isNotNull);
          expect(xml, contains('<?xml version="1.0" encoding="utf-8"?>'));
          expect(xml, contains('<appwidget-provider'));
          expect(
            xml,
            contains('@layout/widget_${intent.identifier}'),
          );
          expect(
            xml,
            contains('@string/widget_${intent.identifier}_description'),
          );
        }
      });

      test('handles intent with underscores in identifier', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_current_weather'
          ..title = 'Get Current Weather'
          ..presentsResult = true;

        final xml = generator.generateWidgetInfo(intent);

        expect(xml, isNotNull);
        expect(
          xml,
          contains('@layout/widget_get_current_weather'),
        );
        expect(
          xml,
          contains('@string/widget_get_current_weather_description'),
        );
      });
    });

    group('getWidgetInfoFileName', () {
      test('returns correct file name for simple identifier', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..presentsResult = true;

        final fileName = generator.getWidgetInfoFileName(intent);

        expect(fileName, equals('get_weather_widget_info.xml'));
      });

      test('returns correct file name for identifier with underscores', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_current_weather'
          ..presentsResult = true;

        final fileName = generator.getWidgetInfoFileName(intent);

        expect(fileName, equals('get_current_weather_widget_info.xml'));
      });

      test('returns correct file name for different identifiers', () {
        final testCases = {
          'test': 'test_widget_info.xml',
          'check_balance': 'check_balance_widget_info.xml',
          'get_status': 'get_status_widget_info.xml',
          'query_data': 'query_data_widget_info.xml',
        };

        for (final entry in testCases.entries) {
          final intent = ExtractedIntent()
            ..identifier = entry.key
            ..presentsResult = true;

          final fileName = generator.getWidgetInfoFileName(intent);

          expect(fileName, equals(entry.value));
        }
      });
    });

    group('XML formatting', () {
      test('generates pretty-printed XML', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..title = 'Get Weather'
          ..presentsResult = true;

        final xml = generator.generateWidgetInfo(intent);

        // Check for proper formatting
        final lines = xml!.split('\n');

        // Should have at least XML declaration and element
        expect(lines.length, greaterThan(1));

        // Root element should not be indented
        expect(
          lines.firstWhere((line) => line.contains('<appwidget-provider')),
          matches(RegExp('^<appwidget-provider')),
        );
      });

      test('XML is parseable and well-formed', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..title = 'Get Weather'
          ..presentsResult = true;

        final xml = generator.generateWidgetInfo(intent);

        // Basic XML validation - should have proper structure
        expect(xml, contains('<appwidget-provider'));

        // Should be a self-closing element with all attributes
        expect(xml, contains('/>'));

        // Should only have one appwidget-provider element
        final matches = '<appwidget-provider'.allMatches(xml!).length;
        expect(matches, equals(1));
      });
    });

    group('edge cases', () {
      test('handles intent with minimal required fields', () {
        final intent = ExtractedIntent()
          ..identifier = 'test'
          ..presentsResult = true;

        final xml = generator.generateWidgetInfo(intent);

        expect(xml, isNotNull);
        expect(xml, contains('@layout/widget_test'));
      });

      test('handles intent without title', () {
        final intent = ExtractedIntent()
          ..identifier = 'no_title'
          ..presentsResult = true;

        final xml = generator.generateWidgetInfo(intent);

        expect(xml, isNotNull);
        // Should still generate valid XML even without title
        expect(xml, contains('<appwidget-provider'));
      });

      test('handles intent with special characters in identifier', () {
        // Note: In practice, identifiers should be valid, but let's test anyway
        final intent = ExtractedIntent()
          ..identifier = 'test123'
          ..title = 'Test 123'
          ..presentsResult = true;

        final xml = generator.generateWidgetInfo(intent);

        expect(xml, isNotNull);
        expect(xml, contains('@layout/widget_test123'));
      });
    });

    group('validation', () {
      test('throws ArgumentError when identifier is null', () {
        final intent = ExtractedIntent()
          ..identifier = null
          ..presentsResult = true;

        expect(
          () => generator.generateWidgetInfo(intent),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Intent identifier must not be null or empty'),
            ),
          ),
        );
      });

      test('throws ArgumentError when identifier is empty', () {
        final intent = ExtractedIntent()
          ..identifier = ''
          ..presentsResult = true;

        expect(
          () => generator.generateWidgetInfo(intent),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Intent identifier must not be null or empty'),
            ),
          ),
        );
      });

      test('does not throw when identifier is valid', () {
        final intent = ExtractedIntent()
          ..identifier = 'valid_id'
          ..presentsResult = true;

        expect(
          () => generator.generateWidgetInfo(intent),
          returnsNormally,
        );
      });
    });

    group('consistency with other generators', () {
      test('layout name matches AndroidWidgetLayoutGenerator convention', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..presentsResult = true;

        final xml = generator.generateWidgetInfo(intent);

        // The layout reference should match the naming convention
        // used by AndroidWidgetLayoutGenerator (widget_<identifier>)
        expect(xml, contains('@layout/widget_get_weather'));
      });

      test('file naming follows Android resource conventions', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..presentsResult = true;

        final fileName = generator.getWidgetInfoFileName(intent);

        // Android resource names should be lowercase with underscores
        expect(fileName, matches(RegExp(r'^[a-z0-9_]+\.xml$')));
      });
    });
  });
}
