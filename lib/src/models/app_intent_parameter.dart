import 'package:equatable/equatable.dart';

/// Represents a parameter that can be passed to an App Intent
class AppIntentParameter extends Equatable {
  const AppIntentParameter({
    required this.name,
    required this.title,
    required this.type,
    this.description,
    this.isOptional = false,
    this.defaultValue,
  });

  /// Parameter name (used programmatically)
  final String name;

  /// Display title for the parameter
  final String title;

  /// Parameter type
  final AppIntentParameterType type;

  /// Optional description of the parameter
  final String? description;

  /// Whether this parameter is optional
  final bool isOptional;

  /// Default value for the parameter
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

  /// Convert to a map for platform channel communication
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'title': title,
      'type': type.name,
      'description': description,
      'isOptional': isOptional,
      'defaultValue': defaultValue,
    };
  }

  /// Create AppIntentParameter from map
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

/// Types of parameters supported by App Intents
enum AppIntentParameterType {
  /// String parameter
  string,

  /// Integer parameter
  integer,

  /// Boolean parameter
  boolean,

  /// Double parameter
  double,

  /// Date parameter
  date,

  /// URL parameter
  url,

  /// File parameter
  file,

  /// Entity parameter (custom app-specific type)
  entity,
}
