import 'package:flutter_app_intents/src/generator/android/resource_naming.dart';
import 'package:flutter_app_intents/src/generator/shared/intent_extractor.dart';
import 'package:xml/xml.dart';

/// Generates Android widget layout XML files for intents that present results.
///
/// Creates RemoteViews-compatible layout XML that can be used by
/// AppWidgetProvider to display intent results.
///
/// For v0.8.0, this generates a simple generic text layout for all intents
/// with presentsResult=true. Future versions will support rich layouts based
/// on ResultLayout specifications.
// TODO(enhancement): Support customizable layouts through ResultLayout API,
// allowing developers to define custom widget appearances per intent.
class WidgetLayoutGenerator {
  // Default layout styling constants
  // These provide consistent styling across all generated widgets but could
  // be made configurable in future versions.

  /// Default padding around widget content (Material Design guideline: 16dp)
  static const String _defaultPadding = '16dp';

  /// Default title text size (Material Design subtitle: 16sp)
  static const String _defaultTitleSize = '16sp';

  /// Default result text size (Material Design body text: 14sp)
  static const String _defaultResultSize = '14sp';

  /// Default title text color (black for high contrast)
  static const String _defaultTitleColor = '#000000';

  /// Default result text color (gray for secondary content)
  static const String _defaultResultColor = '#666666';

  /// Default background color (transparent for theme compatibility)
  static const String _defaultBackgroundColor = '#00000000';

  /// Default margin between title and result (Material Design spacing: 8dp)
  static const String _defaultMarginBetween = '8dp';

  /// Generates a simple widget layout XML for the given intent.
  ///
  /// Returns null if the intent doesn't present results (presentsResult=false).
  ///
  /// Throws [ArgumentError] if the intent identifier is null or empty.
  String? generateLayout(ExtractedIntent intent) {
    if (intent.presentsResult != true) {
      return null;
    }

    // Validate required fields
    if (intent.identifier == null || intent.identifier!.isEmpty) {
      throw ArgumentError(
        'Intent identifier must not be null or empty for widget generation',
      );
    }

    final builder = XmlBuilder()
      ..processing('xml', 'version="1.0" encoding="utf-8"');

    // Generate a simple text-based layout
    _generateSimpleTextLayout(builder, intent);

    return builder.buildDocument().toXmlString(pretty: true, indent: '    ');
  }

  /// Generates a simple text layout for displaying results.
  ///
  /// Creates a vertical LinearLayout with two TextViews:
  /// - Title TextView: Displays the intent name (bold, larger text)
  /// - Result TextView: Displays the result value (regular, smaller text)
  ///
  /// The layout uses Material Design guidelines for spacing and typography.
  /// The result TextView references a string resource for proper localization.
  void _generateSimpleTextLayout(XmlBuilder builder, ExtractedIntent intent) {
    final intentId = intent.identifier!;
    final displayTitle = intent.title ?? 'Result';

    builder.element(
      'LinearLayout',
      nest: () {
        builder
          ..attribute(
            'xmlns:android',
            'http://schemas.android.com/apk/res/android',
          )
          ..attribute('android:layout_width', 'match_parent')
          ..attribute('android:layout_height', 'wrap_content')
          ..attribute('android:orientation', 'vertical')
          ..attribute('android:padding', _defaultPadding)
          ..attribute('android:gravity', 'center')
          ..attribute('android:background', _defaultBackgroundColor)

          // Title TextView: Shows the intent name (static)
          ..element(
            'TextView',
            nest: () {
              builder
                ..attribute('android:id', '@+id/widget_title')
                ..attribute('android:layout_width', 'match_parent')
                ..attribute('android:layout_height', 'wrap_content')
                ..attribute('android:textSize', _defaultTitleSize)
                ..attribute('android:textStyle', 'bold')
                ..attribute('android:textColor', _defaultTitleColor)
                ..attribute('android:gravity', 'center')
                ..attribute(
                  'android:layout_marginBottom',
                  _defaultMarginBetween,
                )
                ..attribute('android:text', displayTitle);
            },
          )

          // Result TextView: Shows the intent result (dynamic)
          // Initial text loaded from string resource, then updated by provider
          ..element(
            'TextView',
            nest: () {
              builder
                ..attribute('android:id', '@+id/widget_result')
                ..attribute('android:layout_width', 'match_parent')
                ..attribute('android:layout_height', 'wrap_content')
                ..attribute('android:textSize', _defaultResultSize)
                ..attribute('android:textColor', _defaultResultColor)
                ..attribute('android:gravity', 'center')
                ..attribute(
                  'android:text',
                  '@string/${ResourceNaming.loadingStringName(intentId)}',
                );
            },
          );
      },
    );
  }

  /// Gets the layout file name for an intent.
  String getLayoutFileName(ExtractedIntent intent) {
    return ResourceNaming.layoutFileName(intent.identifier!);
  }

  /// Gets the layout resource ID for an intent.
  String getLayoutResourceId(ExtractedIntent intent) {
    return ResourceNaming.layoutResourceId(intent.identifier!);
  }
}
