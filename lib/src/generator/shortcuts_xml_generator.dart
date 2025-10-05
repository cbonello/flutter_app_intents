import 'dart:io';

import 'package:flutter_app_intents/src/generator/intent_extractor.dart';
import 'package:flutter_app_intents/src/models/intent_category.dart';
import 'package:path/path.dart' as path;
import 'package:xml/xml.dart';

/// Generates Android shortcuts.xml file for App Actions
class ShortcutsXmlGenerator {
  ShortcutsXmlGenerator({this.projectRoot});

  /// Project root directory (for finding AndroidManifest.xml)
  final String? projectRoot;

  /// Override for main activity class name (set via CLI --main-activity)
  String? mainActivityOverride;

  /// Cached main activity class name
  String? _cachedMainActivity;

  /// Warnings generated during XML generation
  final List<String> warnings = [];

  /// Generate shortcuts.xml content from extracted intents
  String generate(List<ExtractedIntent> intents) {
    // Clear warnings from previous generation
    warnings.clear();
    final builder = XmlBuilder();

    builder
      ..processing('xml', 'version="1.0" encoding="utf-8"')
      ..element(
        'shortcuts',
        nest: () {
          builder.namespace(
            'http://schemas.android.com/apk/res/android',
            'android',
          );

          for (final intent in intents) {
            _generateCapability(builder, intent);
          }
        },
      );

    final document = builder.buildDocument();
    return document.toXmlString(pretty: true, indent: '  ');
  }

  /// Generate a `<capability>` element for an intent
  void _generateCapability(XmlBuilder builder, ExtractedIntent intent) {
    final biiAction = intent.categoryEnum.androidBII;
    final identifier = intent.identifier!;
    final mainActivity = _getMainActivityClass();

    builder.element(
      'capability',
      nest: () {
        builder
          ..attribute('android:name', biiAction)
          ..element(
            'intent',
            nest: () {
              builder
                ..attribute(
                  'android:targetPackage',
                  r'${applicationId}',
                )
                ..attribute('android:targetClass', mainActivity)
                ..attribute('android:action', 'android.intent.action.VIEW')

                // Use deep link to pass intent identifier
                // (standard Android approach)
                ..attribute('android:data', 'app://intent/$identifier');

              // TODO(user): Add support for intent parameters.
              // This requires extracting parameter info in IntentExtractor and
              // generating <parameter> elements here. For example:
              //
              // builder.element('parameter', nest: () {
              //   builder.attribute('android:name', 'note.title');
              //   builder.attribute('android:key', 'title');
              //   builder.attribute('android:mimeType', 'text/*');
              // });
            },
          );
      },
    );
  }

  /// Get the main activity class name
  ///
  /// Auto-detects from AndroidManifest.xml or falls back to 'MainActivity'
  String _getMainActivityClass() {
    // Use override if provided (from CLI --main-activity)
    if (mainActivityOverride != null) {
      _cachedMainActivity = mainActivityOverride;
      return mainActivityOverride!;
    }

    // Return cached value if available
    if (_cachedMainActivity != null) {
      return _cachedMainActivity!;
    }

    // Try to detect from AndroidManifest.xml
    if (projectRoot != null) {
      final detected = _detectMainActivityFromManifest(projectRoot!);
      if (detected != null) {
        _cachedMainActivity = detected;
        return detected;
      }
    }

    // Fallback to default with warning
    _cachedMainActivity = 'MainActivity';
    warnings.add(
      'Could not auto-detect main activity from AndroidManifest.xml. '
      'Using default: MainActivity. '
      'If your app uses a different activity name, use: '
      'dart run flutter_app_intents:generate --main-activity=YourActivity',
    );
    return _cachedMainActivity!;
  }

  /// Detect the main activity class from AndroidManifest.xml
  ///
  /// Returns null if detection fails
  String? _detectMainActivityFromManifest(String projectRoot) {
    try {
      // Look for AndroidManifest.xml in common locations
      final manifestPaths = [
        path.join(
          projectRoot,
          'android',
          'app',
          'src',
          'main',
          'AndroidManifest.xml',
        ),
        path.join(
          projectRoot,
          'android',
          'src',
          'main',
          'AndroidManifest.xml',
        ),
      ];

      String? manifestPath;
      for (final p in manifestPaths) {
        if (File(p).existsSync()) {
          manifestPath = p;
          break;
        }
      }

      if (manifestPath == null) {
        return null;
      }

      // Parse AndroidManifest.xml
      final manifestContent = File(manifestPath).readAsStringSync();
      final document = XmlDocument.parse(manifestContent);

      // Find the activity with MAIN action and LAUNCHER category
      final activities = document.findAllElements('activity');

      for (final activity in activities) {
        final intentFilters = activity.findElements('intent-filter');

        for (final filter in intentFilters) {
          final actions = filter.findElements('action');
          final categories = filter.findElements('category');

          // Check if this intent filter has MAIN action
          final hasMainAction = actions.any(
            (action) =>
                action.getAttribute('android:name') ==
                'android.intent.action.MAIN',
          );

          // Check if this intent filter has LAUNCHER category
          final hasLauncherCategory = categories.any(
            (category) =>
                category.getAttribute('android:name') ==
                'android.intent.category.LAUNCHER',
          );

          // If both are present, this is the main activity
          if (hasMainAction && hasLauncherCategory) {
            final activityName = activity.getAttribute('android:name');
            if (activityName != null) {
              // Handle relative class names (starting with .)
              if (activityName.startsWith('.')) {
                // Extract just the class name without the leading dot
                return activityName.substring(1);
              }
              // Handle fully qualified names
              else if (activityName.contains('.')) {
                // Extract just the class name from the fully qualified name
                return activityName.split('.').last;
              }
              // Return as-is if it's just a simple name
              return activityName;
            }
          }
        }
      }

      return null;
    } on Object {
      // If detection fails for any reason, return null to use fallback
      return null;
    }
  }
}
