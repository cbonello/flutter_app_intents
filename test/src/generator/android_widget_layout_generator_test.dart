import 'package:flutter_app_intents/src/generator/android_widget_layout_generator.dart';
import 'package:flutter_app_intents/src/generator/intent_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(AndroidWidgetLayoutGenerator, () {
    late AndroidWidgetLayoutGenerator generator;

    setUp(() {
      generator = AndroidWidgetLayoutGenerator();
    });

    group('generateLayout', () {
      test('returns null when presentsResult is false', () {
        final intent = ExtractedIntent()
          ..identifier = 'test_action'
          ..title = 'Test Action'
          ..presentsResult = false;

        final xml = generator.generateLayout(intent);

        expect(xml, isNull);
      });

      test('returns null when presentsResult is null', () {
        final intent = ExtractedIntent()
          ..identifier = 'test_action'
          ..title = 'Test Action';

        final xml = generator.generateLayout(intent);

        expect(xml, isNull);
      });

      test('generates XML when presentsResult is true', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..title = 'Get Weather'
          ..presentsResult = true;

        final xml = generator.generateLayout(intent);

        expect(xml, isNotNull);
        expect(xml, isA<String>());
      });

      test('generates correct XML structure', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..title = 'Get Weather'
          ..presentsResult = true;

        final xml = generator.generateLayout(intent);

        // Check XML declaration
        expect(xml, contains('<?xml version="1.0" encoding="utf-8"?>'));

        // Check root element
        expect(xml, contains('<LinearLayout'));
        expect(xml, contains('</LinearLayout>'));

        // Check namespace
        expect(
          xml,
          contains(
            'xmlns:android="http://schemas.android.com/apk/res/android"',
          ),
        );
      });
    });

    group('layout structure', () {
      test('generates LinearLayout with correct attributes', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..title = 'Get Weather'
          ..presentsResult = true;

        final xml = generator.generateLayout(intent);

        // Check LinearLayout attributes
        expect(xml, contains('android:layout_width="match_parent"'));
        expect(xml, contains('android:layout_height="wrap_content"'));
        expect(xml, contains('android:orientation="vertical"'));
        expect(xml, contains('android:padding="16dp"'));
        expect(xml, contains('android:gravity="center"'));
        expect(xml, contains('android:background="#00000000"'));
      });

      test('generates title TextView with correct attributes', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..title = 'Get Weather'
          ..presentsResult = true;

        final xml = generator.generateLayout(intent);

        // Check title TextView
        expect(xml, contains('android:id="@+id/widget_title"'));
        expect(xml, contains('android:textSize="16sp"'));
        expect(xml, contains('android:textStyle="bold"'));
        expect(xml, contains('android:textColor="#000000"'));
        expect(xml, contains('android:layout_marginBottom="8dp"'));
      });

      test('generates result TextView with correct attributes', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..title = 'Get Weather'
          ..presentsResult = true;

        final xml = generator.generateLayout(intent);

        // Check result TextView
        expect(xml, contains('android:id="@+id/widget_result"'));
        expect(xml, contains('android:textSize="14sp"'));
        expect(xml, contains('android:textColor="#666666"'));
      });

      test('title TextView displays intent title', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..title = 'Get Weather'
          ..presentsResult = true;

        final xml = generator.generateLayout(intent);

        // The title should be in the XML as an attribute
        expect(xml, contains('android:text="Get Weather"'));
      });

      test('result TextView references string resource for loading text', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..title = 'Get Weather'
          ..presentsResult = true;

        final xml = generator.generateLayout(intent);

        // The loading text should reference a string resource
        expect(xml, contains('@string/widget_get_weather_loading'));
      });

      test('uses "Result" as default title when intent title is null', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..presentsResult = true;

        final xml = generator.generateLayout(intent);

        // Should use "Result" as fallback title
        expect(xml, contains('android:text="Result"'));
      });
    });

    group('TextView IDs and accessibility', () {
      test('generates unique IDs for title and result TextViews', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..title = 'Get Weather'
          ..presentsResult = true;

        final xml = generator.generateLayout(intent);

        // Check both IDs are present
        expect(xml, contains('@+id/widget_title'));
        expect(xml, contains('@+id/widget_result'));

        // IDs should be different
        expect(
          xml!.indexOf('@+id/widget_title'),
          isNot(equals(xml.indexOf('@+id/widget_result'))),
        );
      });

      test('TextViews have proper layout width and height', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..title = 'Get Weather'
          ..presentsResult = true;

        final xml = generator.generateLayout(intent);

        // Both TextViews should have match_parent width and wrap_content height
        final textViewMatches = RegExp(
          '<TextView[^>]*android:layout_width="match_parent"[^>]*'
          'android:layout_height="wrap_content"',
          multiLine: true,
        ).allMatches(xml!);

        expect(textViewMatches.length, equals(2));
      });

      test('TextViews have center gravity for alignment', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..title = 'Get Weather'
          ..presentsResult = true;

        final xml = generator.generateLayout(intent);

        // Both TextViews should have center gravity
        final centerGravityMatches = RegExp(
          '<TextView[^>]*android:gravity="center"',
          multiLine: true,
        ).allMatches(xml!);

        expect(centerGravityMatches.length, equals(2));
      });
    });

    group('getLayoutFileName', () {
      test('returns correct file name for simple identifier', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..presentsResult = true;

        final fileName = generator.getLayoutFileName(intent);

        expect(fileName, equals('widget_get_weather.xml'));
      });

      test('returns correct file name for identifier with underscores', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_current_weather'
          ..presentsResult = true;

        final fileName = generator.getLayoutFileName(intent);

        expect(fileName, equals('widget_get_current_weather.xml'));
      });

      test('returns correct file name for different identifiers', () {
        final testCases = {
          'test': 'widget_test.xml',
          'check_balance': 'widget_check_balance.xml',
          'get_status': 'widget_get_status.xml',
          'query_data': 'widget_query_data.xml',
        };

        for (final entry in testCases.entries) {
          final intent = ExtractedIntent()
            ..identifier = entry.key
            ..presentsResult = true;

          final fileName = generator.getLayoutFileName(intent);

          expect(fileName, equals(entry.value));
        }
      });
    });

    group('getLayoutResourceId', () {
      test('returns correct resource ID for simple identifier', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..presentsResult = true;

        final resourceId = generator.getLayoutResourceId(intent);

        expect(resourceId, equals('R.layout.widget_get_weather'));
      });

      test('returns correct resource ID for identifier with underscores', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_current_weather'
          ..presentsResult = true;

        final resourceId = generator.getLayoutResourceId(intent);

        expect(resourceId, equals('R.layout.widget_get_current_weather'));
      });

      test('returns correct resource ID for different identifiers', () {
        final testCases = {
          'test': 'R.layout.widget_test',
          'check_balance': 'R.layout.widget_check_balance',
          'get_status': 'R.layout.widget_get_status',
        };

        for (final entry in testCases.entries) {
          final intent = ExtractedIntent()
            ..identifier = entry.key
            ..presentsResult = true;

          final resourceId = generator.getLayoutResourceId(intent);

          expect(resourceId, equals(entry.value));
        }
      });
    });

    group('XML formatting', () {
      test('generates pretty-printed XML with proper indentation', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..title = 'Get Weather'
          ..presentsResult = true;

        final xml = generator.generateLayout(intent);

        // Check for proper formatting
        final lines = xml!.split('\n');

        // Should have multiple lines for readability (at least 3: declaration,
        // layout, elements)
        expect(lines.length, greaterThanOrEqualTo(3));

        // Root element should not be indented
        expect(
          lines.firstWhere((line) => line.contains('<LinearLayout')),
          matches(RegExp('^<LinearLayout')),
        );
      });

      test('XML is parseable and well-formed', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..title = 'Get Weather'
          ..presentsResult = true;

        final xml = generator.generateLayout(intent);

        // Basic XML validation - should have matching tags
        expect(xml, contains('<LinearLayout'));
        expect(xml, contains('</LinearLayout>'));

        // Should have exactly 2 TextView elements
        final textViewOpen = '<TextView'.allMatches(xml!).length;
        expect(textViewOpen, equals(2));

        // LinearLayout should appear exactly once
        expect('<LinearLayout'.allMatches(xml).length, equals(1));
        expect('</LinearLayout>'.allMatches(xml).length, equals(1));
      });
    });

    group('validation', () {
      test('throws ArgumentError when identifier is null', () {
        final intent = ExtractedIntent()
          ..identifier = null
          ..presentsResult = true;

        expect(
          () => generator.generateLayout(intent),
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
          () => generator.generateLayout(intent),
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
          () => generator.generateLayout(intent),
          returnsNormally,
        );
      });
    });

    group('edge cases', () {
      test('handles intent with minimal required fields', () {
        final intent = ExtractedIntent()
          ..identifier = 'test'
          ..presentsResult = true;

        final xml = generator.generateLayout(intent);

        expect(xml, isNotNull);
        expect(xml, contains('<LinearLayout'));
        expect(xml, contains('<TextView'));
      });

      test('handles intent without title', () {
        final intent = ExtractedIntent()
          ..identifier = 'no_title'
          ..presentsResult = true;

        final xml = generator.generateLayout(intent);

        expect(xml, isNotNull);
        // Should use "Result" as default title
        expect(xml, contains('android:text="Result"'));
      });

      test('handles intent with empty title', () {
        final intent = ExtractedIntent()
          ..identifier = 'empty_title'
          ..title = ''
          ..presentsResult = true;

        final xml = generator.generateLayout(intent);

        expect(xml, isNotNull);
        // Empty title should still be used (or show Result as fallback)
        expect(xml, contains('widget_title'));
      });

      test('handles intent with special characters in title', () {
        final intent = ExtractedIntent()
          ..identifier = 'special_chars'
          ..title = 'Test & Weather <Info>'
          ..presentsResult = true;

        final xml = generator.generateLayout(intent);

        expect(xml, isNotNull);
        // Special characters should be properly escaped in XML
        expect(xml, contains('<TextView'));
      });

      test('handles intent with long identifier', () {
        final intent = ExtractedIntent()
          ..identifier = 'very_long_intent_identifier_with_many_words'
          ..title = 'Long Intent'
          ..presentsResult = true;

        final xml = generator.generateLayout(intent);

        expect(xml, isNotNull);
        final fileName = generator.getLayoutFileName(intent);
        expect(
          fileName,
          equals('widget_very_long_intent_identifier_with_many_words.xml'),
        );
      });
    });

    group('multiple intent generation', () {
      test('generates different layouts for different intents', () {
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

        final xmlOutputs = <String>[];

        for (final intent in intents) {
          final xml = generator.generateLayout(intent);
          expect(xml, isNotNull);
          xmlOutputs.add(xml!);

          // Each should have the correct title
          expect(xml, contains('android:text="${intent.title}"'));
        }

        // All outputs should be unique (different titles)
        expect(xmlOutputs.toSet().length, equals(intents.length));
      });

      test('generates consistent structure for all intents', () {
        final intents = [
          ExtractedIntent()
            ..identifier = 'intent1'
            ..title = 'Intent 1'
            ..presentsResult = true,
          ExtractedIntent()
            ..identifier = 'intent2'
            ..title = 'Intent 2'
            ..presentsResult = true,
        ];

        for (final intent in intents) {
          final xml = generator.generateLayout(intent);

          // All should have the same structure
          expect(xml, contains('<LinearLayout'));
          expect(xml, contains('@+id/widget_title'));
          expect(xml, contains('@+id/widget_result'));
          expect(
            xml,
            contains('@string/widget_${intent.identifier}_loading'),
          );
          expect(xml, contains('android:orientation="vertical"'));
        }
      });
    });

    group('consistency with other generators', () {
      test('file naming matches AndroidWidgetProviderGenerator convention', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..presentsResult = true;

        final fileName = generator.getLayoutFileName(intent);

        // Should follow widget_<identifier>.xml pattern
        expect(fileName, matches(RegExp(r'^widget_[a-z0-9_]+\.xml$')));
      });

      test('resource ID format matches Android conventions', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..presentsResult = true;

        final resourceId = generator.getLayoutResourceId(intent);

        // Should follow R.layout.widget_<identifier> pattern
        expect(resourceId, matches(RegExp(r'^R\.layout\.widget_[a-z0-9_]+$')));
      });

      test('layout naming follows Android resource conventions', () {
        final testCases = [
          'get_weather',
          'check_balance',
          'test123',
          'query_data_now',
        ];

        for (final identifier in testCases) {
          final intent = ExtractedIntent()
            ..identifier = identifier
            ..presentsResult = true;

          final fileName = generator.getLayoutFileName(intent);

          // Android layout names must be lowercase with underscores
          expect(fileName, equals(fileName.toLowerCase()));
          expect(fileName, isNot(contains('-')));
          expect(fileName, isNot(contains(' ')));
        }
      });
    });

    group('RemoteViews compatibility', () {
      test('uses only RemoteViews-compatible widgets', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..title = 'Get Weather'
          ..presentsResult = true;

        final xml = generator.generateLayout(intent);

        // LinearLayout and TextView are both RemoteViews-compatible
        expect(xml, contains('<LinearLayout'));
        expect(xml, contains('<TextView'));

        // Should not contain incompatible widgets
        expect(xml, isNot(contains('<Button')));
        expect(xml, isNot(contains('<EditText')));
        expect(xml, isNot(contains('<WebView')));
      });

      test('uses only RemoteViews-compatible attributes', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..title = 'Get Weather'
          ..presentsResult = true;

        final xml = generator.generateLayout(intent);

        // Check for common RemoteViews-compatible attributes
        expect(xml, contains('android:id='));
        expect(xml, contains('android:layout_width='));
        expect(xml, contains('android:layout_height='));
        expect(xml, contains('android:textSize='));
        expect(xml, contains('android:textColor='));
        expect(xml, contains('android:gravity='));
      });
    });
  });
}
