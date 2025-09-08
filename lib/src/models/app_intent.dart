import 'package:equatable/equatable.dart';

import 'package:flutter_app_intents/src/models/app_intent_parameter.dart';

/// Represents an Apple App Intent that can be registered with Siri and
/// Shortcuts
class AppIntent extends Equatable {
  const AppIntent({
    required this.identifier,
    required this.title,
    required this.description,
    this.parameters = const [],
    this.isEligibleForSearch = true,
    this.isEligibleForPrediction = true,
    this.authenticationPolicy = AuthenticationPolicy.none,
  });

  /// Creates AppIntent from a map representation
  AppIntent.fromMap(Map<String, dynamic> map)
      : identifier = map['identifier'] as String,
        title = map['title'] as String,
        description = map['description'] as String,
        parameters = (map['parameters'] as List<dynamic>?)
                ?.map((p) {
                  if (p is Map<String, dynamic>) {
                    return AppIntentParameter.fromMap(p);
                  } else {
                    return AppIntentParameter.fromMap(
                      Map<String, dynamic>.from(p as Map<Object?, Object?>),
                    );
                  }
                })
                .toList() ??
            [],
        isEligibleForSearch = map['isEligibleForSearch'] as bool? ?? true,
        isEligibleForPrediction = 
            map['isEligibleForPrediction'] as bool? ?? true,
        authenticationPolicy = AuthenticationPolicy.values.firstWhere(
          (policy) => policy.name == map['authenticationPolicy'],
          orElse: () => AuthenticationPolicy.none,
        );

  /// Unique identifier for the intent
  final String identifier;

  /// Display title for the intent
  final String title;

  /// Description of what the intent does
  final String description;

  /// Parameters that can be passed to the intent
  final List<AppIntentParameter> parameters;


  /// Whether the intent can appear in Spotlight search results
  final bool isEligibleForSearch;

  /// Whether the intent can be predicted by Siri
  final bool isEligibleForPrediction;

  /// Authentication policy for the intent
  final AuthenticationPolicy authenticationPolicy;

  @override
  List<Object?> get props => [
        identifier,
        title,
        description,
        parameters,
        isEligibleForSearch,
        isEligibleForPrediction,
        authenticationPolicy,
      ];

  /// Creates a copy of this AppIntent with the given fields replaced
  AppIntent copyWith({
    String? identifier,
    String? title,
    String? description,
    List<AppIntentParameter>? parameters,
    bool? isEligibleForSearch,
    bool? isEligibleForPrediction,
    AuthenticationPolicy? authenticationPolicy,
  }) {
    return AppIntent(
      identifier: identifier ?? this.identifier,
      title: title ?? this.title,
      description: description ?? this.description,
      parameters: parameters ?? this.parameters,
      isEligibleForSearch: isEligibleForSearch ?? this.isEligibleForSearch,
      isEligibleForPrediction: 
          isEligibleForPrediction ?? this.isEligibleForPrediction,
      authenticationPolicy: authenticationPolicy ?? this.authenticationPolicy,
    );
  }

  /// Convert to a map for platform channel communication
  Map<String, dynamic> toMap() {
    return {
      'identifier': identifier,
      'title': title,
      'description': description,
      'parameters': parameters.map((p) => p.toMap()).toList(),
      'isEligibleForSearch': isEligibleForSearch,
      'isEligibleForPrediction': isEligibleForPrediction,
      'authenticationPolicy': authenticationPolicy.name,
    };
  }
}

/// Authentication policy for App Intents
enum AuthenticationPolicy {
  /// No authentication required
  none,

  /// User must be authenticated to the device
  requiresAuthentication,

  /// User must unlock the device to run the intent
  requiresUnlockedDevice,
}
