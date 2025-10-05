import 'package:equatable/equatable.dart';

/// Represents a single intent donation for batch processing
///
/// Used when donating multiple intent executions to the system
/// for improved ML learning and predictions.
class IntentDonation extends Equatable {
  const IntentDonation({
    required this.identifier,
    required this.parameters,
    this.relevanceScore = 1.0,
    this.context = const {},
    this.timestamp,
  }) : assert(
          relevanceScore >= 0.0 && relevanceScore <= 1.0,
          'relevanceScore must be between 0.0 and 1.0, got $relevanceScore',
        );

  /// Creates an intent donation with high relevance (for frequently used
  /// intents)
  const IntentDonation.highRelevance({
    required this.identifier,
    required this.parameters,
    this.context = const {},
    this.timestamp,
  }) : relevanceScore = 1.0;

  /// Creates an intent donation with medium relevance
  const IntentDonation.mediumRelevance({
    required this.identifier,
    required this.parameters,
    this.context = const {},
    this.timestamp,
  }) : relevanceScore = 0.7;

  /// Creates an intent donation with low relevance (for rarely used intents)
  const IntentDonation.lowRelevance({
    required this.identifier,
    required this.parameters,
    this.context = const {},
    this.timestamp,
  }) : relevanceScore = 0.3;

  /// Creates an intent donation for user-initiated actions
  const IntentDonation.userInitiated({
    required this.identifier,
    required this.parameters,
    this.context = const {},
    this.timestamp,
  }) : relevanceScore = 0.9;

  /// Creates an intent donation for automated/background actions
  const IntentDonation.automated({
    required this.identifier,
    required this.parameters,
    this.context = const {},
    this.timestamp,
  }) : relevanceScore = 0.5;

  /// The intent identifier that was executed
  final String identifier;

  /// The parameters used in this execution
  final Map<String, dynamic> parameters;

  /// Relevance score (0.0 to 1.0)
  ///
  /// Indicates how relevant this execution was.
  /// Higher scores suggest the system should weight this donation more heavily.
  final double relevanceScore;

  /// Additional context for the donation (iOS-specific)
  ///
  /// Provides extra metadata that can help with intent prediction.
  /// This field is primarily used by iOS and may be ignored on other platforms.
  final Map<String, dynamic> context;

  /// When this execution occurred
  ///
  /// Defaults to current time if not specified.
  final DateTime? timestamp;

  @override
  List<Object?> get props => [
        identifier,
        parameters,
        relevanceScore,
        context,
        timestamp,
      ];

  @override
  String toString() {
    return 'IntentDonation('
        'identifier: $identifier, '
        'parameters: $parameters, '
        'relevanceScore: $relevanceScore, '
        'context: $context, '
        'timestamp: $timestamp)';
  }
}
