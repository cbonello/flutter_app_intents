import 'package:flutter_app_intents/src/generator/android_widget_provider_generator.dart';
import 'package:flutter_app_intents/src/generator/intent_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(AndroidWidgetProviderGenerator, () {
    late AndroidWidgetProviderGenerator generator;
    const testPackageName = 'com.example.test';

    setUp(() {
      generator = AndroidWidgetProviderGenerator();
    });

    group('generateProvider', () {
      test('returns null when presentsResult is false', () {
        final intent = ExtractedIntent()
          ..identifier = 'test_action'
          ..title = 'Test Action'
          ..presentsResult = false;

        final code = generator.generateProvider(
          intent,
          packageName: testPackageName,
        );

        expect(code, isNull);
      });

      test('returns null when presentsResult is null', () {
        final intent = ExtractedIntent()
          ..identifier = 'test_action'
          ..title = 'Test Action';

        final code = generator.generateProvider(
          intent,
          packageName: testPackageName,
        );

        expect(code, isNull);
      });

      test('generates Kotlin code when presentsResult is true', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..title = 'Get Weather'
          ..presentsResult = true;

        final code = generator.generateProvider(
          intent,
          packageName: testPackageName,
        );

        expect(code, isNotNull);
        expect(code, isA<String>());
      });

      test('throws ArgumentError when identifier is null', () {
        final intent = ExtractedIntent()
          ..identifier = null
          ..presentsResult = true;

        expect(
          () => generator.generateProvider(
            intent,
            packageName: testPackageName,
          ),
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
          () => generator.generateProvider(
            intent,
            packageName: testPackageName,
          ),
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
          () => generator.generateProvider(
            intent,
            packageName: testPackageName,
          ),
          returnsNormally,
        );
      });
    });

    group('generated Kotlin code structure', () {
      test('includes correct package declaration', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..presentsResult = true;

        final code = generator.generateProvider(
          intent,
          packageName: testPackageName,
        );

        expect(code, contains('package $testPackageName'));
      });

      test('includes required imports', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..presentsResult = true;

        final code = generator.generateProvider(
          intent,
          packageName: testPackageName,
        );

        expect(code, contains('import android.appwidget.AppWidgetManager'));
        expect(code, contains('import android.appwidget.AppWidgetProvider'));
        expect(code, contains('import android.content.Context'));
        expect(code, contains('import android.widget.RemoteViews'));
      });

      test('generates class extending AppWidgetProvider', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..presentsResult = true;

        final code = generator.generateProvider(
          intent,
          packageName: testPackageName,
        );

        expect(code, contains('class GetWeatherWidgetProvider'));
        expect(code, contains(': AppWidgetProvider()'));
      });

      test('includes onUpdate override', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..presentsResult = true;

        final code = generator.generateProvider(
          intent,
          packageName: testPackageName,
        );

        expect(code, contains('override fun onUpdate'));
        expect(code, contains('appWidgetIds: IntArray'));
      });

      test('includes companion object with updateWidget method', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..presentsResult = true;

        final code = generator.generateProvider(
          intent,
          packageName: testPackageName,
        );

        expect(code, contains('companion object'));
        expect(code, contains('fun updateWidget'));
      });

      test('updateWidget includes intentId parameter', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..presentsResult = true;

        final code = generator.generateProvider(
          intent,
          packageName: testPackageName,
        );

        // Check that updateWidget takes intentId as parameter
        expect(code, contains('intentId: String'));
        expect(code, contains('resultText: String'));
      });

      test('updateWidget validates intentId', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..presentsResult = true;

        final code = generator.generateProvider(
          intent,
          packageName: testPackageName,
        );

        // Should have validation check
        expect(code, contains('if (intentId != "get_weather")'));
        expect(code, contains('return'));
      });

      test('uses string resource for loading text', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..presentsResult = true;

        final code = generator.generateProvider(
          intent,
          packageName: testPackageName,
        );

        // Should use string resource, not hardcoded text
        expect(code, contains('R.string.widget_get_weather_loading'));
        expect(code, contains('context.getString'));
        expect(code, isNot(contains('"Waiting for result..."')));
      });

      test('references correct layout resource', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..presentsResult = true;

        final code = generator.generateProvider(
          intent,
          packageName: testPackageName,
        );

        expect(code, contains('R.layout.widget_get_weather'));
      });

      test('updates widget_result TextView', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..presentsResult = true;

        final code = generator.generateProvider(
          intent,
          packageName: testPackageName,
        );

        expect(code, contains('R.id.widget_result'));
        expect(code, contains('setTextViewText'));
      });
    });

    group('class name generation', () {
      test('converts snake_case to PascalCase', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_current_weather'
          ..presentsResult = true;

        final code = generator.generateProvider(
          intent,
          packageName: testPackageName,
        );

        expect(code, contains('class GetCurrentWeatherWidgetProvider'));
      });

      test('handles single word identifier', () {
        final intent = ExtractedIntent()
          ..identifier = 'weather'
          ..presentsResult = true;

        final code = generator.generateProvider(
          intent,
          packageName: testPackageName,
        );

        expect(code, contains('class WeatherWidgetProvider'));
      });

      test('handles numbers in identifier', () {
        final intent = ExtractedIntent()
          ..identifier = 'test123'
          ..presentsResult = true;

        final code = generator.generateProvider(
          intent,
          packageName: testPackageName,
        );

        expect(code, contains('class Test123WidgetProvider'));
      });
    });

    group('getProviderFileName', () {
      test('returns correct file name for simple identifier', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..presentsResult = true;

        final fileName = generator.getProviderFileName(intent);

        expect(fileName, equals('GetWeatherWidgetProvider.kt'));
      });

      test('returns correct file name for identifier with underscores', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_current_weather'
          ..presentsResult = true;

        final fileName = generator.getProviderFileName(intent);

        expect(fileName, equals('GetCurrentWeatherWidgetProvider.kt'));
      });

      test('file name follows Kotlin naming convention', () {
        final intent = ExtractedIntent()
          ..identifier = 'test'
          ..presentsResult = true;

        final fileName = generator.getProviderFileName(intent);

        // Should be PascalCase with .kt extension
        expect(fileName, matches(RegExp(r'^[A-Z][a-zA-Z0-9]*\.kt$')));
      });
    });

    group('getProviderQualifiedName', () {
      test('returns correct qualified name', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..presentsResult = true;

        final qualifiedName = generator.getProviderQualifiedName(
          intent,
          packageName: testPackageName,
        );

        expect(
          qualifiedName,
          equals('$testPackageName.GetWeatherWidgetProvider'),
        );
      });

      test('handles different package names', () {
        final intent = ExtractedIntent()
          ..identifier = 'test'
          ..presentsResult = true;

        final qualifiedName1 = generator.getProviderQualifiedName(
          intent,
          packageName: 'com.example.app1',
        );

        final qualifiedName2 = generator.getProviderQualifiedName(
          intent,
          packageName: 'com.example.app2',
        );

        expect(qualifiedName1, equals('com.example.app1.TestWidgetProvider'));
        expect(qualifiedName2, equals('com.example.app2.TestWidgetProvider'));
      });
    });

    group('documentation and comments', () {
      test('includes class-level KDoc', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..presentsResult = true;

        final code = generator.generateProvider(
          intent,
          packageName: testPackageName,
        );

        expect(code, contains('/**'));
        expect(code, contains('* AppWidgetProvider for displaying results'));
        expect(code, contains('* This widget is automatically generated'));
      });

      test('includes method-level KDoc for updateWidget', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..presentsResult = true;

        final code = generator.generateProvider(
          intent,
          packageName: testPackageName,
        );

        expect(code, contains('* Updates the widget with new result text'));
        expect(code, contains('@param context'));
        expect(code, contains('@param appWidgetManager'));
        expect(code, contains('@param intentId'));
      });

      test('includes usage example in documentation', () {
        final intent = ExtractedIntent()
          ..identifier = 'get_weather'
          ..presentsResult = true;

        final code = generator.generateProvider(
          intent,
          packageName: testPackageName,
        );

        expect(code, contains('To update the widget'));
        expect(code, contains('updateWidget('));
      });
    });

    group('multiple intent generation', () {
      test('generates unique classes for different intents', () {
        final intents = [
          ExtractedIntent()
            ..identifier = 'get_weather'
            ..presentsResult = true,
          ExtractedIntent()
            ..identifier = 'check_balance'
            ..presentsResult = true,
        ];

        final codes = intents
            .map(
              (i) => generator.generateProvider(
                i,
                packageName: testPackageName,
              ),
            )
            .toList();

        expect(codes[0], contains('GetWeatherWidgetProvider'));
        expect(codes[1], contains('CheckBalanceWidgetProvider'));

        // Should reference different layouts
        expect(codes[0], contains('R.layout.widget_get_weather'));
        expect(codes[1], contains('R.layout.widget_check_balance'));

        // Should reference different string resources
        expect(codes[0], contains('R.string.widget_get_weather_loading'));
        expect(codes[1], contains('R.string.widget_check_balance_loading'));
      });
    });

    group('edge cases', () {
      test('handles intent without title', () {
        final intent = ExtractedIntent()
          ..identifier = 'test'
          ..presentsResult = true;

        final code = generator.generateProvider(
          intent,
          packageName: testPackageName,
        );

        expect(code, isNotNull);
        expect(code, contains('class TestWidgetProvider'));
      });

      test('handles long identifier', () {
        final intent = ExtractedIntent()
          ..identifier = 'very_long_intent_identifier_with_many_words'
          ..presentsResult = true;

        final code = generator.generateProvider(
          intent,
          packageName: testPackageName,
        );

        expect(code, isNotNull);
        expect(
          code,
          contains('VeryLongIntentIdentifierWithManyWordsWidgetProvider'),
        );
      });
    });
  });
}
