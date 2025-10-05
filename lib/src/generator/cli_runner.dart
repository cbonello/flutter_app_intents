import 'dart:io';

import 'package:flutter_app_intents/src/generator/intent_extractor.dart';
import 'package:flutter_app_intents/src/generator/intent_validator.dart';
import 'package:flutter_app_intents/src/generator/shortcuts_xml_generator.dart';
import 'package:meta/meta.dart';
import 'package:watcher/watcher.dart';

/// Main CLI runner for code generation
class CliRunner {
  /// Creates a new [CliRunner] with default dependencies.
  CliRunner()
      : _intentExtractor = IntentExtractor(),
        _shortcutsXmlGenerator = ShortcutsXmlGenerator(
          projectRoot: _findProjectRoot(),
        ),
        _intentValidatorFactory =
            ((platform) => IntentValidator(targetPlatform: platform));

  /// Creates a new [CliRunner] with mockable dependencies for testing.
  @visibleForTesting
  CliRunner.test({
    required IntentExtractor intentExtractor,
    required ShortcutsXmlGenerator shortcutsXmlGenerator,
    required IntentValidator Function(String) intentValidatorFactory,
  })  : _intentExtractor = intentExtractor,
        _shortcutsXmlGenerator = shortcutsXmlGenerator,
        _intentValidatorFactory = intentValidatorFactory;

  final IntentExtractor _intentExtractor;
  final ShortcutsXmlGenerator _shortcutsXmlGenerator;
  final IntentValidator Function(String) _intentValidatorFactory;

  /// Run the code generator
  Future<void> run({
    String? platform,
    String? mainActivity,
    bool watch = false,
  }) async {
    final currentDir = Directory.current;

    // Determine target platforms
    final platforms = _determinePlatforms(platform);

    stdout
      ..writeln('🔍 flutter_app_intents code generator')
      ..writeln('📂 Project: ${currentDir.path}')
      ..writeln('🎯 Platforms: ${platforms.join(", ")}')
      ..writeln();

    if (watch) {
      await _watchMode(platforms, mainActivity: mainActivity);
    } else {
      await _generateOnce(platforms, mainActivity: mainActivity);
    }
  }

  /// Find the project root by searching upward for pubspec.yaml
  static String _findProjectRoot() {
    var current = Directory.current;

    // Search upward for pubspec.yaml (max 10 levels)
    for (var i = 0; i < 10; i++) {
      final pubspecPath = '${current.path}/pubspec.yaml';
      if (File(pubspecPath).existsSync()) {
        return current.path;
      }

      final parent = current.parent;
      if (parent.path == current.path) {
        // Reached filesystem root
        break;
      }
      current = parent;
    }

    // Fallback to current directory if pubspec.yaml not found
    return Directory.current.path;
  }

  /// Determine which platforms to generate code for
  List<String> _determinePlatforms(String? platformArg) {
    if (platformArg != null) {
      // Explicit platform(s) specified
      final platforms = platformArg
          .split(',')
          .map(
            (p) => p.trim().toLowerCase(),
          )
          .toList();

      // Validate platform names
      for (final platform in platforms) {
        if (platform != 'ios' && platform != 'android') {
          throw ArgumentError(
            'Invalid platform: $platform. Must be "ios" or "android".',
          );
        }
      }

      return platforms;
    }

    // Auto-detect platforms based on project structure
    final available = <String>[];
    if (Directory('android').existsSync()) {
      available.add('android');
    }
    if (Directory('ios').existsSync()) {
      available.add('ios');
    }

    if (available.isEmpty) {
      throw Exception(
        'No platforms specified and no "android" or "ios" directories found.\n'
        'Please run from your Flutter project root or specify platforms '
        'with --platform.',
      );
    }

    stdout
      ..writeln(
        'ℹ️  No --platform specified, auto-detecting: ${available.join(', ')}',
      )
      ..writeln();

    return available;
  }

  /// Generate code once
  Future<void> _generateOnce(
    List<String> platforms, {
    String? mainActivity,
  }) async {
    await _validatePlatforms(platforms);
    await _generateForPlatforms(platforms, mainActivity: mainActivity);

    stdout
      ..writeln()
      ..writeln('✅ Code generation complete!')
      ..writeln();
    _printNextSteps(platforms);
  }

  /// Watch mode: regenerate on file changes
  Future<void> _watchMode(
    List<String> platforms, {
    String? mainActivity,
  }) async {
    await _validatePlatforms(platforms);

    stdout
      ..writeln('👀 Watching lib/ for changes... (Press Ctrl+C to stop)')
      ..writeln();

    // Initial generation
    await _generateForPlatforms(platforms, mainActivity: mainActivity);

    // Watch for changes
    final watcher = DirectoryWatcher('lib');

    try {
      await for (final event in watcher.events) {
        // Only watch Dart files
        if (!event.path.endsWith('.dart')) continue;

        // Debounce rapid changes
        await Future<void>.delayed(const Duration(milliseconds: 500));

        stdout
          ..writeln()
          ..writeln('🔄 File changed: ${event.path}')
          ..writeln('🔍 Re-scanning...')
          ..writeln();

        try {
          await _generateForPlatforms(platforms, mainActivity: mainActivity);
          stdout.writeln('✅ Regeneration complete');
        } on Exception catch (e) {
          stdout.writeln('❌ Error during regeneration: $e');
        }

        stdout
          ..writeln()
          ..writeln('👀 Watching...');
      }
    } on Object catch (e) {
      stdout
        ..writeln()
        ..writeln('❌ An unexpected error occurred with the file watcher: $e')
        ..writeln('   Watch mode has stopped.');
    }
  }

  /// Validate that specified platforms exist in the project
  Future<void> _validatePlatforms(List<String> platforms) async {
    final hasAndroid = Directory('android').existsSync();
    final hasIos = Directory('ios').existsSync();

    final missingPlatforms = <String>[];

    for (final platform in platforms) {
      if (platform == 'android' && !hasAndroid) {
        missingPlatforms.add('android');
      } else if (platform == 'ios' && !hasIos) {
        missingPlatforms.add('ios');
      }
    }

    if (missingPlatforms.isNotEmpty) {
      stdout
        ..writeln(
          '❌ Platform configuration not found: ${missingPlatforms.join(", ")}',
        )
        ..writeln();

      for (final platform in missingPlatforms) {
        stdout
          ..writeln('   Missing: $platform/ directory')
          ..writeln('   💡 Add $platform to your Flutter project:')
          ..writeln('      flutter create --platforms $platform .')
          ..writeln();
      }

      stdout.writeln('   Or generate for available platforms only:');
      final available = <String>[];
      if (hasAndroid && !missingPlatforms.contains('android')) {
        available.add('android');
      }
      if (hasIos && !missingPlatforms.contains('ios')) available.add('ios');

      if (available.isNotEmpty) {
        stdout.writeln(
          '      dart run flutter_app_intents:generate '
          '--platform=${available.join(",")}',
        );
      }

      throw Exception('Missing platform directories');
    }
  }

  /// Generate code for all platforms
  Future<void> _generateForPlatforms(
    List<String> platforms, {
    String? mainActivity,
  }) async {
    stdout.writeln('🔍 Scanning lib/ for intent definitions...');
    final intents = await _intentExtractor.extractFromDirectory('lib');

    if (_intentExtractor.warnings.isNotEmpty) {
      stdout
        ..writeln()
        ..writeln('⚠️  Warnings during intent extraction:');
      for (final warning in _intentExtractor.warnings) {
        stdout.writeln('   - $warning');
      }
      stdout.writeln();
    }

    if (intents.isEmpty) {
      stdout
        ..writeln('⚠️  No intents found in lib/')
        ..writeln(
          "   Make sure you're using AppIntentBuilder to define intents.",
        );
      return;
    }

    stdout.writeln(
      '✅ Found ${intents.length} intent(s) in '
      '${_intentExtractor.filesScanned} file(s)',
    );

    // Generate for each platform
    for (final platform in platforms) {
      stdout.writeln('📱 Processing platform: $platform');

      // Validate intents for this platform
      final validator = _intentValidatorFactory(platform);
      final errors = validator.validateAll(intents);

      if (errors.isNotEmpty) {
        stdout.writeln('❌ Validation errors:');
        for (final error in errors) {
          stdout.writeln('   ${error.intent}: ${error.message}');
          if (error.hint != null) {
            stdout.writeln('      💡 ${error.hint}');
          }
        }
        stdout.writeln();
        throw Exception('Validation failed for $platform');
      }

      // Generate platform-specific code
      if (platform == 'android') {
        await _generateAndroid(intents, mainActivity: mainActivity);
      } else if (platform == 'ios') {
        stdout
          ..writeln('⚠️  iOS code generation not yet implemented (v1.1.0+)')
          ..writeln(
            '   iOS uses dynamic App Intents - no code generation required.',
          );
      }

      stdout.writeln();
    }
  }

  /// Generate Android shortcuts.xml
  Future<void> _generateAndroid(
    List<ExtractedIntent> intents, {
    String? mainActivity,
  }) async {
    // Set the main activity override if provided
    _shortcutsXmlGenerator.mainActivityOverride = mainActivity;

    final xml = _shortcutsXmlGenerator.generate(intents);

    // Display any warnings from generation
    if (_shortcutsXmlGenerator.warnings.isNotEmpty) {
      stdout.writeln('⚠️  Warnings:');
      for (final warning in _shortcutsXmlGenerator.warnings) {
        stdout.writeln('   $warning');
      }
      stdout.writeln();
    }

    const outputPath = 'android/app/src/main/res/xml/shortcuts.xml';
    final outputFile = File(outputPath);

    // Create directory if it doesn't exist
    await outputFile.parent.create(recursive: true);

    // Write the file
    await outputFile.writeAsString(xml);

    stdout.writeln('📝 Generated: $outputPath');
  }

  /// Print next steps for the user
  void _printNextSteps(List<String> platforms) {
    if (platforms.contains('android')) {
      stdout
        ..writeln('📌 Next steps for Android:')
        ..writeln('   1. Run: flutter build apk')
        ..writeln('   2. Test with Google Assistant or adb commands')
        ..writeln('   3. Remember: Hot RESTART (R) required after XML changes')
        ..writeln();
    }

    if (platforms.contains('ios')) {
      stdout
        ..writeln('📌 Next steps for iOS:')
        ..writeln('   1. Define AppShortcutsProvider in Swift')
        ..writeln('   2. Run: flutter build ios')
        ..writeln('   3. Test with Siri')
        ..writeln();
    }
  }
}
