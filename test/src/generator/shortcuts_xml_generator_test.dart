import 'dart:io';

import 'package:flutter_app_intents/src/generator/intent_extractor.dart';
import 'package:flutter_app_intents/src/generator/shortcuts_xml_generator.dart';
import 'package:flutter_test/flutter_test.dart';

/// This file contains unit tests for the [ShortcutsXmlGenerator] class.
///
/// These tests cover various aspects of `shortcuts.xml` generation, including
/// handling single and multiple intents, correct Built-in Intent (BII) mapping,
/// main activity detection logic, and the overall structure of the generated
/// XML.
void main() {
  /// A group of tests for the [ShortcutsXmlGenerator].
  group('ShortcutsXmlGenerator', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('xml_generator_test');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    /// Tests that the generator produces a valid XML structure for a single
    /// intent,
    /// including the correct capability and deep link.
    test('generates valid shortcuts.xml for single intent', () {
      final generator = ShortcutsXmlGenerator();
      final intents = [
        ExtractedIntent()
          ..identifier = 'test_intent'
          ..title = 'Test Intent'
          ..description = 'A test intent'
          ..category = 'general',
      ];

      final xml = generator.generate(intents);

      expect(xml, contains('<?xml version="1.0" encoding="utf-8"?>'));
      expect(xml, contains('<shortcuts'));
      expect(xml, contains('<capability'));
      expect(xml, contains('android:name="actions.intent.OPEN_APP_FEATURE"'));
      expect(xml, contains('app://intent/test_intent'));
    });

    /// Tests that the generator can handle a list of multiple intents and
    /// includes all of them in the final XML output.
    test('generates shortcuts.xml for multiple intents', () {
      final generator = ShortcutsXmlGenerator();
      final intents = [
        ExtractedIntent()
          ..identifier = 'intent_one'
          ..title = 'First Intent'
          ..description = 'First test intent'
          ..category = 'general',
        ExtractedIntent()
          ..identifier = 'intent_two'
          ..title = 'Second Intent'
          ..description = 'Second test intent'
          ..category = 'fitness',
      ];

      final xml = generator.generate(intents);

      expect(xml, contains('app://intent/intent_one'));
      expect(xml, contains('app://intent/intent_two'));
      expect(xml, contains('actions.intent.OPEN_APP_FEATURE'));
      expect(xml, contains('actions.intent.START_EXERCISE'));
    });

    /// Verifies that the generator maps the [IntentCategory] to the correct
    /// Android Built-in Intent (BII) action name in the capability tag.
    test('uses correct BII for each category', () {
      final generator = ShortcutsXmlGenerator();
      final intents = [
        ExtractedIntent()
          ..identifier = 'fitness_intent'
          ..title = 'Fitness'
          ..description = 'Fitness intent'
          ..category = 'fitness',
        ExtractedIntent()
          ..identifier = 'messaging_intent'
          ..title = 'Messaging'
          ..description = 'Messaging intent'
          ..category = 'messaging',
      ];

      final xml = generator.generate(intents);

      expect(xml, contains('actions.intent.START_EXERCISE'));
      expect(xml, contains('actions.intent.SEND_MESSAGE'));
    });

    /// Tests the logic for determining the main activity class name, which is a
    /// critical part of the `<intent>` tag generation.
    group('MainActivity detection', () {
      /// Ensures that if a `mainActivityOverride` is provided, it is used as
      /// the `android:targetClass`, bypassing auto-detection.
      test('uses override when mainActivityOverride is set', () {
        final generator = ShortcutsXmlGenerator()
          ..mainActivityOverride = 'SplashActivity';

        final intents = [
          ExtractedIntent()
            ..identifier = 'test'
            ..title = 'Test'
            ..description = 'Test'
            ..category = 'general',
        ];

        final xml = generator.generate(intents);

        expect(xml, contains('android:targetClass="SplashActivity"'));
        expect(generator.warnings, isEmpty);
      });

      /// Tests the primary auto-detection path where the generator finds the
      /// main activity from a standard `AndroidManifest.xml` file.
      test('auto-detects MainActivity from AndroidManifest.xml', () {
        // Create a mock AndroidManifest.xml
        final androidDir = Directory('${tempDir.path}/android/app/src/main')
          ..createSync(recursive: true);

        final manifestFile = File('${androidDir.path}/AndroidManifest.xml')
          ..writeAsStringSync(
            '''
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application>
        <activity android:name=".MainActivity">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
''',
          );

        final generator = ShortcutsXmlGenerator(projectRoot: tempDir.path);
        final intents = [
          ExtractedIntent()
            ..identifier = 'test'
            ..title = 'Test'
            ..description = 'Test'
            ..category = 'general',
        ];

        final xml = generator.generate(intents);

        expect(xml, contains('android:targetClass="MainActivity"'));
        expect(generator.warnings, isEmpty);
      });

      /// Verifies that the generator can detect a custom-named main activity
      /// (e.g., `.SplashActivity`) from the manifest.
      test('detects custom activity name from AndroidManifest.xml', () {
        // Create a mock AndroidManifest.xml with custom activity
        final androidDir = Directory('${tempDir.path}/android/app/src/main')
          ..createSync(recursive: true);

        final manifestFile = File('${androidDir.path}/AndroidManifest.xml')
          ..writeAsStringSync(
            '''
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application>
        <activity android:name=".SplashActivity">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
''',
          );

        final generator = ShortcutsXmlGenerator(projectRoot: tempDir.path);
        final intents = [
          ExtractedIntent()
            ..identifier = 'test'
            ..title = 'Test'
            ..description = 'Test'
            ..category = 'general',
        ];

        final xml = generator.generate(intents);

        expect(xml, contains('android:targetClass="SplashActivity"'));
        expect(generator.warnings, isEmpty);
      });

      /// Checks if the generator correctly extracts the class name from a
      /// fully qualified activity name in the manifest.
      test('handles fully qualified activity names', () {
        final androidDir = Directory('${tempDir.path}/android/app/src/main')
          ..createSync(recursive: true);

        final manifestFile = File('${androidDir.path}/AndroidManifest.xml')
          ..writeAsStringSync(
            '''
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application>
        <activity android:name="com.example.myapp.LauncherActivity">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
''',
          );

        final generator = ShortcutsXmlGenerator(projectRoot: tempDir.path);
        final intents = [
          ExtractedIntent()
            ..identifier = 'test'
            ..title = 'Test'
            ..description = 'Test'
            ..category = 'general',
        ];

        final xml = generator.generate(intents);

        expect(xml, contains('android:targetClass="LauncherActivity"'));
        expect(generator.warnings, isEmpty);
      });

      /// Tests the fallback mechanism: if no manifest is found, the generator
      /// should default to 'MainActivity' and produce a warning.
      test('falls back to MainActivity with warning when detection fails', () {
        final generator = ShortcutsXmlGenerator(projectRoot: tempDir.path);
        final intents = [
          ExtractedIntent()
            ..identifier = 'test'
            ..title = 'Test'
            ..description = 'Test'
            ..category = 'general',
        ];

        final xml = generator.generate(intents);

        expect(xml, contains('android:targetClass="MainActivity"'));
        expect(generator.warnings, hasLength(1));
        expect(
          generator.warnings.first,
          contains('Could not auto-detect main activity'),
        );
        expect(
          generator.warnings.first,
          contains('--main-activity=YourActivity'),
        );
      });

      /// Confirms that the `mainActivityOverride` has the highest precedence,
      /// even when a valid `AndroidManifest.xml` is present.
      test('override takes precedence over auto-detection', () {
        // Create AndroidManifest with MainActivity
        final androidDir = Directory('${tempDir.path}/android/app/src/main')
          ..createSync(recursive: true);

        final manifestFile = File('${androidDir.path}/AndroidManifest.xml')
          ..writeAsStringSync(
            '''
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application>
        <activity android:name=".MainActivity">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
''',
          );

        final generator = ShortcutsXmlGenerator(projectRoot: tempDir.path)
          ..mainActivityOverride = 'CustomActivity';

        final intents = [
          ExtractedIntent()
            ..identifier = 'test'
            ..title = 'Test'
            ..description = 'Test'
            ..category = 'general',
        ];

        final xml = generator.generate(intents);

        // Override should win
        expect(xml, contains('android:targetClass="CustomActivity"'));
        expect(generator.warnings, isEmpty);
      });
    });

    /// Tests the behavior of the warning collection system in the generator.
    group('Warning system', () {
      /// Ensures that the `warnings` list is cleared before each new
      /// generation, preventing warnings from accumulating across multiple
      /// calls.
      test('clears warnings on each generation', () {
        final intents = [
          ExtractedIntent()
            ..identifier = 'test'
            ..title = 'Test'
            ..description = 'Test'
            ..category = 'general',
        ];

        // First generation - should create warning
        final generator1 = ShortcutsXmlGenerator(projectRoot: tempDir.path)
          ..generate(intents);
        expect(generator1.warnings, hasLength(1));

        // Second generation with new instance - warnings should be fresh
        final generator2 = ShortcutsXmlGenerator(projectRoot: tempDir.path)
          ..generate(intents);
        expect(
          generator2.warnings,
          hasLength(1),
        ); // Only one warning, not accumulated
      });
    });

    /// Contains tests that validate the general structure and correctness of
    /// the generated XML output.
    group('XML structure', () {
      /// Checks for fundamental XML correctness, like the XML declaration, root
      /// element, and namespace.
      test('generates properly formatted XML', () {
        final generator = ShortcutsXmlGenerator();
        final intents = [
          ExtractedIntent()
            ..identifier = 'test_intent'
            ..title = 'Test'
            ..description = 'Test'
            ..category = 'general',
        ];

        final xml = generator.generate(intents);

        // Should be valid XML with proper formatting
        expect(xml, startsWith('<?xml'));
        expect(xml, contains('xmlns:android='));
        expect(xml, contains('</shortcuts>'));
      });

      /// Verifies that the generated `<intent>` tag includes all mandatory
      /// attributes for App Actions to work correctly.
      test('includes all required intent attributes', () {
        final generator = ShortcutsXmlGenerator();
        final intents = [
          ExtractedIntent()
            ..identifier = 'test'
            ..title = 'Test'
            ..description = 'Test'
            ..category = 'general',
        ];

        final xml = generator.generate(intents);

        expect(xml, contains('android:targetPackage'));
        expect(xml, contains('android:targetClass'));
        expect(xml, contains('android:action="android.intent.action.VIEW"'));
        expect(xml, contains('android:data='));
      });
    });
  });
}
