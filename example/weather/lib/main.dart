// Weather App Intents Example - Query & Data Patterns
//
// This example demonstrates query-based App Intents that can retrieve and
// provide information without opening the app interface. It showcases:
//
// - Query intents with ProvidesDialog for voice responses
// - Multiple parameter types (location, date, enum)
// - Background data processing without UI
// - Proper voice output formatting for Siri
// - Enhanced intent donation with metadata
//
// Voice Commands Examples:
// - "Get weather from Weather Example"
// - "Check temperature in San Francisco using Weather Example"
// - "What's the forecast for tomorrow in Weather Example"
// - "Is it raining in New York with Weather Example"

import 'package:flutter/material.dart';
import 'package:flutter_app_intents/flutter_app_intents.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App Intents',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  late FlutterAppIntentsClient _client;
  final List<String> _queryLog = [];

  @override
  void initState() {
    super.initState();
    _setupAppIntents();
  }

  /// Sets up all weather query intents
  Future<void> _setupAppIntents() async {
    _client = FlutterAppIntentsClient.instance;

    // Register query intents that work without opening the app
    await _registerWeatherIntents();
  }

  /// Registers all weather-related query intents
  Future<void> _registerWeatherIntents() async {
    // Current weather query intent
    final currentWeatherIntent = AppIntentBuilder()
        .identifier('get_current_weather')
        .title('Get Current Weather')
        .description('Get current weather conditions for a location')
        .parameter(
          const AppIntentParameter(
            name: 'location',
            title: 'Location',
            type: AppIntentParameterType.string,
            isOptional: true,
            defaultValue: 'current location',
          ),
        )
        .eligibleForSearch(eligible: true)
        .eligibleForPrediction(eligible: true)
        .build();

    await _client.registerIntent(currentWeatherIntent, _handleCurrentWeather);

    // Temperature query intent
    final temperatureIntent = AppIntentBuilder()
        .identifier('get_temperature')
        .title('Get Temperature')
        .description('Get current temperature for a location')
        .parameter(
          const AppIntentParameter(
            name: 'location',
            title: 'Location',
            type: AppIntentParameterType.string,
            isOptional: true,
            defaultValue: 'current location',
          ),
        )
        .eligibleForSearch(eligible: true)
        .eligibleForPrediction(eligible: true)
        .build();

    await _client.registerIntent(temperatureIntent, _handleTemperature);

    // Weather forecast intent
    final forecastIntent = AppIntentBuilder()
        .identifier('get_weather_forecast')
        .title('Get Weather Forecast')
        .description('Get weather forecast for upcoming days')
        .parameter(
          const AppIntentParameter(
            name: 'location',
            title: 'Location',
            type: AppIntentParameterType.string,
            isOptional: true,
            defaultValue: 'current location',
          ),
        )
        .parameter(
          const AppIntentParameter(
            name: 'days',
            title: 'Number of Days',
            type: AppIntentParameterType.integer,
            isOptional: true,
            defaultValue: 3,
          ),
        )
        .eligibleForSearch(eligible: true)
        .eligibleForPrediction(eligible: true)
        .build();

    await _client.registerIntent(forecastIntent, _handleForecast);

    // Rain check intent
    final rainCheckIntent = AppIntentBuilder()
        .identifier('check_rain')
        .title('Check Rain')
        .description('Check if it is currently raining at a location')
        .parameter(
          const AppIntentParameter(
            name: 'location',
            title: 'Location',
            type: AppIntentParameterType.string,
            isOptional: true,
            defaultValue: 'current location',
          ),
        )
        .eligibleForSearch(eligible: true)
        .eligibleForPrediction(eligible: true)
        .build();

    await _client.registerIntent(rainCheckIntent, _handleRainCheck);
  }

  /// Handles current weather queries
  /// This intent provides comprehensive weather information via voice
  Future<AppIntentResult> _handleCurrentWeather(
    Map<String, dynamic> parameters,
  ) async {
    try {
      final location = parameters['location'] as String? ?? 'current location';

      // Simulate weather data fetching
      final weatherData = await _fetchWeatherData(location);

      // Log the query for demonstration
      setState(() {
        _queryLog.insert(0, 'Current weather for $location');
      });

      // Donate intent for Siri learning
      await _client.donateIntent('get_current_weather', parameters);

      // Format response optimized for Siri voice output
      final response = _formatCurrentWeatherResponse(weatherData, location);

      return AppIntentResult.successful(
        value: response,
        // Note: needsToContinueInApp = false for background queries
        needsToContinueInApp: false,
      );
    } catch (e) {
      return AppIntentResult.failed(error: 'Failed to get weather data: $e');
    }
  }

  /// Handles temperature-specific queries
  Future<AppIntentResult> _handleTemperature(
    Map<String, dynamic> parameters,
  ) async {
    try {
      final location = parameters['location'] as String? ?? 'current location';

      final weatherData = await _fetchWeatherData(location);

      setState(() {
        _queryLog.insert(0, 'Temperature for $location');
      });

      await _client.donateIntent('get_temperature', parameters);

      final response =
          'The current temperature in $location is '
          '${weatherData['temperature']}°F';

      return AppIntentResult.successful(value: response);
    } catch (e) {
      return AppIntentResult.failed(error: 'Failed to get temperature: $e');
    }
  }

  /// Handles weather forecast queries
  Future<AppIntentResult> _handleForecast(
    Map<String, dynamic> parameters,
  ) async {
    try {
      final location = parameters['location'] as String? ?? 'current location';
      final days = parameters['days'] as int? ?? 3;

      final forecastData = await _fetchForecastData(location, days);

      setState(() {
        _queryLog.insert(0, '$days-day forecast for $location');
      });

      await _client.donateIntent('get_weather_forecast', parameters);

      final response = _formatForecastResponse(forecastData, location, days);

      return AppIntentResult.successful(value: response);
    } catch (e) {
      return AppIntentResult.failed(error: 'Failed to get forecast: $e');
    }
  }

  /// Handles rain check queries
  Future<AppIntentResult> _handleRainCheck(
    Map<String, dynamic> parameters,
  ) async {
    try {
      final location = parameters['location'] as String? ?? 'current location';

      final weatherData = await _fetchWeatherData(location);

      setState(() {
        _queryLog.insert(0, 'Rain check for $location');
      });

      await _client.donateIntent('check_rain', parameters);

      final isRaining = weatherData['precipitation'] as bool;
      final response = isRaining
          ? 'Yes, it is currently raining in $location'
          : 'No, it is not raining in $location right now';

      return AppIntentResult.successful(value: response);
    } catch (e) {
      return AppIntentResult.failed(error: 'Failed to check rain: $e');
    }
  }

  /// Simulates fetching weather data from an API
  Future<Map<String, dynamic>> _fetchWeatherData(String location) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock weather data
    return {
      'temperature': 72,
      'condition': 'Partly Cloudy',
      'humidity': 65,
      'wind_speed': 8,
      'precipitation': false,
      'visibility': 10,
    };
  }

  /// Simulates fetching forecast data
  Future<List<Map<String, dynamic>>> _fetchForecastData(
    String location,
    int days,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));

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

  /// Formats current weather response for optimal Siri speech
  String _formatCurrentWeatherResponse(
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

  /// Formats forecast response for voice output
  String _formatForecastResponse(
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
        '$dayName: High ${day['high']}, Low ${day['low']}, '
        '${day['condition']}. ',
      );
    }

    return buffer.toString();
  }

  /// Manually test weather queries (for development/demo)
  Future<void> _testWeatherQuery(String queryType, String location) async {
    AppIntentResult result;

    switch (queryType) {
      case 'current':
        result = await _handleCurrentWeather({'location': location});
        break;
      case 'temperature':
        result = await _handleTemperature({'location': location});
        break;
      case 'forecast':
        result = await _handleForecast({'location': location, 'days': 3});
        break;
      case 'rain':
        result = await _handleRainCheck({'location': location});
        break;
      default:
        result = AppIntentResult.failed(error: 'Unknown query type');
    }

    // Show result in a dialog
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('$queryType Query Result'),
            content: Text(
              result.success ? result.value : result.error ?? 'Unknown error',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Weather App Intents'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Intents Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'App Intents Status:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Weather query intents registered successfully!',
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Try these Siri commands:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text('• "Get weather from Weather Example"'),
                          Text(
                            '• "Check temperature in San Francisco using '
                            'Weather Example"',
                          ),
                          Text(
                            '• "What\'s the forecast for tomorrow in Weather '
                            'Example"',
                          ),
                          Text(
                            '• "Is it raining in New York with Weather '
                            'Example"',
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Note: These queries work without opening the app!',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Manual Testing Section
            const Text(
              'Manual Testing:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () =>
                      _testWeatherQuery('current', 'San Francisco'),
                  icon: const Icon(Icons.wb_sunny),
                  label: const Text('Current Weather'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _testWeatherQuery('temperature', 'New York'),
                  icon: const Icon(Icons.thermostat),
                  label: const Text('Temperature'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _testWeatherQuery('forecast', 'Seattle'),
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Forecast'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _testWeatherQuery('rain', 'Miami'),
                  icon: const Icon(Icons.umbrella),
                  label: const Text('Rain Check'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Query Log
            const Text(
              'Recent Query Log:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _queryLog.isEmpty
                    ? const Center(
                        child: Text(
                          'No queries yet. Try voice commands or manual '
                          'testing!',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _queryLog.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(_queryLog[index])),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Registered Query Intents Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Registered Query Intents:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('✓ Get Current Weather (with location parameter)'),
                  Text('✓ Get Temperature (location-specific)'),
                  Text('✓ Get Weather Forecast (location + days)'),
                  Text('✓ Check Rain (boolean query)'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
