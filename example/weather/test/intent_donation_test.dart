// Weather App Intent Donation Tests
//
// Tests intent donation behavior for weather query intents, including
// cross-platform compatibility, parameter handling, and donation timing.

import 'package:flutter_app_intents/flutter_app_intents.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Weather Intent Donation Tests', () {
    group('Donation API', () {
      test('donateIntentWithMetadata succeeds on all platforms', () async {
        // Intent donation should silently succeed on all platforms
        // This allows cross-platform code without platform checks
        final result = await FlutterAppIntentsClient.instance
            .donateIntentWithMetadata(
          'get_current_weather',
          {'location': 'San Francisco'},
        );

        expect(result, isTrue);
      });

      test('donateIntentWithMetadata accepts custom relevance score',
          () async {
        // High relevance for user-initiated query
        final result = await FlutterAppIntentsClient.instance
            .donateIntentWithMetadata(
          'get_current_weather',
          {'location': 'San Francisco'},
          relevanceScore: 0.9,
        );

        expect(result, isTrue);
      });

      test('donateIntentWithMetadata accepts context metadata', () async {
        final result = await FlutterAppIntentsClient.instance
            .donateIntentWithMetadata(
          'get_current_weather',
          {'location': 'San Francisco'},
          context: {
            'source': 'manual_test',
            'time_of_day': 'morning',
          },
        );

        expect(result, isTrue);
      });

      test('donateIntentWithMetadata accepts custom timestamp', () async {
        final customTimestamp = DateTime(2024, 1, 15, 9, 30);
        final result = await FlutterAppIntentsClient.instance
            .donateIntentWithMetadata(
          'get_current_weather',
          {'location': 'San Francisco'},
          timestamp: customTimestamp,
        );

        expect(result, isTrue);
      });

      test('donateIntentWithMetadata works with all weather intents', () async {
        final intents = [
          {'id': 'get_current_weather', 'params': {'location': 'Seattle'}},
          {'id': 'get_temperature', 'params': {'location': 'Portland'}},
          {
            'id': 'get_weather_forecast',
            'params': {'location': 'Denver', 'days': 5},
          },
          {'id': 'check_rain', 'params': {'location': 'Miami'}},
        ];

        for (final intent in intents) {
          final result = await FlutterAppIntentsClient.instance
              .donateIntentWithMetadata(
            intent['id'] as String,
            intent['params'] as Map<String, dynamic>,
          );
          expect(result, isTrue, reason: 'Failed for ${intent['id']}');
        }
      });
    });

    group('Parameter Handling', () {
      test('handles location parameter correctly', () async {
        final locations = [
          'San Francisco',
          'New York',
          'London',
          'Tokyo',
          'current location',
        ];

        for (final location in locations) {
          final result = await FlutterAppIntentsClient.instance
              .donateIntentWithMetadata(
            'get_current_weather',
            {'location': location},
          );
          expect(result, isTrue, reason: 'Failed for location: $location');
        }
      });

      test('handles days parameter in forecast intent', () async {
        final daysValues = [1, 3, 5, 7, 10];

        for (final days in daysValues) {
          final result = await FlutterAppIntentsClient.instance
              .donateIntentWithMetadata(
            'get_weather_forecast',
            {'location': 'Seattle', 'days': days},
          );
          expect(result, isTrue, reason: 'Failed for days: $days');
        }
      });

      test('handles optional parameters correctly', () async {
        // Donation with minimal parameters (using defaults)
        final result1 = await FlutterAppIntentsClient.instance
            .donateIntentWithMetadata(
          'get_current_weather',
          {}, // No location - should use default
        );
        expect(result1, isTrue);

        // Donation with all parameters specified
        final result2 = await FlutterAppIntentsClient.instance
            .donateIntentWithMetadata(
          'get_weather_forecast',
          {
            'location': 'Miami',
            'days': 7,
          },
        );
        expect(result2, isTrue);
      });

      test('handles null parameter values gracefully', () async {
        final result = await FlutterAppIntentsClient.instance
            .donateIntentWithMetadata(
          'get_current_weather',
          {'location': null},
        );
        expect(result, isTrue);
      });

      test('handles empty parameter map', () async {
        final result = await FlutterAppIntentsClient.instance
            .donateIntentWithMetadata(
          'get_current_weather',
          {},
        );
        expect(result, isTrue);
      });
    });

    group('Relevance Scoring', () {
      test('accepts default relevance score (1.0)', () async {
        final result = await FlutterAppIntentsClient.instance
            .donateIntentWithMetadata(
          'get_current_weather',
          {'location': 'Boston'},
        );
        expect(result, isTrue);
      });

      test('accepts high relevance score for user-initiated queries',
          () async {
        // User directly asked "what's the weather?"
        final result = await FlutterAppIntentsClient.instance
            .donateIntentWithMetadata(
          'get_current_weather',
          {'location': 'Boston'},
          relevanceScore: 0.9,
        );
        expect(result, isTrue);
      });

      test('accepts medium relevance score for automated queries', () async {
        // App automatically checked weather at startup
        final result = await FlutterAppIntentsClient.instance
            .donateIntentWithMetadata(
          'get_current_weather',
          {'location': 'Boston'},
          relevanceScore: 0.5,
        );
        expect(result, isTrue);
      });

      test('accepts low relevance score for background queries', () async {
        // Weather updated in background
        final result = await FlutterAppIntentsClient.instance
            .donateIntentWithMetadata(
          'get_current_weather',
          {'location': 'Boston'},
          relevanceScore: 0.3,
        );
        expect(result, isTrue);
      });

      test('accepts boundary relevance scores', () async {
        // Test minimum and maximum values
        final result1 = await FlutterAppIntentsClient.instance
            .donateIntentWithMetadata(
          'get_current_weather',
          {'location': 'Boston'},
          relevanceScore: 0.0,
        );
        expect(result1, isTrue);

        final result2 = await FlutterAppIntentsClient.instance
            .donateIntentWithMetadata(
          'get_current_weather',
          {'location': 'Boston'},
          relevanceScore: 1.0,
        );
        expect(result2, isTrue);
      });
    });

    group('Context Metadata', () {
      test('accepts context with source information', () async {
        final result = await FlutterAppIntentsClient.instance
            .donateIntentWithMetadata(
          'get_current_weather',
          {'location': 'Chicago'},
          context: {'source': 'voice_command'},
        );
        expect(result, isTrue);
      });

      test('accepts context with time-based information', () async {
        final result = await FlutterAppIntentsClient.instance
            .donateIntentWithMetadata(
          'get_current_weather',
          {'location': 'Chicago'},
          context: {
            'time_of_day': 'morning',
            'day_of_week': 'Monday',
          },
        );
        expect(result, isTrue);
      });

      test('accepts context with user preference information', () async {
        final result = await FlutterAppIntentsClient.instance
            .donateIntentWithMetadata(
          'get_temperature',
          {'location': 'Phoenix'},
          context: {
            'unit_preference': 'fahrenheit',
            'detail_level': 'brief',
          },
        );
        expect(result, isTrue);
      });

      test('accepts empty context map', () async {
        final result = await FlutterAppIntentsClient.instance
            .donateIntentWithMetadata(
          'get_current_weather',
          {'location': 'Austin'},
          context: {},
        );
        expect(result, isTrue);
      });

      test('accepts null context', () async {
        final result = await FlutterAppIntentsClient.instance
            .donateIntentWithMetadata(
          'get_current_weather',
          {'location': 'Austin'},
          context: null,
        );
        expect(result, isTrue);
      });
    });

    group('Timestamp Handling', () {
      test('uses current time when timestamp not provided', () async {
        final result = await FlutterAppIntentsClient.instance
            .donateIntentWithMetadata(
          'get_current_weather',
          {'location': 'Seattle'},
        );
        expect(result, isTrue);
      });

      test('accepts custom timestamp', () async {
        final customTime = DateTime(2024, 3, 15, 14, 30);
        final result = await FlutterAppIntentsClient.instance
            .donateIntentWithMetadata(
          'get_current_weather',
          {'location': 'Seattle'},
          timestamp: customTime,
        );
        expect(result, isTrue);
      });

      test('accepts past timestamp', () async {
        final pastTime = DateTime.now().subtract(const Duration(hours: 2));
        final result = await FlutterAppIntentsClient.instance
            .donateIntentWithMetadata(
          'get_current_weather',
          {'location': 'Seattle'},
          timestamp: pastTime,
        );
        expect(result, isTrue);
      });

      test('accepts current timestamp', () async {
        final currentTime = DateTime.now();
        final result = await FlutterAppIntentsClient.instance
            .donateIntentWithMetadata(
          'get_current_weather',
          {'location': 'Seattle'},
          timestamp: currentTime,
        );
        expect(result, isTrue);
      });
    });

    group('Donation Best Practices', () {
      test('donates after successful weather query', () async {
        // Simulate successful weather query flow
        final weatherParams = {'location': 'Portland'};

        // 1. Execute query (mocked)
        final querySuccess = true;

        // 2. Donate intent after success
        if (querySuccess) {
          final result = await FlutterAppIntentsClient.instance
              .donateIntentWithMetadata(
            'get_current_weather',
            weatherParams,
            relevanceScore: 0.9, // User-initiated
          );
          expect(result, isTrue);
        }
      });

      test('includes actual parameter values used', () async {
        // Use actual values from the query, not placeholders
        final actualLocation = 'San Francisco';
        final actualDays = 5;

        final result = await FlutterAppIntentsClient.instance
            .donateIntentWithMetadata(
          'get_weather_forecast',
          {
            'location': actualLocation,
            'days': actualDays,
          },
        );
        expect(result, isTrue);
      });

      test('donates consistently for all query executions', () async {
        // Simulate multiple query executions
        final queries = [
          {'intent': 'get_current_weather', 'location': 'Boston'},
          {'intent': 'get_temperature', 'location': 'New York'},
          {'intent': 'check_rain', 'location': 'Seattle'},
        ];

        for (final query in queries) {
          final result = await FlutterAppIntentsClient.instance
              .donateIntentWithMetadata(
            query['intent'] as String,
            {'location': query['location']},
          );
          expect(result, isTrue);
        }
      });
    });

    group('Cross-Platform Compatibility', () {
      test('no platform checks needed for donation', () async {
        // This code works on all platforms without Platform.isIOS checks
        final result = await FlutterAppIntentsClient.instance
            .donateIntentWithMetadata(
          'get_current_weather',
          {'location': 'Denver'},
        );
        expect(result, isTrue);
      });

      test('multiple donations work consistently', () async {
        // Donate same intent multiple times
        for (var i = 0; i < 5; i++) {
          final result = await FlutterAppIntentsClient.instance
              .donateIntentWithMetadata(
            'get_current_weather',
            {'location': 'Miami'},
          );
          expect(result, isTrue);
        }
      });

      test('different intents can be donated in sequence', () async {
        final intents = [
          'get_current_weather',
          'get_temperature',
          'get_weather_forecast',
          'check_rain',
        ];

        for (final intent in intents) {
          final result = await FlutterAppIntentsClient.instance
              .donateIntentWithMetadata(
            intent,
            {'location': 'Atlanta'},
          );
          expect(result, isTrue);
        }
      });
    });

    group('Error Conditions', () {
      test('handles donation with invalid intent identifier', () async {
        // Should still succeed (silently ignored on non-iOS)
        final result = await FlutterAppIntentsClient.instance
            .donateIntentWithMetadata(
          'nonexistent_intent',
          {},
        );
        expect(result, isTrue);
      });

      test('handles donation with unusual parameter values', () async {
        final result = await FlutterAppIntentsClient.instance
            .donateIntentWithMetadata(
          'get_current_weather',
          {
            'location': 'X' * 1000, // Very long string
          },
        );
        expect(result, isTrue);
      });

      test('handles donation with mixed parameter types', () async {
        final result = await FlutterAppIntentsClient.instance
            .donateIntentWithMetadata(
          'get_weather_forecast',
          {
            'location': 'Seattle',
            'days': '5', // String instead of int
          },
        );
        expect(result, isTrue);
      });
    });
  });
}
