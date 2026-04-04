import 'package:equatable/equatable.dart';

/// Represents a parameter that can be passed to an App Intent.
///
/// Each parameter defines a piece of information that an intent can receive
/// when it is invoked.
class AppIntentParameter extends Equatable {
  /// Creates a new [AppIntentParameter].
  ///
  /// The [name], [title], and [type] are required.
  const AppIntentParameter({
    required this.name,
    required this.title,
    required this.type,
    this.description,
    this.isOptional = false,
    this.defaultValue,
  });

  /// The programmatic name of the parameter, used to identify it in code.
  final String name;

  /// The user-facing display title for the parameter.
  final String title;

  /// The data type of the parameter.
  final AppIntentParameterType type;

  /// An optional user-facing description of what the parameter is for.
  final String? description;

  /// Whether this parameter is optional.
  ///
  /// If false, the system will ensure the parameter has a value before the
  /// intent is handled. Defaults to `false`.
  final bool isOptional;

  /// A default value for the parameter, used if no other value is provided.
  final dynamic defaultValue;

  @override
  List<Object?> get props => [
        name,
        title,
        type,
        description,
        isOptional,
        defaultValue,
      ];

  /// Converts this object to a map suitable for platform channel communication.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'title': title,
      'type': type.name,
      if (description != null) 'description': description,
      'isOptional': isOptional,
      if (defaultValue != null) 'defaultValue': defaultValue,
    };
  }

  /// Creates an [AppIntentParameter] from a map, typically received from a
  /// platform channel.
  // ignore: prefer_constructors_over_static_methods
  static AppIntentParameter fromMap(Map<String, dynamic> map) {
    return AppIntentParameter(
      name: map['name'] as String,
      title: map['title'] as String,
      type: AppIntentParameterType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => AppIntentParameterType.string,
      ),
      description: map['description'] as String?,
      isOptional: map['isOptional'] as bool? ?? false,
      defaultValue: map['defaultValue'],
    );
  }
}

/// The data types of parameters that are supported by App Intents.
enum AppIntentParameterType {
  /// A text-based parameter.
  string,

  /// An integer-based parameter.
  integer,

  /// A boolean (true/false) parameter.
  boolean,

  /// A floating-point number parameter.
  double,

  /// A parameter representing a specific date or date-time.
  date,

  /// A parameter representing a URL.
  url,

  /// A parameter representing a file.
  file,

  /// A parameter representing a custom, app-specific entity.
  entity,
}
