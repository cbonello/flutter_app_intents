import 'package:flutter_app_intents/src/generator/android/resource_naming.dart';
import 'package:flutter_app_intents/src/generator/shared/intent_extractor.dart';
import 'package:xml/xml.dart';

/// Generates Android widget provider info XML files.
///
/// Creates widget configuration XML files that define widget properties
/// like initial layout, update period, resize mode, etc.
///
/// The generated XML references an Android string resource
/// (`@string/widget_<identifier>_description`) that is automatically generated
/// by `StringsGenerator`. The description text can be customized via
/// the `widgetDescription()` method on `AppIntentBuilder`.
// TODO(enhancement): Make widget dimensions and properties configurable
// via parameters or a configuration object for more flexibility.
class WidgetInfoGenerator {
  /// Generates a widget provider info XML for the given intent.
  ///
  /// Returns null if the intent doesn't present results (presentsResult=false).
  ///
  /// Throws [ArgumentError] if the intent identifier is null or empty.
  String? generateWidgetInfo(ExtractedIntent intent) {
    if (intent.presentsResult != true) {
      return null;
    }

    // Validate intent identifier
    if (intent.identifier == null || intent.identifier!.isEmpty) {
      throw ArgumentError(
        'Intent identifier must not be null or empty for widget generation',
      );
    }

    final builder = XmlBuilder()
      ..processing('xml', 'version="1.0" encoding="utf-8"');

    final layoutName = ResourceNaming.layoutName(intent.identifier!);

    builder.element(
      'appwidget-provider',
      nest: () {
        builder
          ..attribute(
            'xmlns:android',
            'http://schemas.android.com/apk/res/android',
          )
          ..attribute('android:initialLayout', '@layout/$layoutName')
          // Default dimensions: 2x1 grid cells (180dp x 40dp minimum)
          ..attribute('android:minWidth', '180dp')
          ..attribute('android:minHeight', '40dp')
          // updatePeriodMillis = 0: manual updates only (no periodic refresh)
          ..attribute('android:updatePeriodMillis', '0')
          // Description from auto-generated strings.xml
          ..attribute(
            'android:description',
            '@string/${ResourceNaming.descriptionStringName(intent.identifier!)}',
          )
          ..attribute('android:widgetCategory', 'home_screen')
          // Allow both horizontal and vertical resizing
          ..attribute('android:resizeMode', 'horizontal|vertical');
      },
    );

    return builder.buildDocument().toXmlString(pretty: true, indent: '    ');
  }

  /// Gets the widget info file name for an intent.
  String getWidgetInfoFileName(ExtractedIntent intent) {
    return ResourceNaming.widgetInfoFileName(intent.identifier!);
  }
}
