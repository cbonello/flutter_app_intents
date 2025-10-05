import 'dart:io';

import 'package:flutter_app_intents/src/generator/cli_runner.dart';
import 'package:flutter_app_intents/src/generator/intent_extractor.dart';
import 'package:flutter_app_intents/src/generator/intent_validator.dart';
import 'package:flutter_app_intents/src/generator/shortcuts_xml_generator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;

class MockIntentExtractor extends Mock implements IntentExtractor {}

class MockIntentValidator extends Mock implements IntentValidator {}

class MockShortcutsXmlGenerator extends Mock implements ShortcutsXmlGenerator {}

void main() {
  group(CliRunner, () {
    late CliRunner cliRunner;
    late Directory tempDir;
    late Directory originalCurrent;
    late MockIntentExtractor mockIntentExtractor;
    late MockShortcutsXmlGenerator mockShortcutsXmlGenerator;
    late MockIntentValidator mockIntentValidator;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('cli_runner_test');
      originalCurrent = Directory.current;
      Directory.current = tempDir;

      // Create a dummy pubspec.yaml so that the project root can be found.
      File(p.join(tempDir.path, 'pubspec.yaml')).createSync();

      mockIntentExtractor = MockIntentExtractor();
      mockShortcutsXmlGenerator = MockShortcutsXmlGenerator();
      mockIntentValidator = MockIntentValidator();

      when(() => mockIntentExtractor.extractFromDirectory(any())).thenAnswer(
        (_) async => [
          ExtractedIntent()
            ..identifier = 'testIntent'
            ..title = 'Test Intent'
            ..description = 'A test intent'
            ..category = 'general',
        ],
      );
      when(() => mockIntentExtractor.filesScanned).thenReturn(1);
      when(() => mockIntentExtractor.warnings).thenReturn([]);
      when(() => mockIntentValidator.validateAll(any())).thenReturn([]);
      when(() => mockShortcutsXmlGenerator.generate(any())).thenReturn(
        '<shortcuts/>',
      );
      when(() => mockShortcutsXmlGenerator.warnings).thenReturn([]);

      cliRunner = CliRunner.test(
        intentExtractor: mockIntentExtractor,
        shortcutsXmlGenerator: mockShortcutsXmlGenerator,
        intentValidatorFactory: (_) => mockIntentValidator,
      );
    });

    tearDown(() {
      Directory.current = originalCurrent;
      tempDir.deleteSync(recursive: true);
    });

    group('run()', () {
      test('auto-detects android platform when platform is null', () async {
        await Directory('android').create();
        await cliRunner.run();
        final file = File('android/app/src/main/res/xml/shortcuts.xml');
        expect(file.existsSync(), isTrue);
        verify(() => mockShortcutsXmlGenerator.generate(any()));
      });

      test('auto-detects all platforms when platform is null', () async {
        await Directory('android').create();
        await Directory('ios').create();
        await cliRunner.run();

        // Android file should be generated
        final file = File('android/app/src/main/res/xml/shortcuts.xml');
        expect(file.existsSync(), isTrue);
        verify(() => mockShortcutsXmlGenerator.generate(any()));

        // iOS generation is not implemented, so we just check it doesn't throw
      });

      test('throws when no platforms are specified or detected', () {
        expect(
          () => cliRunner.run(),
          throwsA(isA<Exception>()),
        );
      });

      test('uses specified platform', () async {
        await Directory('ios').create();
        await cliRunner.run(platform: 'ios');
        // iOS generation is not implemented, so generate shouldn't be called.
        verifyNever(() => mockShortcutsXmlGenerator.generate(any()));
      });

      test('handles multiple platforms', () async {
        await Directory('android').create();
        await Directory('ios').create();
        await cliRunner.run(platform: 'android,ios');
        final file = File('android/app/src/main/res/xml/shortcuts.xml');
        expect(file.existsSync(), isTrue);
        verify(() => mockShortcutsXmlGenerator.generate(any()));
      });

      test('throws for invalid platform', () {
        expect(
          () => cliRunner.run(platform: 'windows'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('changes to project root before running', () async {
        await Directory('android').create();
        final subdir = await Directory('subdir').create();
        Directory.current = subdir;

        await cliRunner.run();

        // Check that the file was created relative to the project root,
        // not the subdirectory.
        final file = File(
          p.join(tempDir.path, 'android/app/src/main/res/xml/shortcuts.xml'),
        );
        expect(file.existsSync(), isTrue);
      });
    });

    group('watch mode', () {
      test('generates files in watch mode on initial run', () async {
        await Directory('android').create();
        await Directory('lib').create(); // Required for watch mode

        // We don't await this because it runs forever.
        // We can't easily test the file watching part in a unit test.
        // ignore: unawaited_futures
        cliRunner.run(watch: true).timeout(const Duration(seconds: 2));
        await Future<void>.delayed(const Duration(milliseconds: 100));

        final file = File('android/app/src/main/res/xml/shortcuts.xml');
        expect(file.existsSync(), isTrue);
        verify(() => mockShortcutsXmlGenerator.generate(any()));
      });

      test('returns early in watch mode if lib directory is missing', () async {
        await Directory('android').create();

        // Run in watch mode without a 'lib' directory
        await cliRunner.run(watch: true);

        // Should not attempt to generate files if lib is missing
        verifyNever(() => mockIntentExtractor.extractFromDirectory(any()));
      });
    });

    group('validation', () {
      test('throws when android directory is missing', () {
        expect(
          () => cliRunner.run(platform: 'android'),
          throwsA(isA<Exception>()),
        );
      });

      test('throws when ios directory is missing', () {
        expect(
          () => cliRunner.run(platform: 'ios'),
          throwsA(isA<Exception>()),
        );
      });

      test('throws on validation errors', () async {
        when(() => mockIntentValidator.validateAll(any())).thenReturn(
          [
            ValidationError(
              intent: 'TestIntent',
              message: 'Something is wrong',
            ),
          ],
        );

        await Directory('android').create();

        expect(
          () => cliRunner.run(platform: 'android'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('generation', () {
      test('generates android shortcuts.xml successfully', () async {
        await Directory('android').create();
        await cliRunner.run(platform: 'android');

        final file = File('android/app/src/main/res/xml/shortcuts.xml');
        expect(file.existsSync(), isTrue);
        expect(await file.readAsString(), equals('<shortcuts/>'));
        verify(() => mockShortcutsXmlGenerator.generate(any()));
      });

      test('handles no intents found', () async {
        when(
          () => mockIntentExtractor.extractFromDirectory(any()),
        ).thenAnswer((_) async => []);

        await Directory('android').create();
        await cliRunner.run(platform: 'android');

        final file = File('android/app/src/main/res/xml/shortcuts.xml');
        expect(file.existsSync(), isFalse);
        verifyNever(() => mockShortcutsXmlGenerator.generate(any()));
      });
    });
  });
}
