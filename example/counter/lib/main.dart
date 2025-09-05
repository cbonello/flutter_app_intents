/// Example app demonstrating Flutter App Intents package usage.
///
/// This example shows how to integrate Apple App Intents with Flutter using
/// the Flutter App Intents package. It demonstrates:
/// - Creating App Intents with parameters
/// - Registering intent handlers
/// - Handling Siri voice commands
/// - Intent donation for improved predictions
///
/// Key features demonstrated:
/// - Counter increment intent with optional amount parameter
/// - Counter reset intent
/// - Counter query intent for reading current value
/// - Proper error handling and user feedback
///
/// To test the intents:
/// 1. Run the app on iOS 16.0+ device or simulator
/// 2. Try voice commands like "Hey Siri, increment counter"
/// 3. Check Shortcuts app for available actions
/// 4. Use Spotlight search to find app actions
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_intents/flutter_app_intents.dart';

/// Entry point for the flutter_app_intents example application.
///
/// Initializes the Flutter app with Material Design theme and sets up
/// the main page for demonstrating App Intents functionality.
void main() {
  runApp(const MyApp());
}

/// Root application widget for the flutter_app_intents example.
///
/// Sets up the Material app with:
/// - App title and theme configuration
/// - Material Design 3 styling
/// - Deep purple color scheme
/// - Routes to the main demonstration page
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App Intents Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter App Intents Example'),
    );
  }
}

/// Main demonstration page for flutter_app_intents functionality.
///
/// This page showcases App Intents integration by:
/// - Setting up and registering intents during initialization
/// - Displaying current app state and registration status
/// - Providing manual controls alongside voice commands
/// - Showing registered intents for debugging purposes
///
/// The page maintains a simple counter that can be controlled via:
/// - Manual button tap (traditional UI)
/// - Siri voice commands (App Intents)
/// - iOS Shortcuts app actions
/// - Spotlight search integration
class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title, super.key});

  /// The title displayed in the app bar
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// State management for the main demonstration page.
///
/// Manages:
/// - Counter value that can be modified via intents or UI
/// - List of successfully registered intents for display
/// - Status messages for user feedback
/// - flutter_app_intents client instance for intent operations
class _MyHomePageState extends State<MyHomePage> {
  /// Current counter value that can be incremented, reset, or queried
  int _counter = 0;

  /// List of intents that have been successfully registered with the system
  List<AppIntent> _registeredIntents = [];

  /// Current status message to show setup progress and errors
  String _status = 'Ready';

  /// Singleton instance of flutter_app_intents client for intent management
  final FlutterAppIntentsClient _client = FlutterAppIntentsClient.instance;

  @override
  void initState() {
    super.initState();
    // Initialize App Intents when the widget is first created
    _setupIntents();
  }

  /// Sets up and registers App Intents with the iOS system.
  ///
  /// This method demonstrates the complete App Intents setup process:
  /// 1. Platform validation (iOS 16.0+ required)
  /// 2. Intent creation using the fluent builder pattern
  /// 3. Parameter configuration for complex intents
  /// 4. Handler registration for intent execution
  /// 5. System integration and shortcuts update
  /// 6. Error handling and user feedback
  ///
  /// Creates three example intents:
  /// - Increment: Adds to counter with optional amount parameter
  /// - Reset: Sets counter back to zero
  /// - Query: Returns current counter value (search-eligible)
  Future<void> _setupIntents() async {
    // Validate platform compatibility
    if (!Platform.isIOS) {
      setState(() {
        _status = 'App Intents are only supported on iOS';
      });
      return;
    }

    try {
      // Create increment intent with optional parameter
      // This demonstrates parameterized intents with type safety
      final incrementIntent = AppIntentBuilder()
          .identifier('increment_counter')
          .title('Increment Counter')
          .description('Increments the counter by one')
          .parameter(
            const AppIntentParameter(
              name: 'amount',
              title: 'Amount',
              type: AppIntentParameterType.integer,
              description: 'Amount to increment by',
              isOptional: true,
              defaultValue: 1,
            ),
          )
          .build();

      // Create simple reset intent without parameters
      // This demonstrates basic intent structure
      final resetIntent = AppIntentBuilder()
          .identifier('reset_counter')
          .title('Reset Counter')
          .description('Resets the counter to zero')
          .build();

      // Create query intent with search eligibility
      // This demonstrates Spotlight integration
      final getCounterIntent = AppIntentBuilder()
          .identifier('get_counter')
          .title('Get Counter Value')
          .description('Returns the current counter value')
          .eligibleForSearch(eligible: true)
          .build();

      // Register all intents with their corresponding handlers
      // This creates the mapping between intents and business logic
      await _client.registerIntents({
        incrementIntent: _handleIncrementIntent,
        resetIntent: _handleResetIntent,
        getCounterIntent: _handleGetCounterIntent,
      });

      // Update system shortcuts to reflect new intents
      await _client.updateShortcuts();

      // Retrieve and display registered intents for debugging
      _registeredIntents = await _client.getRegisteredIntents();

      setState(() {
        _status = 'Intents registered successfully';
      });
    } on Object catch (e) {
      // Handle and display any setup errors
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  /// Handles the increment counter intent invocation.
  ///
  /// This demonstrates parameter handling and state management:
  /// - Extracts optional 'amount' parameter with default value
  /// - Updates app state using setState for UI reactivity
  /// - Donates intent execution to improve Siri predictions
  /// - Returns success result with descriptive message
  ///
  /// Parameters:
  /// - amount (optional int): How much to increment, defaults to 1
  ///
  /// Returns success with current counter value or error on failure.
  Future<AppIntentResult> _handleIncrementIntent(
    Map<String, dynamic> parameters,
  ) async {
    // Extract parameter with type safety and default value
    final amount = parameters['amount'] as int? ?? 1;

    // Update app state to reflect the change
    setState(() => _counter += amount);

    // Donate this intent execution to help Siri learn user patterns
    await _client.donateIntent('increment_counter', parameters);

    // Return successful result with informative message
    return AppIntentResult.successful(
      value: 'Counter incremented by $amount. New value: $_counter',
      needsToContinueInApp: true,
    );
  }

  /// Handles the reset counter intent invocation.
  ///
  /// This demonstrates simple intent handling without parameters:
  /// - Resets counter to zero
  /// - Updates UI through setState
  /// - Donates execution for learning
  /// - Returns confirmation message
  ///
  /// No parameters required for this intent.
  /// Returns success confirmation or error on failure.
  Future<AppIntentResult> _handleResetIntent(
    Map<String, dynamic> parameters,
  ) async {
    // Reset counter to initial value
    setState(() => _counter = 0);

    // Donate for Siri learning
    await _client.donateIntent('reset_counter', parameters);

    // Return success confirmation
    return AppIntentResult.successful(
      value: 'Counter reset to 0',
      needsToContinueInApp: true,
    );
  }

  /// Handles the get counter value intent invocation.
  ///
  /// This demonstrates read-only intent handling:
  /// - Accesses current state without modification
  /// - Returns current value to the user
  /// - Supports Spotlight search integration
  /// - Donates for prediction improvement
  ///
  /// No parameters required for this query intent.
  /// Returns current counter value or error on failure.
  Future<AppIntentResult> _handleGetCounterIntent(
    Map<String, dynamic> parameters,
  ) async {
    print('🔍 Flutter: _handleGetCounterIntent called with counter = $_counter');
    
    // Donate for learning (queries are also valuable for predictions)
    await _client.donateIntent('get_counter', parameters);

    final resultValue = 'Current counter value is $_counter';
    print('🔍 Flutter: Returning result: $resultValue');
    
    // Return current state as result
    return AppIntentResult.successful(
      value: resultValue,
    );
  }

  /// Manual counter increment for traditional UI interaction.
  ///
  /// This provides the same functionality as the intent handler but
  /// triggered by direct user interaction (button tap). This demonstrates
  /// how the same business logic can be accessed through multiple channels:
  /// - Traditional UI (this method)
  /// - Voice commands (intent handlers)
  /// - Shortcuts app
  /// - Spotlight search
  void _incrementCounter() => setState(() => _counter++);

  /// Builds the main UI for the flutter_app_intents demonstration.
  ///
  /// The UI is designed to:
  /// - Show current app state and intent registration status
  /// - Provide visual feedback about App Intents functionality
  /// - Display Siri command examples for user guidance
  /// - List registered intents for debugging and transparency
  /// - Offer manual controls alongside voice commands
  ///
  /// Layout structure:
  /// - App bar with title
  /// - Status card showing setup state
  /// - Instruction cards for Siri commands
  /// - Counter display and manual increment button
  /// - Debug list of registered intents
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Status card showing intent registration state
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'App Intents Status:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Instructions for using Siri with the registered intents
            const Text('You can now use Siri to control this counter:'),
            const SizedBox(height: 10),
            Card(
              color: Colors.blue,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      'Try these Siri commands:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    // Example voice commands that will trigger the intents
                    Text(
                      '• "Increment counter with Flutter App Intents Example"\n'
                      '• "Reset counter with Flutter App Intents Example"\n'
                      '• "Get counter from Flutter App Intents Example"',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Current counter display - shows state managed by intents
            const Text('Current counter value:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),

            // Debug section: Show registered intents for transparency
            if (_registeredIntents.isNotEmpty) ...[
              const Text(
                'Registered Intents:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // List each registered intent with its details
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _registeredIntents.length,
                  itemBuilder: (context, index) {
                    final intent = _registeredIntents[index];
                    return Card(
                      child: ListTile(
                        title: Text(intent.title),
                        subtitle: Text(intent.description),
                        trailing: Chip(
                          label: Text(
                            intent.identifier,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      // Manual increment button - traditional UI alongside voice control
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
