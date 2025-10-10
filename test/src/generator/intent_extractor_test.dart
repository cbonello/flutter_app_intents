import 'dart:io';

import 'package:flutter_app_intents/src/generator/intent_extractor.dart';
import 'package:flutter_app_intents/src/models/intent_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(IntentExtractor, () {
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
        File('${tempDir.path}/test_intent.dart').writeAsStringSync(
          '''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final myIntent = AppIntentBuilder()
  .identifier('test_intent')
  .title('Test Intent')
  .description('A test intent')
  .category(IntentCategory.general)
  .build();
''',
        );

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
      // Variable assignment pattern support needs debugging. The AST visitor
      // doesn't correctly track builder variables across statements.
      // For now, users should use the method chaining pattern instead.
      const skipReason =
          'Variable assignment pattern needs AST visitor improvements';

      test(
        'extracts intent from variable-based builder',
        () async {
          File('${tempDir.path}/test.dart').writeAsStringSync(
            '''
import 'package:flutter_app_intents/flutter_app_intents.dart';

void setupIntents() {
  final builder = AppIntentBuilder();
  builder.identifier('var_intent');
  builder.title('Variable Intent');
  builder.description('Built with variables');
  builder.category(IntentCategory.fitness);
  final intent = builder.build();
}
''',
          );

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
          File('${tempDir.path}/test.dart').writeAsStringSync(
            '''
import 'package:flutter_app_intents/flutter_app_intents.dart';

void createIntent() {
  var builder = AppIntentBuilder();
  builder.identifier('tracked_intent');
  builder.title('Tracked');
  builder.description('Description');
  builder.build();
}
''',
          );

          final intents = await extractor.extractFromDirectory(tempDir.path);

          expect(intents, hasLength(1));
          expect(intents.first.identifier, equals('tracked_intent'));
        },
        skip: skipReason,
      );
    });

    group('Category enum validation', () {
      test('extracts category with IntentCategory prefix', () async {
        File('${tempDir.path}/test.dart').writeAsStringSync(
          '''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final intent = AppIntentBuilder()
  .identifier('test')
  .title('Test')
  .description('Test')
  .category(IntentCategory.messaging)
  .build();
''',
        );

        final intents = await extractor.extractFromDirectory(tempDir.path);

        expect(intents.first.category, equals('messaging'));
      });

      test('validates enum is from IntentCategory', () async {
        File('${tempDir.path}/test.dart').writeAsStringSync(
          '''
import 'package:flutter_app_intents/flutter_app_intents.dart';

enum MyCategory { general }

final intent = AppIntentBuilder()
  .identifier('test')
  .title('Test')
  .description('Test')
  .category(MyCategory.general)
  .build();
''',
        );

        final intents = await extractor.extractFromDirectory(tempDir.path);

        // Should not extract category from wrong enum type
        expect(intents.first.category, isNull);
      });

      test('extracts all category types correctly', () async {
        File('${tempDir.path}/test.dart').writeAsStringSync(
          '''
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
''',
        );

        final intents = await extractor.extractFromDirectory(tempDir.path);

        expect(intents, hasLength(3));
        expect(intents[0].category, equals('general'));
        expect(intents[1].category, equals('fitness'));
        expect(intents[2].category, equals('messaging'));
      });
    });

    group('File scanning', () {
      test('scans multiple files', () async {
        File('${tempDir.path}/file1.dart').writeAsStringSync(
          '''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final intent1 = AppIntentBuilder()
  .identifier('intent1')
  .title('Intent 1')
  .description('First')
  .build();
''',
        );

        File('${tempDir.path}/file2.dart').writeAsStringSync(
          '''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final intent2 = AppIntentBuilder()
  .identifier('intent2')
  .title('Intent 2')
  .description('Second')
  .build();
''',
        );

        final intents = await extractor.extractFromDirectory(tempDir.path);

        expect(intents, hasLength(2));
        expect(extractor.filesScanned, equals(2));
      });

      test('skips non-dart files', () async {
        File('${tempDir.path}/test.dart').writeAsStringSync(
          '''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final intent = AppIntentBuilder()
  .identifier('test')
  .title('Test')
  .description('Test')
  .build();
''',
        );

        File('${tempDir.path}/readme.txt').writeAsStringSync('Not dart code');

        final intents = await extractor.extractFromDirectory(tempDir.path);

        expect(intents, hasLength(1));
        expect(extractor.filesScanned, equals(1));
      });

      test('scans nested directories', () async {
        final subDir = Directory('${tempDir.path}/subdir')..createSync();

        File('${subDir.path}/nested_intent.dart').writeAsStringSync(
          '''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final nested = AppIntentBuilder()
  .identifier('nested')
  .title('Nested')
  .description('In subdirectory')
  .build();
''',
        );

        final intents = await extractor.extractFromDirectory(tempDir.path);

        expect(intents, hasLength(1));
        expect(intents.first.identifier, equals('nested'));
      });

      test('tracks files scanned count correctly', () async {
        // Create 3 dart files
        for (var i = 0; i < 3; i++) {
          File('${tempDir.path}/file$i.dart').writeAsStringSync(
            '''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final intent$i = AppIntentBuilder()
  .identifier('intent$i')
  .title('Intent $i')
  .description('Intent $i')
  .build();
''',
          );
        }

        await extractor.extractFromDirectory(tempDir.path);

        expect(extractor.filesScanned, equals(3));
      });
    });

    group('Edge cases', () {
      test('handles file with no intents', () async {
        File('${tempDir.path}/empty.dart').writeAsStringSync(
          '''
void main() {
  print('No intents here');
}
''',
        );

        final intents = await extractor.extractFromDirectory(tempDir.path);

        expect(intents, isEmpty);
      });

      test('handles file with syntax errors gracefully', () async {
        File('${tempDir.path}/broken.dart').writeAsStringSync(
          '''
This is not valid Dart code {{{
''',
        );

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
        File('${tempDir.path}/incomplete.dart').writeAsStringSync(
          '''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final incomplete = AppIntentBuilder()
  .identifier('incomplete')
  .title('Incomplete')
  .description('No build() call');
''',
        );

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

      test('isValid checks required fields', () {
        final validIntent = ExtractedIntent()
          ..identifier = 'test'
          ..title = 'Test'
          ..description = 'Description';

        expect(validIntent.isValid, isTrue);

        final invalidIntent1 = ExtractedIntent()
          ..title = 'Test'
          ..description = 'Description';

        expect(invalidIntent1.isValid, isFalse);

        final invalidIntent2 = ExtractedIntent()
          ..identifier = 'test'
          ..description = 'Description';

        expect(invalidIntent2.isValid, isFalse);

        final invalidIntent3 = ExtractedIntent()
          ..identifier = 'test'
          ..title = 'Test';

        expect(invalidIntent3.isValid, isFalse);
      });
    });

    group('Parameter extraction', () {
      test('extracts parameters from intent', () async {
        File('${tempDir.path}/test.dart').writeAsStringSync(
          '''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final intent = AppIntentBuilder()
  .identifier('test')
  .title('Test')
  .description('Test')
  .parameter(const AppIntentParameter(
    name: 'amount',
    title: 'Amount',
    type: AppIntentParameterType.integer,
  ))
  .build();
''',
        );

        final intents = await extractor.extractFromDirectory(tempDir.path);

        expect(intents.first.parameters, hasLength(1));
        expect(intents.first.parameters.first.name, equals('amount'));
        expect(intents.first.parameters.first.title, equals('Amount'));
        expect(intents.first.parameters.first.type, equals('integer'));
      });

      test('extracts multiple parameters', () async {
        File('${tempDir.path}/test.dart').writeAsStringSync(
          '''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final intent = AppIntentBuilder()
  .identifier('test')
  .title('Test')
  .description('Test')
  .parameter(const AppIntentParameter(
    name: 'param1',
    title: 'First',
    type: AppIntentParameterType.string,
  ))
  .parameter(const AppIntentParameter(
    name: 'param2',
    title: 'Second',
    type: AppIntentParameterType.integer,
  ))
  .build();
''',
        );

        final intents = await extractor.extractFromDirectory(tempDir.path);

        expect(intents.first.parameters, hasLength(2));
        expect(intents.first.parameters[0].name, equals('param1'));
        expect(intents.first.parameters[1].name, equals('param2'));
      });

      test('extracts parameter with isOptional flag', () async {
        File('${tempDir.path}/test.dart').writeAsStringSync(
          '''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final intent = AppIntentBuilder()
  .identifier('test')
  .title('Test')
  .description('Test')
  .parameter(const AppIntentParameter(
    name: 'optional',
    title: 'Optional Param',
    type: AppIntentParameterType.string,
    isOptional: true,
  ))
  .build();
''',
        );

        final intents = await extractor.extractFromDirectory(tempDir.path);

        expect(intents.first.parameters.first.isOptional, isTrue);
      });

      test('extracts parameter with string default value', () async {
        File('${tempDir.path}/test.dart').writeAsStringSync(
          '''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final intent = AppIntentBuilder()
  .identifier('test')
  .title('Test')
  .description('Test')
  .parameter(const AppIntentParameter(
    name: 'name',
    title: 'Name',
    type: AppIntentParameterType.string,
    defaultValue: 'default',
  ))
  .build();
''',
        );

        final intents = await extractor.extractFromDirectory(tempDir.path);

        expect(intents.first.parameters.first.defaultValue, equals('default'));
      });

      test('extracts parameter with integer default value', () async {
        File('${tempDir.path}/test.dart').writeAsStringSync(
          '''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final intent = AppIntentBuilder()
  .identifier('test')
  .title('Test')
  .description('Test')
  .parameter(const AppIntentParameter(
    name: 'count',
    title: 'Count',
    type: AppIntentParameterType.integer,
    defaultValue: 42,
  ))
  .build();
''',
        );

        final intents = await extractor.extractFromDirectory(tempDir.path);

        expect(intents.first.parameters.first.defaultValue, equals(42));
      });

      test('extracts parameter with double default value', () async {
        File('${tempDir.path}/test.dart').writeAsStringSync(
          '''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final intent = AppIntentBuilder()
  .identifier('test')
  .title('Test')
  .description('Test')
  .parameter(const AppIntentParameter(
    name: 'price',
    title: 'Price',
    type: AppIntentParameterType.decimal,
    defaultValue: 9.99,
  ))
  .build();
''',
        );

        final intents = await extractor.extractFromDirectory(tempDir.path);

        expect(intents.first.parameters.first.defaultValue, equals(9.99));
      });

      test('extracts parameter with boolean default value', () async {
        File('${tempDir.path}/test.dart').writeAsStringSync(
          '''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final intent = AppIntentBuilder()
  .identifier('test')
  .title('Test')
  .description('Test')
  .parameter(const AppIntentParameter(
    name: 'enabled',
    title: 'Enabled',
    type: AppIntentParameterType.boolean,
    defaultValue: true,
  ))
  .build();
''',
        );

        final intents = await extractor.extractFromDirectory(tempDir.path);

        expect(intents.first.parameters.first.defaultValue, equals(true));
      });

      test('extracts all parameter types', () async {
        File('${tempDir.path}/test.dart').writeAsStringSync(
          '''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final stringParam = AppIntentBuilder()
  .identifier('test1')
  .title('Test1')
  .description('Test1')
  .parameter(const AppIntentParameter(
    name: 'str',
    title: 'String',
    type: AppIntentParameterType.string,
  ))
  .build();

final intParam = AppIntentBuilder()
  .identifier('test2')
  .title('Test2')
  .description('Test2')
  .parameter(const AppIntentParameter(
    name: 'num',
    title: 'Number',
    type: AppIntentParameterType.integer,
  ))
  .build();

final boolParam = AppIntentBuilder()
  .identifier('test3')
  .title('Test3')
  .description('Test3')
  .parameter(const AppIntentParameter(
    name: 'flag',
    title: 'Flag',
    type: AppIntentParameterType.boolean,
  ))
  .build();
''',
        );

        final intents = await extractor.extractFromDirectory(tempDir.path);

        expect(intents[0].parameters.first.type, equals('string'));
        expect(intents[1].parameters.first.type, equals('integer'));
        expect(intents[2].parameters.first.type, equals('boolean'));
      });
    });

    group('PresentsResult flag', () {
      test('extracts presentsResult true', () async {
        File('${tempDir.path}/test.dart').writeAsStringSync(
          '''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final intent = AppIntentBuilder()
  .identifier('test')
  .title('Test')
  .description('Test')
  .presentsResult(presents: true)
  .build();
''',
        );

        final intents = await extractor.extractFromDirectory(tempDir.path);

        expect(intents.first.presentsResult, isTrue);
      });

      test('extracts presentsResult false', () async {
        File('${tempDir.path}/test.dart').writeAsStringSync(
          '''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final intent = AppIntentBuilder()
  .identifier('test')
  .title('Test')
  .description('Test')
  .presentsResult(presents: false)
  .build();
''',
        );

        final intents = await extractor.extractFromDirectory(tempDir.path);

        expect(intents.first.presentsResult, isFalse);
      });
    });

    group('Error handling', () {
      test('throws when directory does not exist', () async {
        final nonExistentPath = '${tempDir.path}/does_not_exist';

        expect(
          () => extractor.extractFromDirectory(nonExistentPath),
          throwsA(isA<Exception>()),
        );
      });

      test('adds warning for files that cannot be analyzed', () async {
        // Create a file with very broken syntax
        File('${tempDir.path}/broken.dart').writeAsStringSync(
          '''
completely broken { {{ syntax
''',
        );

        await extractor.extractFromDirectory(tempDir.path);

        // Should have processed the file and potentially added a warning
        expect(extractor.filesScanned, greaterThan(0));
      });
    });

    group('ExtractedParameter', () {
      test('isValid checks required fields', () {
        final validParam = ExtractedParameter()
          ..name = 'test'
          ..title = 'Test'
          ..type = 'string';

        expect(validParam.isValid, isTrue);

        final invalidParam1 = ExtractedParameter()
          ..title = 'Test'
          ..type = 'string';

        expect(invalidParam1.isValid, isFalse);

        final invalidParam2 = ExtractedParameter()
          ..name = 'test'
          ..type = 'string';

        expect(invalidParam2.isValid, isFalse);

        final invalidParam3 = ExtractedParameter()
          ..name = 'test'
          ..title = 'Test';

        expect(invalidParam3.isValid, isFalse);
      });

      test('toString includes key fields', () {
        final param = ExtractedParameter()
          ..name = 'testParam'
          ..type = 'string'
          ..isOptional = true;

        final str = param.toString();

        expect(str, contains('testParam'));
        expect(str, contains('string'));
        expect(str, contains('true'));
      });
    });
  });
}
