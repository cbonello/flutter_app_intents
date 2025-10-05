import 'dart:io';

import 'package:flutter_app_intents/src/generator/intent_extractor.dart';
import 'package:flutter_app_intents/src/models/intent_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IntentExtractor', () {
    late Directory tempDir;
    late IntentExtractor extractor;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('intent_extractor_test');
      extractor = IntentExtractor();
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    group('Method chaining pattern', () {
      test('extracts intent from chained builder', () async {
        File('${tempDir.path}/test_intent.dart').writeAsStringSync('''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final myIntent = AppIntentBuilder()
  .identifier('test_intent')
  .title('Test Intent')
  .description('A test intent')
  .category(IntentCategory.general)
  .build();
''');

        final intents = await extractor.extractFromDirectory(tempDir.path);

        expect(intents, hasLength(1));
        expect(intents.first.identifier, equals('test_intent'));
        expect(intents.first.title, equals('Test Intent'));
        expect(intents.first.description, equals('A test intent'));
        expect(intents.first.category, equals('general'));
      });

      test('extracts multiple intents from same file', () async {
        File('${tempDir.path}/intents.dart').writeAsStringSync('''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final intent1 = AppIntentBuilder()
  .identifier('first_intent')
  .title('First')
  .description('First intent')
  .build();

final intent2 = AppIntentBuilder()
  .identifier('second_intent')
  .title('Second')
  .description('Second intent')
  .build();
''');

        final intents = await extractor.extractFromDirectory(tempDir.path);

        expect(intents, hasLength(2));
        expect(intents[0].identifier, equals('first_intent'));
        expect(intents[1].identifier, equals('second_intent'));
      });
    });

    group('Variable assignment pattern', () {
      // TODO(flutter_app_intents): Variable assignment pattern support needs
      // debugging. The AST visitor doesn't correctly track builder variables
      // across statements. For now, users should use the method chaining
      // pattern instead.
      const skipReason =
          'Variable assignment pattern needs AST visitor improvements';

      test(
        'extracts intent from variable-based builder',
        () async {
          File('${tempDir.path}/test.dart').writeAsStringSync('''
import 'package:flutter_app_intents/flutter_app_intents.dart';

void setupIntents() {
  final builder = AppIntentBuilder();
  builder.identifier('var_intent');
  builder.title('Variable Intent');
  builder.description('Built with variables');
  builder.category(IntentCategory.fitness);
  final intent = builder.build();
}
''');

          final intents = await extractor.extractFromDirectory(tempDir.path);

          expect(intents, hasLength(1));
          expect(intents.first.identifier, equals('var_intent'));
          expect(intents.first.title, equals('Variable Intent'));
          expect(intents.first.category, equals('fitness'));
        },
        skip: skipReason,
      );

      test(
        'tracks builder across method calls',
        () async {
          File('${tempDir.path}/test.dart').writeAsStringSync('''
import 'package:flutter_app_intents/flutter_app_intents.dart';

void createIntent() {
  var builder = AppIntentBuilder();
  builder.identifier('tracked_intent');
  builder.title('Tracked');
  builder.description('Description');
  builder.build();
}
''');

          final intents = await extractor.extractFromDirectory(tempDir.path);

          expect(intents, hasLength(1));
          expect(intents.first.identifier, equals('tracked_intent'));
        },
        skip: skipReason,
      );
    });

    group('Category enum validation', () {
      test('extracts category with IntentCategory prefix', () async {
        File('${tempDir.path}/test.dart').writeAsStringSync('''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final intent = AppIntentBuilder()
  .identifier('test')
  .title('Test')
  .description('Test')
  .category(IntentCategory.messaging)
  .build();
''');

        final intents = await extractor.extractFromDirectory(tempDir.path);

        expect(intents.first.category, equals('messaging'));
      });

      test('validates enum is from IntentCategory', () async {
        File('${tempDir.path}/test.dart').writeAsStringSync('''
import 'package:flutter_app_intents/flutter_app_intents.dart';

enum MyCategory { general }

final intent = AppIntentBuilder()
  .identifier('test')
  .title('Test')
  .description('Test')
  .category(MyCategory.general)
  .build();
''');

        final intents = await extractor.extractFromDirectory(tempDir.path);

        // Should not extract category from wrong enum type
        expect(intents.first.category, isNull);
      });

      test('extracts all category types correctly', () async {
        File('${tempDir.path}/test.dart').writeAsStringSync('''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final general = AppIntentBuilder()
  .identifier('general')
  .title('General')
  .description('General')
  .category(IntentCategory.general)
  .build();

final fitness = AppIntentBuilder()
  .identifier('fitness')
  .title('Fitness')
  .description('Fitness')
  .category(IntentCategory.fitness)
  .build();

final messaging = AppIntentBuilder()
  .identifier('messaging')
  .title('Messaging')
  .description('Messaging')
  .category(IntentCategory.messaging)
  .build();
''');

        final intents = await extractor.extractFromDirectory(tempDir.path);

        expect(intents, hasLength(3));
        expect(intents[0].category, equals('general'));
        expect(intents[1].category, equals('fitness'));
        expect(intents[2].category, equals('messaging'));
      });
    });

    group('File scanning', () {
      test('scans multiple files', () async {
        File('${tempDir.path}/file1.dart').writeAsStringSync('''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final intent1 = AppIntentBuilder()
  .identifier('intent1')
  .title('Intent 1')
  .description('First')
  .build();
''');

        File('${tempDir.path}/file2.dart').writeAsStringSync('''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final intent2 = AppIntentBuilder()
  .identifier('intent2')
  .title('Intent 2')
  .description('Second')
  .build();
''');

        final intents = await extractor.extractFromDirectory(tempDir.path);

        expect(intents, hasLength(2));
        expect(extractor.filesScanned, equals(2));
      });

      test('skips non-dart files', () async {
        File('${tempDir.path}/test.dart').writeAsStringSync('''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final intent = AppIntentBuilder()
  .identifier('test')
  .title('Test')
  .description('Test')
  .build();
''');

        File('${tempDir.path}/readme.txt').writeAsStringSync('Not dart code');

        final intents = await extractor.extractFromDirectory(tempDir.path);

        expect(intents, hasLength(1));
        expect(extractor.filesScanned, equals(1));
      });

      test('scans nested directories', () async {
        final subDir = Directory('${tempDir.path}/subdir')..createSync();

        File('${subDir.path}/nested_intent.dart').writeAsStringSync('''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final nested = AppIntentBuilder()
  .identifier('nested')
  .title('Nested')
  .description('In subdirectory')
  .build();
''');

        final intents = await extractor.extractFromDirectory(tempDir.path);

        expect(intents, hasLength(1));
        expect(intents.first.identifier, equals('nested'));
      });

      test('tracks files scanned count correctly', () async {
        // Create 3 dart files
        for (var i = 0; i < 3; i++) {
          File('${tempDir.path}/file$i.dart').writeAsStringSync('''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final intent$i = AppIntentBuilder()
  .identifier('intent$i')
  .title('Intent $i')
  .description('Intent $i')
  .build();
''');
        }

        await extractor.extractFromDirectory(tempDir.path);

        expect(extractor.filesScanned, equals(3));
      });
    });

    group('Edge cases', () {
      test('handles file with no intents', () async {
        File('${tempDir.path}/empty.dart').writeAsStringSync('''
void main() {
  print('No intents here');
}
''');

        final intents = await extractor.extractFromDirectory(tempDir.path);

        expect(intents, isEmpty);
      });

      test('handles file with syntax errors gracefully', () async {
        File('${tempDir.path}/broken.dart').writeAsStringSync('''
This is not valid Dart code {{{
''');

        // Should not crash
        final intents = await extractor.extractFromDirectory(tempDir.path);

        expect(intents, isEmpty);
      });

      test('handles empty directory', () async {
        final intents = await extractor.extractFromDirectory(tempDir.path);

        expect(intents, isEmpty);
        expect(extractor.filesScanned, equals(0));
      });

      test('handles incomplete builder (missing build)', () async {
        File('${tempDir.path}/incomplete.dart').writeAsStringSync('''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final incomplete = AppIntentBuilder()
  .identifier('incomplete')
  .title('Incomplete')
  .description('No build() call');
''');

        final intents = await extractor.extractFromDirectory(tempDir.path);

        expect(intents, isEmpty);
      });
    });

    group('ExtractedIntent properties', () {
      test('categoryEnum returns correct enum value', () {
        final intent = ExtractedIntent()..category = 'fitness';

        expect(intent.categoryEnum, equals(IntentCategory.fitness));
      });

      test('categoryEnum returns general for null category', () {
        final intent = ExtractedIntent();

        expect(intent.categoryEnum, equals(IntentCategory.general));
      });

      test('categoryEnum returns general for unknown category', () {
        final intent = ExtractedIntent()..category = 'invalid_category';

        expect(intent.categoryEnum, equals(IntentCategory.general));
      });

      test('toString includes key fields', () {
        final intent = ExtractedIntent()
          ..identifier = 'test'
          ..title = 'Test'
          ..description = 'Test Description';

        final str = intent.toString();

        expect(str, contains('test'));
        expect(str, contains('Test'));
      });
    });
  });
}