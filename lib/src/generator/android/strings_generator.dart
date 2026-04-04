import 'package:flutter_app_intents/src/generator/android/resource_naming.dart';
import 'package:flutter_app_intents/src/generator/shared/intent_extractor.dart';
import 'package:xml/xml.dart';

/// Generates Android string resources for widget support.
///
/// Creates `strings.xml` with localized string resources referenced by:
/// - Widget info XML files (`widget_<id>_description`)
/// - Widget layout XML files (`widget_<id>_loading`)
///
/// String values use custom text from `AppIntentBuilder.widgetLoadingText()`
/// and `AppIntentBuilder.widgetDescription()` when provided, falling back to
/// auto-generated defaults derived from the intent title.
///
/// Resource names are derived from [ResourceNaming] for consistency
/// with other Android generators. String values are escaped for Android
/// resource requirements (apostrophes, quotes, leading `@`/`?`).
class StringsGenerator {
  /// Generates or updates strings.xml with widget string resources.
  ///
  /// Returns null if no intents with presentsResult=true.
  String? generateStrings(List<ExtractedIntent> intents) {
    // Filter intents that need widget strings
    final widgetIntents = intents
        .where((i) => (i.presentsResult ?? false) && i.identifier != null)
        .toList();

    if (widgetIntents.isEmpty) {
      return null;
    }

    final builder = XmlBuilder()
      ..processing('xml', 'version="1.0" encoding="utf-8"');

    builder.element(
      'resources',
      nest: () {
        builder
          ..comment(' START: flutter_app_intents auto-generated strings ')
          ..comment(
            ' Widget string resources - auto-generated '
            'by flutter_app_intents ',
          )
          ..comment(' You can customize these strings for localization ');

        // Generate strings for each widget intent
        for (final intent in widgetIntents) {
          final identifier = intent.identifier!;
          final title = intent.title ?? 'Result';

          final descriptionText =
              intent.widgetDescription ?? _generateDescription(title);
          final loadingText =
              intent.widgetLoadingText ?? _generateLoadingText(title);

          builder
            ..comment(' Strings for ${intent.identifier} intent ')

            // Widget description (used in widget info XML)
            ..element(
              'string',
              nest: () {
                builder
                  ..attribute(
                    'name',
                    ResourceNaming.descriptionStringName(identifier),
                  )
                  ..text(_escapeForAndroidResource(descriptionText));
              },
            )

            // Widget loading text (used in widget provider)
            ..element(
              'string',
              nest: () {
                builder
                  ..attribute(
                    'name',
                    ResourceNaming.loadingStringName(identifier),
                  )
                  ..text(_escapeForAndroidResource(loadingText));
              },
            )
            ..text('\n');
        }
        builder.comment(' END: flutter_app_intents auto-generated strings ');
      },
    );

    return builder.buildDocument().toXmlString(pretty: true, indent: '    ');
  }

  /// Generates a user-friendly description for the widget.
  String _generateDescription(String title) {
    // Convert title to lowercase for natural language
    final lowerTitle = title.toLowerCase();
    return 'Displays $lowerTitle results';
  }

  /// Generates a user-friendly loading message.
  String _generateLoadingText(String title) {
    return 'Loading $title…';
  }

  /// Escapes a string for use in an Android `strings.xml` resource value.
  ///
  /// Android resource strings have special escaping requirements beyond
  /// standard XML:
  /// - Apostrophes must be backslash-escaped (`\'`)
  /// - Double quotes must be backslash-escaped (`\"`)
  /// - Backslashes must be escaped (`\\`)
  /// - `@` at the start must be escaped (Android treats it as a reference)
  /// - `?` at the start must be escaped (Android treats it as a theme attr)
  ///
  /// Standard XML entities (`&`, `<`, `>`) are handled by the xml package.
  String _escapeForAndroidResource(String value) {
    var escaped = value
        .replaceAll(r'\', r'\\')
        .replaceAll("'", r"\'")
        .replaceAll('"', r'\"');

    if (escaped.startsWith('@')) {
      escaped = '\\$escaped';
    } else if (escaped.startsWith('?')) {
      escaped = '\\$escaped';
    }

    return escaped;
  }

  /// Gets the file path for strings.xml relative to app directory.
  String getStringsFilePath() {
    return 'android/app/src/main/res/values/strings.xml';
  }

  /// Merges generated strings with existing `strings.xml` content.
  ///
  /// Preserves user-defined strings while adding/updating widget-related
  /// strings. Uses comment markers to identify the auto-generated block.
  ///
  /// Throws [FormatException] if the existing content is not valid XML.
  String mergeWithExisting(String existingContent, String newStrings) {
    try {
      final existingDoc = XmlDocument.parse(existingContent);
      final newDoc = XmlDocument.parse(newStrings);

      final existingResources = existingDoc.findElements('resources').first;
      final newResources = newDoc.findElements('resources').first;

      // Find the start and end markers in the existing document
      final children = existingResources.children;
      int? startIndex;
      int? endIndex;

      for (var i = 0; i < children.length; i++) {
        final node = children[i];
        if (node is XmlComment &&
            node.value.trim() ==
                'START: flutter_app_intents auto-generated strings') {
          startIndex = i;
        } else if (node is XmlComment &&
            node.value.trim() ==
                'END: flutter_app_intents auto-generated strings') {
          endIndex = i;
        }
      }

      // If markers are found, remove the old block
      if (startIndex != null && endIndex != null) {
        children.removeRange(startIndex, endIndex + 1);
      } else if (startIndex != null || endIndex != null) {
        // Only one marker found — the auto-generation block is corrupted
        final found = startIndex != null ? 'START' : 'END';
        final missing = startIndex != null ? 'END' : 'START';
        throw FormatException(
          'Found the $found marker for the flutter_app_intents auto-generated '
          'block in strings.xml but the $missing marker is missing. '
          'Please restore both markers or remove them entirely, then re-run '
          'the generator.',
        );
      } else {
        // No markers found - remove all widget_* strings before adding new
        // block
        children.removeWhere((node) {
          if (node is XmlElement && node.name.local == 'string') {
            final nameAttr = node.getAttribute('name');
            return nameAttr != null && nameAttr.startsWith('widget_');
          }
          return false;
        });
      }

      // Add the new block from newResources
      // Find where to insert. If there was no old block, append at the end.
      final insertIndex = startIndex ?? children.length;
      existingResources.children.insertAll(
        insertIndex,
        newResources.children.map((n) => n.copy()),
      );

      return existingDoc.toXmlString(pretty: true, indent: '    ');
    } on XmlException catch (e) {
      throw FormatException(
        'Failed to parse existing strings.xml. '
        'Please fix the XML syntax error before re-running the generator.\n'
        'Error: $e',
      );
    }
  }
}
