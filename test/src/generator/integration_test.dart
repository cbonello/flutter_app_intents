import 'dart:io';

import 'package:flutter_app_intents/src/generator/cli_runner.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

/// End-to-end integration tests for the complete code generation flow.
///
/// These tests use real implementations (not mocks) to verify the entire
/// pipeline from intent extraction through XML generation.
void main() {
  group('End-to-end integration', () {
    late Directory tempDir;
    late Directory originalCurrent;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('integration_test');
      originalCurrent = Directory.current;
      Directory.current = tempDir;

      // Create basic Flutter project structure
      File(p.join(tempDir.path, 'pubspec.yaml')).writeAsStringSync(
        '''
name: test_app
description: Test app
version: 1.0.0
environment:
  sdk: ^3.5.0
dependencies:
  flutter:
    sdk: flutter
  flutter_app_intents: any
''',
      );
    });

    tearDown(() {
      Directory.current = originalCurrent;
      tempDir.deleteSync(recursive: true);
    });

    test('generates valid shortcuts.xml from intent definitions', () async {
      // Create lib directory with intent definitions
      final libDir = Directory(p.join(tempDir.path, 'lib'))..createSync();
      File(p.join(libDir.path, 'intents.dart')).writeAsStringSync(
        '''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final workoutIntent = AppIntentBuilder()
  .identifier('start_workout')
  .title('Start Workout')
  .description('Begin a new workout session')
  .category(IntentCategory.fitness)
  .build();

final messageIntent = AppIntentBuilder()
  .identifier('send_message')
  .title('Send Message')
  .description('Send a quick message')
  .category(IntentCategory.messaging)
  .build();
''',
      );

      // Create Android structure with AndroidManifest.xml
      final androidDir = Directory(p.join(tempDir.path, 'android/app/src/main'))
        ..createSync(recursive: true);

      File(p.join(androidDir.path, 'AndroidManifest.xml')).writeAsStringSync(
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

      // Run the generator
      final runner = CliRunner();
      await runner.run(platform: 'android');

      // Verify shortcuts.xml was generated
      final shortcutsFile = File(
        p.join(tempDir.path, 'android/app/src/main/res/xml/shortcuts.xml'),
      );
      expect(shortcutsFile.existsSync(), isTrue);

      // Parse and validate the XML
      final xmlContent = await shortcutsFile.readAsString();
      final document = XmlDocument.parse(xmlContent);

      // Verify root element
      final shortcuts = document.rootElement;
      expect(shortcuts.name.local, equals('shortcuts'));
      expect(
        shortcuts.getAttribute('xmlns:android'),
        equals('http://schemas.android.com/apk/res/android'),
      );

      // Verify we have 2 capabilities (one per intent)
      final capabilityElements = shortcuts.findElements('capability').toList();
      expect(capabilityElements, hasLength(2));

      // Verify first capability (workout)
      final workoutCapability = capabilityElements.firstWhere(
        (e) =>
            e.getAttribute('android:name') == 'actions.intent.START_EXERCISE',
      );

      final workoutIntent = workoutCapability.findElements('intent').first;
      expect(
        workoutIntent.getAttribute('android:action'),
        equals('android.intent.action.VIEW'),
      );
      expect(
        workoutIntent.getAttribute('android:targetPackage'),
        equals(r'${applicationId}'),
      );
      expect(
        workoutIntent.getAttribute('android:targetClass'),
        equals('MainActivity'),
      );
      expect(
        workoutIntent.getAttribute('android:data'),
        equals('app://intent/start_workout'),
      );

      // Verify second capability (message)
      final messageCapability = capabilityElements.firstWhere(
        (e) => e.getAttribute('android:name') == 'actions.intent.SEND_MESSAGE',
      );

      final messageIntent = messageCapability.findElements('intent').first;
      expect(
        messageIntent.getAttribute('android:data'),
        equals('app://intent/send_message'),
      );
    });

    test('handles custom main activity name', () async {
      // Create lib directory with one intent
      final libDir = Directory(p.join(tempDir.path, 'lib'))..createSync();
      File(p.join(libDir.path, 'intents.dart')).writeAsStringSync(
        '''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final testIntent = AppIntentBuilder()
  .identifier('test')
  .title('Test')
  .description('Test intent')
  .category(IntentCategory.general)
  .build();
''',
      );

      // Create Android structure with custom activity
      final androidDir = Directory(p.join(tempDir.path, 'android/app/src/main'))
        ..createSync(recursive: true);

      File(p.join(androidDir.path, 'AndroidManifest.xml')).writeAsStringSync(
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

      // Run the generator
      final runner = CliRunner();
      await runner.run(platform: 'android');

      // Verify shortcuts.xml uses SplashActivity
      final shortcutsFile = File(
        p.join(tempDir.path, 'android/app/src/main/res/xml/shortcuts.xml'),
      );
      final xmlContent = await shortcutsFile.readAsString();
      expect(xmlContent, contains('android:targetClass="SplashActivity"'));
    });

    test('handles MainActivity override parameter', () async {
      // Create lib directory with one intent
      final libDir = Directory(p.join(tempDir.path, 'lib'))..createSync();
      File(p.join(libDir.path, 'intents.dart')).writeAsStringSync(
        '''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final testIntent = AppIntentBuilder()
  .identifier('test')
  .title('Test')
  .description('Test intent')
  .category(IntentCategory.general)
  .build();
''',
      );

      // Create Android structure (AndroidManifest not needed for override test)
      Directory(p.join(tempDir.path, 'android')).createSync();

      // Run the generator with custom activity override
      final runner = CliRunner();
      await runner.run(
        platform: 'android',
        mainActivity: 'CustomActivity',
      );

      // Verify shortcuts.xml uses CustomActivity
      final shortcutsFile = File(
        p.join(tempDir.path, 'android/app/src/main/res/xml/shortcuts.xml'),
      );
      final xmlContent = await shortcutsFile.readAsString();
      expect(xmlContent, contains('android:targetClass="CustomActivity"'));
    });

    test('skips generation when no intents are found', () async {
      // Create lib directory with no intent definitions
      Directory(p.join(tempDir.path, 'lib'))
        ..createSync()
        ..createSync();
      File(p.join(tempDir.path, 'lib/main.dart')).writeAsStringSync(
        '''
void main() {
  print('No intents here');
}
''',
      );

      // Create Android structure
      Directory(p.join(tempDir.path, 'android')).createSync();

      // Run the generator
      final runner = CliRunner();
      await runner.run(platform: 'android');

      // Verify shortcuts.xml was NOT generated
      final shortcutsFile = File(
        p.join(tempDir.path, 'android/app/src/main/res/xml/shortcuts.xml'),
      );
      expect(shortcutsFile.existsSync(), isFalse);
    });

    test('handles intents in nested directories', () async {
      // Create nested lib structure
      final libDir = Directory(p.join(tempDir.path, 'lib'))..createSync();
      final featuresDir = Directory(p.join(libDir.path, 'features/workout'))
        ..createSync(recursive: true);

      File(p.join(featuresDir.path, 'workout_intents.dart')).writeAsStringSync(
        '''
import 'package:flutter_app_intents/flutter_app_intents.dart';

final workoutIntent = AppIntentBuilder()
  .identifier('nested_workout')
  .title('Nested Workout')
  .description('Workout from nested directory')
  .category(IntentCategory.fitness)
  .build();
''',
      );

      // Create Android structure
      Directory(p.join(tempDir.path, 'android')).createSync();

      // Run the generator
      final runner = CliRunner();
      await runner.run(platform: 'android');

      // Verify shortcuts.xml includes the nested intent
      final shortcutsFile = File(
        p.join(tempDir.path, 'android/app/src/main/res/xml/shortcuts.xml'),
      );
      final xmlContent = await shortcutsFile.readAsString();
      expect(xmlContent, contains('nested_workout'));
      expect(xmlContent, contains('actions.intent.START_EXERCISE'));
    });
  });
}
