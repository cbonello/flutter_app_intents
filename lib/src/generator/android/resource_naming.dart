/// Centralized naming conventions for Android widget resources.
///
/// All Android generators must use these methods to derive resource names
/// from intent identifiers. This ensures consistency across generated
/// layout XML, widget info XML, widget provider Kotlin classes, and
/// string resources.
class ResourceNaming {
  ResourceNaming._();

  /// The Android resource name for the widget layout.
  ///
  /// Used in:
  /// - Layout XML file name: `widget_<id>.xml`
  /// - Widget info XML: `@layout/widget_<id>`
  /// - Widget provider Kotlin: `R.layout.widget_<id>`
  static String layoutName(String identifier) => 'widget_$identifier';

  /// The Android resource name for the widget description string.
  ///
  /// Used in:
  /// - `strings.xml`: `<string name="widget_<id>_description">`
  /// - Widget info XML: `@string/widget_<id>_description`
  static String descriptionStringName(String identifier) =>
      'widget_${identifier}_description';

  /// The Android resource name for the widget loading string.
  ///
  /// Used in:
  /// - `strings.xml`: `<string name="widget_<id>_loading">`
  /// - Widget layout XML: `@string/widget_<id>_loading`
  static String loadingStringName(String identifier) =>
      'widget_${identifier}_loading';

  /// The layout file name for an intent's widget.
  static String layoutFileName(String identifier) =>
      'widget_$identifier.xml';

  /// The layout resource ID for use in Kotlin code.
  static String layoutResourceId(String identifier) =>
      'R.layout.widget_$identifier';

  /// The widget info file name for an intent.
  static String widgetInfoFileName(String identifier) =>
      '${identifier}_widget_info.xml';

  /// Pattern for valid Android resource identifiers.
  ///
  /// Must contain only lowercase letters, digits, and underscores.
  /// Must start with a letter or underscore.
  static final RegExp validResourcePattern = RegExp(r'^[a-z_][a-z0-9_]*$');

  /// Whether an identifier is a valid Android resource name.
  static bool isValidResourceName(String identifier) =>
      validResourcePattern.hasMatch(identifier);
}
