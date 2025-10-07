import 'package:flutter_app_intents/src/generator/intent_extractor.dart';
import 'package:xml/xml.dart';

/// Generates Android string resources for widget support.
///
/// Creates strings.xml with localized string resources referenced by:
/// - Widget info XML files (description)
/// - Widget provider Kotlin classes (loading text)
///
/// These strings can be customized by editing the generated file.
class AndroidStringsGenerator {
  /// Generates or updates strings.xml with widget string resources.
  ///
  /// Returns null if no intents with presentsResult=true.
  String? generateStrings(List<ExtractedIntent> intents) {
    // Filter intents that need widget strings
    final widgetIntents =
        intents.where((i) => i.presentsResult ?? false).toList();

    if (widgetIntents.isEmpty) {
      return null;
    }

    final builder = XmlBuilder()
      ..processing('xml', 'version="1.0" encoding="utf-8"');

    builder.element(
      'resources',
      nest: () {
        // Add header comment
        builder
          ..comment(
            ' Widget string resources - auto-generated '
            'by flutter_app_intents ',
          )
          ..comment(' You can customize these strings for localization ');

        // Generate strings for each widget intent
        for (final intent in widgetIntents) {
          final identifier = intent.identifier!;
          final title = intent.title ?? 'Result';

          builder
            ..comment(' Strings for ${intent.identifier} intent ')

            // Widget description (used in widget info XML)
            ..element(
              'string',
              nest: () {
                builder
                  ..attribute('name', 'widget_${identifier}_description')
                  ..text(_generateDescription(title));
              },
            )

            // Widget loading text (used in widget provider)
            ..element(
              'string',
              nest: () {
                builder
                  ..attribute('name', 'widget_${identifier}_loading')
                  ..text(_generateLoadingText(title));
              },
            )
            ..text('\n');
        }
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

  /// Gets the file path for strings.xml relative to app directory.
  String getStringsFilePath() {
    return 'android/app/src/main/res/values/strings.xml';
  }

  /// Merges generated strings with existing strings.xml content.
  ///
  /// This preserves any user-defined strings while adding/updating
  /// widget-related strings.
  String mergeWithExisting(String existingContent, String newStrings) {
    try {
      final existingDoc = XmlDocument.parse(existingContent);
      final newDoc = XmlDocument.parse(newStrings);

      final existingResources = existingDoc.findElements('resources').first;
      final newResources = newDoc.findElements('resources').first;

      // Get all new string elements
      final newStringElements = newResources.findElements('string').toList();

      // Track which strings we need to add/update
      final newStringNames = <String, XmlElement>{};
      for (final element in newStringElements) {
        final name = element.getAttribute('name');
        if (name != null) {
          newStringNames[name] = element;
        }
      }

      // Update or remove existing widget strings
      final existingStrings = existingResources.findElements('string').toList();
      for (final element in existingStrings) {
        final name = element.getAttribute('name');
        if (name != null && name.startsWith('widget_')) {
          // Remove old widget strings (they'll be re-added with new content)
          element.parent?.children.remove(element);
        }
      }

      // Add all new widget strings and comments
      for (final child in newResources.children) {
        existingResources.children.add(child.copy());
      }

      return existingDoc.toXmlString(pretty: true, indent: '    ');
    } on XmlException {
      // If parsing fails, return the new content
      return newStrings;
    }
  }
}
