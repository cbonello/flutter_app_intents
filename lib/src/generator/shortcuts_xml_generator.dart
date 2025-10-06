import 'dart:io';

import 'package:flutter_app_intents/src/generator/intent_extractor.dart';
import 'package:path/path.dart' as path;
import 'package:xml/xml.dart';

/// Generates the `shortcuts.xml` file required for Android App Actions.
class ShortcutsXmlGenerator {
  /// Creates a new instance of the shortcuts.xml generator.
  ///
  /// The [projectRoot] is used to find the `AndroidManifest.xml` for
  /// auto-detecting the main activity.
  ShortcutsXmlGenerator({this.projectRoot});

  /// The absolute path to the project root directory.
  final String? projectRoot;

  /// An optional override for the main activity class name.
  ///
  /// If provided, this value will be used for the `android:targetClass`
  /// attribute in the generated `shortcuts.xml`. This is typically set via the
  /// `--main-activity` CLI flag.
  String? mainActivityOverride;

  /// Cached main activity class name to avoid repeated file lookups.
  String? _cachedMainActivity;

  /// A list of non-fatal warnings generated during the XML generation process.
  ///
  /// This list is cleared at the beginning of each `generate` call.
  final List<String> warnings = [];

  /// Generates the XML content for `shortcuts.xml` based on a list of
  /// [intents].
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

  /// Generate a `<capability>` element for an intent.
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

  /// Gets the main activity class name.
  ///
  /// The lookup order is:
  /// 1. [mainActivityOverride] if it is not null.
  /// 2. The cached value from a previous detection.
  /// 3. Auto-detection from `AndroidManifest.xml`.
  /// 4. Fallback to 'MainActivity' if detection fails.
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

  /// Detects the main activity class from `AndroidManifest.xml`.
  ///
  /// Returns the activity name as a string, or `null` if detection fails.
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
              if (activityName.startsWith('.')) {
                return activityName.substring(1);
              }

              // For fully qualified or simple names, return the part after
              // the last dot, or the whole string if no dot is present.
              final parts = activityName.split('.');

              return parts.last;
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
