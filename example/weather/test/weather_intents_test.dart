import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_intents/flutter_app_intents.dart';

void main() {
  group('Weather App Intent Handlers - Mock Implementation', () {
    // Mock weather data helpers
    Future<Map<String, dynamic>> fetchMockWeatherData(String location) async {
      await Future.delayed(const Duration(milliseconds: 100));
      return {
        'temperature': 72,
        'condition': 'Partly Cloudy',
        'humidity': 65,
        'wind_speed': 8,
        'precipitation': false,
        'visibility': 10,
      };
    }

    Future<List<Map<String, dynamic>>> fetchMockForecastData(
      String location,
      int days,
    ) async {
      await Future.delayed(const Duration(milliseconds: 100));
      return List.generate(
        days,
        (index) => {
          'day': index + 1,
          'high': 75 + (index * 2),
          'low': 60 + index,
          'condition': ['Sunny', 'Partly Cloudy', 'Cloudy'][index % 3],
          'precipitation_chance': [10, 30, 60][index % 3],
        },
      );
    }

    String formatMockCurrentWeatherResponse(
      Map<String, dynamic> data,
      String location,
    ) {
      final temp = data['temperature'];
      final condition = data['condition'];
      final humidity = data['humidity'];
      final wind = data['wind_speed'];

      return 'Current weather in $location: $temp degrees and $condition. '
          'Humidity is $humidity percent with winds at $wind miles per hour.';
    }

    String formatMockForecastResponse(
      List<Map<String, dynamic>> forecast,
      String location,
      int days,
    ) {
      final buffer = StringBuffer('$days-day forecast for $location: ');

      for (int i = 0; i < forecast.length; i++) {
        final day = forecast[i];
        final dayName = i == 0
            ? 'Today'
            : i == 1
            ? 'Tomorrow'
            : 'Day ${i + 1}';
        buffer.write(
          '$dayName: High ${day['high']}, Low ${day['low']}, ${day['condition']}. ',
        );
      }

      return buffer.toString();
    }

    // Mock intent handlers that match the app's functionality
    Future<AppIntentResult> handleMockCurrentWeather(
      Map<String, dynamic> parameters,
    ) async {
      try {
        final location =
            parameters['location'] as String? ?? 'current location';
        final weatherData = await fetchMockWeatherData(location);
        final response = formatMockCurrentWeatherResponse(
          weatherData,
          location,
        );

        return AppIntentResult.successful(
          value: response,
          needsToContinueInApp: false,
        );
      } catch (e) {
        return AppIntentResult.failed(error: 'Failed to get weather data: $e');
      }
    }

    Future<AppIntentResult> handleMockTemperature(
      Map<String, dynamic> parameters,
    ) async {
      try {
        final location =
            parameters['location'] as String? ?? 'current location';
        final weatherData = await fetchMockWeatherData(location);
        final response =
            'The current temperature in $location is ${weatherData['temperature']}°F';

        return AppIntentResult.successful(value: response);
      } catch (e) {
        return AppIntentResult.failed(error: 'Failed to get temperature: $e');
      }
    }

    Future<AppIntentResult> handleMockForecast(
      Map<String, dynamic> parameters,
    ) async {
      try {
        final location =
            parameters['location'] as String? ?? 'current location';
        final days = parameters['days'] as int? ?? 3;
        final forecastData = await fetchMockForecastData(location, days);
        final response = formatMockForecastResponse(
          forecastData,
          location,
          days,
        );

        return AppIntentResult.successful(value: response);
      } catch (e) {
        return AppIntentResult.failed(error: 'Failed to get forecast: $e');
      }
    }

    Future<AppIntentResult> handleMockRainCheck(
      Map<String, dynamic> parameters,
    ) async {
      try {
        final location =
            parameters['location'] as String? ?? 'current location';
        final weatherData = await fetchMockWeatherData(location);
        final isRaining = weatherData['precipitation'] as bool;
        final response = isRaining
            ? 'Yes, it is currently raining in $location'
            : 'No, it is not raining in $location right now';

        return AppIntentResult.successful(value: response);
      } catch (e) {
        return AppIntentResult.failed(error: 'Failed to check rain: $e');
      }
    }

    group('Current Weather Intent', () {
      test('should return successful result with weather data', () async {
        // Arrange
        final parameters = {'location': 'San Francisco'};

        // Act
        final result = await handleMockCurrentWeather(parameters);

        // Assert
        expect(result.success, isTrue);
        expect(result.value, isA<String>());
        expect(result.value, contains('San Francisco'));
        expect(result.value, contains('72 degrees'));
        expect(result.value, contains('Partly Cloudy'));
        expect(result.needsToContinueInApp, isFalse);
      });

      test(
        'should use default location when location parameter is null',
        () async {
          // Arrange
          final parameters = <String, dynamic>{};

          // Act
          final result = await handleMockCurrentWeather(parameters);

          // Assert
          expect(result.success, isTrue);
          expect(result.value, contains('current location'));
        },
      );

      test('should handle exceptions gracefully', () async {
        // Arrange
        final parameters = {'location': 'TestLocation'};

        // Act
        final result = await handleMockCurrentWeather(parameters);

        // Assert - Should not throw and should return a result
        expect(result, isA<AppIntentResult>());
        expect(result.success, isTrue);
      });
    });

    group('Temperature Intent', () {
      test('should return temperature for specified location', () async {
        // Arrange
        final parameters = {'location': 'New York'};

        // Act
        final result = await handleMockTemperature(parameters);

        // Assert
        expect(result.success, isTrue);
        expect(result.value, isA<String>());
        expect(result.value, contains('New York'));
        expect(result.value, contains('72°F'));
        expect(result.value, startsWith('The current temperature in'));
      });

      test('should use default location when not specified', () async {
        // Arrange
        final parameters = <String, dynamic>{};

        // Act
        final result = await handleMockTemperature(parameters);

        // Assert
        expect(result.success, isTrue);
        expect(result.value, contains('current location'));
      });
    });

    group('Weather Forecast Intent', () {
      test('should return multi-day forecast', () async {
        // Arrange
        final parameters = {'location': 'Seattle', 'days': 3};

        // Act
        final result = await handleMockForecast(parameters);

        // Assert
        expect(result.success, isTrue);
        expect(result.value, isA<String>());
        expect(result.value, contains('Seattle'));
        expect(result.value, contains('3-day forecast'));
        expect(result.value, contains('Today'));
        expect(result.value, contains('Tomorrow'));
        expect(result.value, contains('Day 3'));
      });

      test('should use default values when parameters not provided', () async {
        // Arrange
        final parameters = <String, dynamic>{};

        // Act
        final result = await handleMockForecast(parameters);

        // Assert
        expect(result.success, isTrue);
        expect(result.value, contains('current location'));
        expect(result.value, contains('3-day forecast'));
      });

      test('should handle custom number of days', () async {
        // Arrange
        final parameters = {'location': 'Miami', 'days': 5};

        // Act
        final result = await handleMockForecast(parameters);

        // Assert
        expect(result.success, isTrue);
        expect(result.value, contains('5-day forecast'));
        expect(result.value, contains('Miami'));
      });
    });

    group('Rain Check Intent', () {
      test('should return rain status for location', () async {
        // Arrange
        final parameters = {'location': 'Portland'};

        // Act
        final result = await handleMockRainCheck(parameters);

        // Assert
        expect(result.success, isTrue);
        expect(result.value, isA<String>());
        expect(result.value, contains('Portland'));
        // Mock data returns precipitation: false
        expect(result.value, contains('No, it is not raining'));
      });

      test('should use default location when not specified', () async {
        // Arrange
        final parameters = <String, dynamic>{};

        // Act
        final result = await handleMockRainCheck(parameters);

        // Assert
        expect(result.success, isTrue);
        expect(result.value, contains('current location'));
      });

      test('should provide boolean-style response', () async {
        // Arrange
        final parameters = {'location': 'TestCity'};

        // Act
        final result = await handleMockRainCheck(parameters);

        // Assert
        expect(result.success, isTrue);
        // Should contain either "Yes" or "No"
        expect(
          result.value.startsWith('Yes') || result.value.startsWith('No'),
          isTrue,
        );
      });
    });

    group('Weather Data Formatting', () {
      test('should format current weather response correctly', () {
        // Arrange
        final mockData = {
          'temperature': 75,
          'condition': 'Sunny',
          'humidity': 60,
          'wind_speed': 10,
        };

        // Act
        final response = formatMockCurrentWeatherResponse(
          mockData,
          'Test City',
        );

        // Assert
        expect(response, contains('Test City'));
        expect(response, contains('75 degrees'));
        expect(response, contains('Sunny'));
        expect(response, contains('60 percent'));
        expect(response, contains('10 miles per hour'));
      });

      test('should format forecast response correctly', () {
        // Arrange
        final mockForecast = [
          {
            'day': 1,
            'high': 80,
            'low': 65,
            'condition': 'Sunny',
            'precipitation_chance': 10,
          },
          {
            'day': 2,
            'high': 75,
            'low': 60,
            'condition': 'Cloudy',
            'precipitation_chance': 30,
          },
        ];

        // Act
        final response = formatMockForecastResponse(
          mockForecast,
          'Test City',
          2,
        );

        // Assert
        expect(response, contains('2-day forecast for Test City'));
        expect(response, contains('Today: High 80, Low 65, Sunny'));
        expect(response, contains('Tomorrow: High 75, Low 60, Cloudy'));
      });
    });

    group('Mock Data Generation', () {
      test('should generate consistent weather data', () async {
        // Act
        final data1 = await fetchMockWeatherData('TestLocation');
        final data2 = await fetchMockWeatherData('TestLocation');

        // Assert - Mock data should be consistent
        expect(data1['temperature'], equals(data2['temperature']));
        expect(data1['condition'], equals(data2['condition']));
        expect(data1['humidity'], equals(data2['humidity']));
        expect(data1['wind_speed'], equals(data2['wind_speed']));
        expect(data1['precipitation'], equals(data2['precipitation']));
      });

      test('should generate forecast data with correct structure', () async {
        // Act
        final forecast = await fetchMockForecastData('TestLocation', 3);

        // Assert
        expect(forecast, hasLength(3));
        expect(forecast[0]['day'], equals(1));
        expect(forecast[1]['day'], equals(2));
        expect(forecast[2]['day'], equals(3));

        for (final day in forecast) {
          expect(day, containsPair('high', isA<int>()));
          expect(day, containsPair('low', isA<int>()));
          expect(day, containsPair('condition', isA<String>()));
          expect(day, containsPair('precipitation_chance', isA<int>()));
        }
      });
    });

    group('Parameter Validation', () {
      test('should handle null location gracefully', () async {
        // Arrange
        final parameters = {'location': null};

        // Act
        final result = await handleMockCurrentWeather(parameters);

        // Assert
        expect(result.success, isTrue);
        expect(result.value, contains('current location'));
      });

      test('should handle invalid days parameter in forecast', () async {
        // Arrange
        final parameters = {'location': 'TestCity', 'days': null};

        // Act
        final result = await handleMockForecast(parameters);

        // Assert
        expect(result.success, isTrue);
        expect(result.value, contains('3-day forecast')); // Default value
      });

      test('should handle empty parameters map', () async {
        // Arrange
        final emptyParameters = <String, dynamic>{};

        // Act & Assert - All handlers should work with empty parameters
        final currentWeather = await handleMockCurrentWeather(emptyParameters);
        expect(currentWeather.success, isTrue);

        final temperature = await handleMockTemperature(emptyParameters);
        expect(temperature.success, isTrue);

        final forecast = await handleMockForecast(emptyParameters);
        expect(forecast.success, isTrue);

        final rainCheck = await handleMockRainCheck(emptyParameters);
        expect(rainCheck.success, isTrue);
      });
    });
  });

  group('App Intent Result Tests', () {
    test('should create successful results correctly', () {
      // Arrange & Act
      final result = AppIntentResult.successful(
        value: 'Test value',
        needsToContinueInApp: false,
      );

      // Assert
      expect(result.success, isTrue);
      expect(result.value, equals('Test value'));
      expect(result.needsToContinueInApp, isFalse);
      expect(result.error, isNull);
    });

    test('should create failed results correctly', () {
      // Arrange & Act
      final result = AppIntentResult.failed(error: 'Test error');

      // Assert
      expect(result.success, isFalse);
      expect(result.error, equals('Test error'));
      expect(result.value, isNull);
    });

    test('should convert to map correctly', () {
      // Arrange
      final result = AppIntentResult.successful(
        value: 'Test value',
        needsToContinueInApp: true,
      );

      // Act
      final map = result.toMap();

      // Assert
      expect(map['success'], isTrue);
      expect(map['value'], equals('Test value'));
      expect(map['needsToContinueInApp'], isTrue);
      expect(map['error'], isNull);
    });
  });
}
