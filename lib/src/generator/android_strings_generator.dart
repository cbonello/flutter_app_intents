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
    } on XmlException {
      // If parsing fails, return the new content
      return newStrings;
    }
  }
}
