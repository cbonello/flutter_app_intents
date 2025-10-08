import 'package:flutter_app_intents/src/generator/android_strings_generator.dart';
import 'package:flutter_app_intents/src/generator/intent_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(AndroidStringsGenerator, () {
    late AndroidStringsGenerator generator;

    setUp(() {
      generator = AndroidStringsGenerator();
    });

    group('generateStrings', () {
      test('returns null when no intents present results', () {
        final intents = [
          ExtractedIntent()
            ..identifier = 'test_action'
            ..title = 'Test Action'
            ..presentsResult = false,
        ];

        final xml = generator.generateStrings(intents);

        expect(xml, isNull);
      });

      test('returns null when presentsResult is null', () {
        final intents = [
          ExtractedIntent()
            ..identifier = 'test_action'
            ..title = 'Test Action',
        ];

        final xml = generator.generateStrings(intents);

        expect(xml, isNull);
      });

      test('returns null for empty intent list', () {
        final xml = generator.generateStrings([]);

        expect(xml, isNull);
      });

      test('generates XML when presentsResult is true', () {
        final intents = [
          ExtractedIntent()
            ..identifier = 'get_counter'
            ..title = 'Get Counter'
            ..presentsResult = true,
        ];

        final xml = generator.generateStrings(intents);

        expect(xml, isNotNull);
        expect(xml, isA<String>());
      });

      test('generates correct XML structure', () {
        final intents = [
          ExtractedIntent()
            ..identifier = 'get_counter'
            ..title = 'Get Counter'
            ..presentsResult = true,
        ];

        final xml = generator.generateStrings(intents);

        // Check XML declaration
        expect(xml, contains('<?xml version="1.0" encoding="utf-8"?>'));

        // Check root element
        expect(xml, contains('<resources>'));
        expect(xml, contains('</resources>'));
      });

      test('generates description string resource', () {
        final intents = [
          ExtractedIntent()
            ..identifier = 'get_counter'
            ..title = 'Get Counter'
            ..presentsResult = true,
        ];

        final xml = generator.generateStrings(intents);

        // Check description string resource
        expect(
          xml,
          contains('<string name="widget_get_counter_description">'),
        );
        expect(xml, contains('Displays get counter results'));
        expect(xml, contains('</string>'));
      });

      test('generates loading string resource', () {
        final intents = [
          ExtractedIntent()
            ..identifier = 'get_counter'
            ..title = 'Get Counter'
            ..presentsResult = true,
        ];

        final xml = generator.generateStrings(intents);

        // Check loading string resource
        expect(xml, contains('<string name="widget_get_counter_loading">'));
        expect(xml, contains('Loading Get Counter…'));
        expect(xml, contains('</string>'));
      });

      test('generates header comments', () {
        final intents = [
          ExtractedIntent()
            ..identifier = 'get_counter'
            ..title = 'Get Counter'
            ..presentsResult = true,
        ];

        final xml = generator.generateStrings(intents);

        // Check for header comments
        expect(
          xml,
          contains('Widget string resources - auto-generated'),
        );
        expect(
          xml,
          contains('You can customize these strings for localization'),
        );
      });

      test('generates intent-specific comments', () {
        final intents = [
          ExtractedIntent()
            ..identifier = 'get_counter'
            ..title = 'Get Counter'
            ..presentsResult = true,
        ];

        final xml = generator.generateStrings(intents);

        // Check for intent-specific comment
        expect(xml, contains('Strings for get_counter intent'));
      });

      test('uses "Result" as default title when null', () {
        final intents = [
          ExtractedIntent()
            ..identifier = 'get_counter'
            ..presentsResult = true,
        ];

        final xml = generator.generateStrings(intents);

        // Should use "Result" as fallback
        expect(xml, contains('Displays result results'));
        expect(xml, contains('Loading Result…'));
      });

      test('handles multiple widget intents', () {
        final intents = [
          ExtractedIntent()
            ..identifier = 'get_counter'
            ..title = 'Get Counter'
            ..presentsResult = true,
          ExtractedIntent()
            ..identifier = 'get_weather'
            ..title = 'Get Weather'
            ..presentsResult = true,
        ];

        final xml = generator.generateStrings(intents);

        // Check for both intents
        expect(
          xml,
          contains('<string name="widget_get_counter_description">'),
        );
        expect(
          xml,
          contains('<string name="widget_get_weather_description">'),
        );
        expect(xml, contains('<string name="widget_get_counter_loading">'));
        expect(xml, contains('<string name="widget_get_weather_loading">'));
      });

      test('filters mixed intent types correctly', () {
        final intents = [
          ExtractedIntent()
            ..identifier = 'increment_counter'
            ..title = 'Increment Counter'
            ..presentsResult = false,
          ExtractedIntent()
            ..identifier = 'get_counter'
            ..title = 'Get Counter'
            ..presentsResult = true,
        ];

        final xml = generator.generateStrings(intents);

        // Should only include the widget intent
        expect(
          xml,
          contains('<string name="widget_get_counter_description">'),
        );
        expect(
          xml,
          isNot(contains('widget_increment_counter')),
        );
      });
    });

    group('XML formatting', () {
      test('generates pretty-printed XML with proper indentation', () {
        final intents = [
          ExtractedIntent()
            ..identifier = 'get_counter'
            ..title = 'Get Counter'
            ..presentsResult = true,
        ];

        final xml = generator.generateStrings(intents);

        // Check for proper formatting
        final lines = xml!.split('\n');

        // Should have multiple lines for readability
        expect(lines.length, greaterThanOrEqualTo(3));

        // Root element should not be indented
        expect(
          lines.firstWhere((line) => line.contains('<resources>')),
          matches(RegExp('^<resources>')),
        );
      });

      test('uses 4-space indentation', () {
        final intents = [
          ExtractedIntent()
            ..identifier = 'get_counter'
            ..title = 'Get Counter'
            ..presentsResult = true,
        ];

        final xml = generator.generateStrings(intents);

        // String elements should be indented with 4 spaces
        expect(xml, contains('    <string name='));
      });

      test('XML is parseable and well-formed', () {
        final intents = [
          ExtractedIntent()
            ..identifier = 'get_counter'
            ..title = 'Get Counter'
            ..presentsResult = true,
        ];

        final xml = generator.generateStrings(intents);

        // Basic XML validation - should have matching tags
        expect(xml, contains('<resources>'));
        expect(xml, contains('</resources>'));

        // Should have exactly 2 string elements for 1 intent
        final stringOpen = '<string'.allMatches(xml!).length;
        final stringClose = '</string>'.allMatches(xml).length;
        expect(stringOpen, equals(2));
        expect(stringClose, equals(2));
      });
    });

    group('getStringsFilePath', () {
      test('returns correct path for strings.xml', () {
        final path = generator.getStringsFilePath();

        expect(
          path,
          equals('android/app/src/main/res/values/strings.xml'),
        );
      });
    });

    group('mergeWithExisting', () {
      test('preserves non-widget strings', () {
        const existingContent = '''
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">My App</string>
    <string name="welcome_message">Welcome!</string>
</resources>
''';

        final newStrings = generator.generateStrings([
          ExtractedIntent()
            ..identifier = 'get_counter'
            ..title = 'Get Counter'
            ..presentsResult = true,
        ])!;

        final merged = generator.mergeWithExisting(
          existingContent,
          newStrings,
        );

        // Original strings should be preserved
        expect(merged, contains('<string name="app_name">'));
        expect(merged, contains('My App'));
        expect(merged, contains('<string name="welcome_message">'));
        expect(merged, contains('Welcome!'));

        // New widget strings should be added
        expect(
          merged,
          contains('<string name="widget_get_counter_description">'),
        );
        expect(merged, contains('<string name="widget_get_counter_loading">'));
      });

      test('removes old widget strings', () {
        const existingContent = '''
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">My App</string>
    <string name="widget_old_intent_description">Old description</string>
    <string name="widget_old_intent_loading">Old loading</string>
</resources>
''';

        final newStrings = generator.generateStrings([
          ExtractedIntent()
            ..identifier = 'get_counter'
            ..title = 'Get Counter'
            ..presentsResult = true,
        ])!;

        final merged = generator.mergeWithExisting(
          existingContent,
          newStrings,
        );

        // Old widget strings should be removed
        expect(merged, isNot(contains('widget_old_intent_description')));
        expect(merged, isNot(contains('widget_old_intent_loading')));
        expect(merged, isNot(contains('Old description')));
        expect(merged, isNot(contains('Old loading')));

        // New widget strings should be present
        expect(
          merged,
          contains('<string name="widget_get_counter_description">'),
        );
      });

      test('updates widget strings when regenerated', () {
        const existingContent = '''
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="widget_get_counter_description">Old description</string>
    <string name="widget_get_counter_loading">Old loading</string>
</resources>
''';

        final newStrings = generator.generateStrings([
          ExtractedIntent()
            ..identifier = 'get_counter'
            ..title = 'Get Counter'
            ..presentsResult = true,
        ])!;

        final merged = generator.mergeWithExisting(
          existingContent,
          newStrings,
        );

        // Should have new generated content
        expect(merged, contains('Displays get counter results'));
        expect(merged, contains('Loading Get Counter…'));

        // Should not have old content
        expect(merged, isNot(contains('Old description')));
        expect(merged, isNot(contains('Old loading')));
      });

      test('returns new content when parsing existing content fails', () {
        const invalidExistingContent = 'This is not valid XML';

        final newStrings = generator.generateStrings([
          ExtractedIntent()
            ..identifier = 'get_counter'
            ..title = 'Get Counter'
            ..presentsResult = true,
        ])!;

        final merged = generator.mergeWithExisting(
          invalidExistingContent,
          newStrings,
        );

        // Should return the new content when parsing fails
        expect(merged, equals(newStrings));
      });

      test('handles empty existing resources', () {
        const existingContent = '''
<?xml version="1.0" encoding="utf-8"?>
<resources>
</resources>
''';

        final newStrings = generator.generateStrings([
          ExtractedIntent()
            ..identifier = 'get_counter'
            ..title = 'Get Counter'
            ..presentsResult = true,
        ])!;

        final merged = generator.mergeWithExisting(
          existingContent,
          newStrings,
        );

        // New widget strings should be present
        expect(
          merged,
          contains('<string name="widget_get_counter_description">'),
        );
        expect(merged, contains('<string name="widget_get_counter_loading">'));
      });
    });

    group('description and loading text generation', () {
      test('generates description with lowercase title', () {
        final intents = [
          ExtractedIntent()
            ..identifier = 'get_counter'
            ..title = 'Get Counter'
            ..presentsResult = true,
        ];

        final xml = generator.generateStrings(intents);

        // Title should be lowercased in description
        expect(xml, contains('Displays get counter results'));
      });

      test('generates loading text with original title', () {
        final intents = [
          ExtractedIntent()
            ..identifier = 'get_counter'
            ..title = 'Get Counter'
            ..presentsResult = true,
        ];

        final xml = generator.generateStrings(intents);

        // Title should keep original case in loading text
        expect(xml, contains('Loading Get Counter…'));
      });

      test('handles title with special characters', () {
        final intents = [
          ExtractedIntent()
            ..identifier = 'get_data'
            ..title = "User's Data & Info"
            ..presentsResult = true,
        ];

        final xml = generator.generateStrings(intents);

        expect(xml, isNotNull);
        // XML escaping should be handled by XmlBuilder
        expect(xml, contains('<string name="widget_get_data_description">'));
      });

      test('handles empty title string', () {
        final intents = [
          ExtractedIntent()
            ..identifier = 'get_data'
            ..title = ''
            ..presentsResult = true,
        ];

        final xml = generator.generateStrings(intents);

        // Empty title becomes empty in the generated text
        expect(xml, contains('Displays results'));
        expect(xml, contains('Loading …'));
      });
    });

    group('edge cases', () {
      test('handles intent with long identifier', () {
        final intents = [
          ExtractedIntent()
            ..identifier = 'get_very_long_counter_value_from_database'
            ..title = 'Get Counter'
            ..presentsResult = true,
        ];

        final xml = generator.generateStrings(intents);

        expect(xml, isNotNull);
        expect(
          xml,
          contains(
            '<string name="widget_get_very_long_counter_value_from_database_description">',
          ),
        );
      });

      test('handles multiple intents with similar identifiers', () {
        final intents = [
          ExtractedIntent()
            ..identifier = 'get_counter'
            ..title = 'Get Counter'
            ..presentsResult = true,
          ExtractedIntent()
            ..identifier = 'get_counter_value'
            ..title = 'Get Counter Value'
            ..presentsResult = true,
        ];

        final xml = generator.generateStrings(intents);

        // Both should be present with unique names
        expect(
          xml,
          contains('<string name="widget_get_counter_description">'),
        );
        expect(
          xml,
          contains('<string name="widget_get_counter_value_description">'),
        );
      });

      test('handles intent with underscores in identifier', () {
        final intents = [
          ExtractedIntent()
            ..identifier = 'get_user_profile_data'
            ..title = 'Get Profile'
            ..presentsResult = true,
        ];

        final xml = generator.generateStrings(intents);

        expect(
          xml,
          contains(
            '<string name="widget_get_user_profile_data_description">',
          ),
        );
      });
    });

    group('consistency with other generators', () {
      test('string resource names match widget info expectations', () {
        final intents = [
          ExtractedIntent()
            ..identifier = 'get_counter'
            ..title = 'Get Counter'
            ..presentsResult = true,
        ];

        final xml = generator.generateStrings(intents);

        // Should match the pattern used by widget info generator
        expect(
          xml,
          contains('<string name="widget_get_counter_description">'),
        );
      });

      test('string resource names match widget provider expectations', () {
        final intents = [
          ExtractedIntent()
            ..identifier = 'get_counter'
            ..title = 'Get Counter'
            ..presentsResult = true,
        ];

        final xml = generator.generateStrings(intents);

        // Should match the pattern used by widget provider generator
        expect(xml, contains('<string name="widget_get_counter_loading">'));
      });

      test('generates strings for all widget intents', () {
        final intents = [
          ExtractedIntent()
            ..identifier = 'get_counter'
            ..title = 'Get Counter'
            ..presentsResult = true,
          ExtractedIntent()
            ..identifier = 'get_weather'
            ..title = 'Get Weather'
            ..presentsResult = true,
          ExtractedIntent()
            ..identifier = 'check_status'
            ..title = 'Check Status'
            ..presentsResult = true,
        ];

        final xml = generator.generateStrings(intents);

        // Should have 2 strings per intent (description + loading)
        final stringCount = '<string'.allMatches(xml!).length;
        expect(stringCount, equals(intents.length * 2));
      });
    });
  });
}
