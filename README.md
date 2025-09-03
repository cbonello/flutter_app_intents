# Flutter App Intents

A Flutter plugin for integrating Apple App Intents with your iOS applications. This plugin enables your Flutter app to work seamlessly with Siri, Shortcuts, Spotlight, and other system experiences on iOS 16.0 and later.

## Features

- **Siri Integration**: Create custom voice commands for your app
- **Shortcuts Support**: Allow users to create custom shortcuts
- **Spotlight Integration**: Make your app's actions discoverable in search
- **Visual Intelligence**: Support for visual search results (iOS 2025+)
- **Widgets and Controls**: Enhanced widget and control center integration
- **Type-Safe API**: Strongly typed Dart API with comprehensive error handling
- **Enhanced Intent Donation**: Advanced intent donation with metadata, relevance scoring, and batch processing for improved Siri learning

## Requirements

- iOS 16.0 or later
- Flutter 3.8.1 or later
- Xcode 14.0 or later

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_app_intents:
    path: packages/flutter_app_intents
```

## Quick Start

### 1. Import the package

```dart
import 'package:flutter_app_intents/flutter_app_intents.dart';
```

### 2. Create and register an App Intent

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Register intents during app initialization
    _setupAppIntents();
    
    return MaterialApp(
      title: 'My App',
      home: MyHomePage(),
    );
  }
  
  Future<void> _setupAppIntents() async {
    final client = Flutter App IntentsClient.instance;
    
    // Create an intent using the builder
    final incrementIntent = AppIntentBuilder()
        .identifier('increment_counter')
        .title('Increment Counter')
        .description('Increments the counter by one')
        .parameter(const AppIntentParameter(
          name: 'amount',
          title: 'Amount',
          type: AppIntentParameterType.integer,
          isOptional: true,
          defaultValue: 1,
        ))
        .build();
    
    // Register with a handler
    await client.registerIntent(incrementIntent, (parameters) async {
      final amount = parameters['amount'] as int? ?? 1;
      
      // Your business logic here
      incrementCounter(amount);
      
      return AppIntentResult.successful(
        value: 'Counter incremented by $amount',
      );
    });
  }
}
```

### 3. Handle intent execution

```dart
Future<AppIntentResult> handleIncrementIntent(Map<String, dynamic> parameters) async {
  try {
    final amount = parameters['amount'] as int? ?? 1;
    
    // Perform your app's logic
    final newValue = incrementCounter(amount);
    
    // Donate the intent to help Siri learn (enhanced donation)
    await FlutterAppIntentsService.donateIntentWithMetadata(
      'increment_counter',
      parameters,
      relevanceScore: 0.9, // High relevance for user-initiated actions
      context: {'feature': 'counter', 'userAction': true},
    );
    
    return AppIntentResult.successful(
      value: 'Counter is now $newValue',
    );
  } catch (e) {
    return AppIntentResult.failed(
      error: 'Failed to increment counter: $e',
    );
  }
}
```

## API Reference

### Flutter App IntentsClient

The main client class for managing App Intents:

#### Methods

- `registerIntent(AppIntent intent, handler)` - Register a single intent with handler
- `registerIntents(Map<AppIntent, handler>)` - Register multiple intents
- `unregisterIntent(String identifier)` - Remove an intent
- `getRegisteredIntents()` - Get all registered intents
- `updateShortcuts()` - Refresh app shortcuts
- `donateIntent(String identifier, parameters)` - Basic intent donation for prediction
- `donateIntentWithMetadata(identifier, parameters, {relevanceScore, context, timestamp})` - Enhanced donation with metadata
- `donateIntentBatch(List<IntentDonation> donations)` - Batch donate multiple intents efficiently

### AppIntent

Represents an App Intent configuration:

```dart
const AppIntent({
  required String identifier,      // Unique ID
  required String title,          // Display name
  required String description,    // What it does
  List<AppIntentParameter> parameters = const [],
  bool isEligibleForSearch = true,
  bool isEligibleForPrediction = true,
  AuthenticationPolicy authenticationPolicy = AuthenticationPolicy.none,
});
```

### AppIntentParameter

Defines parameters that can be passed to intents:

```dart
const AppIntentParameter({
  required String name,           // Parameter name
  required String title,          // Display title
  required AppIntentParameterType type,
  String? description,
  bool isOptional = false,
  dynamic defaultValue,
});
```

### AppIntentResult

Result returned from intent execution:

```dart
// Successful result
AppIntentResult.successful(
  value: 'Operation completed',
  needsToContinueInApp: false,
);

// Failed result
AppIntentResult.failed(
  error: 'Something went wrong',
);
```

### AppIntentBuilder

Fluent API for creating intents:

```dart
final intent = AppIntentBuilder()
    .identifier('my_intent')
    .title('My Intent')
    .description('Does something useful')
    .parameter(myParameter)
    .eligibleForSearch(true)
    .authenticationPolicy(AuthenticationPolicy.requiresAuthentication)
    .build();
```

## Enhanced Intent Donation

The plugin provides advanced intent donation capabilities to help Siri learn user patterns and provide better predictions.

### Basic Intent Donation

```dart
// Simple donation (legacy API)
await FlutterAppIntentsService.donateIntent('my_intent', {'param': 'value'});
```

### Enhanced Donation with Metadata

```dart
// Enhanced donation with relevance scoring and context
await FlutterAppIntentsService.donateIntentWithMetadata(
  'my_intent',
  {'param': 'value'},
  relevanceScore: 0.8,           // 0.0-1.0 relevance score
  context: {                     // Additional context for better learning
    'feature': 'messaging',
    'userAction': true,
    'timeOfDay': 'morning',
  },
  timestamp: DateTime.now(),     // Optional custom timestamp
);
```

### Batch Intent Donation

For better performance when donating multiple intents:

```dart
final donations = [
  IntentDonation.highRelevance(
    identifier: 'send_message',
    parameters: {'recipient': 'Alice'},
    context: {'recent_contact': true},
  ),
  IntentDonation.userInitiated(
    identifier: 'set_reminder',
    parameters: {'title': 'Meeting'},
    context: {'calendar_event': true},
  ),
  IntentDonation.automated(
    identifier: 'background_sync',
    parameters: {'sync_type': 'incremental'},
  ),
];

await FlutterAppIntentsService.donateIntentBatch(donations);
```

### IntentDonation Factory Constructors

The `IntentDonation` class provides convenient factory constructors for different use cases:

#### High Relevance (1.0)
```dart
IntentDonation.highRelevance(
  identifier: 'frequent_action',
  parameters: {'key': 'value'},
  context: {'usage': 'daily'},
)
```

#### User Initiated (0.9)
```dart
IntentDonation.userInitiated(
  identifier: 'manual_action',
  parameters: {'trigger': 'button_press'},
)
```

#### Medium Relevance (0.7)
```dart
IntentDonation.mediumRelevance(
  identifier: 'occasional_action',
  parameters: {'frequency': 'weekly'},
)
```

#### Automated (0.5)
```dart
IntentDonation.automated(
  identifier: 'background_process',
  parameters: {'type': 'sync'},
)
```

#### Low Relevance (0.3)
```dart
IntentDonation.lowRelevance(
  identifier: 'rare_action',
  parameters: {'last_used': '6_months_ago'},
)
```

### Donation Best Practices

1. **Use appropriate relevance scores**:
   - `1.0` for frequently used, critical actions
   - `0.9` for user-initiated actions
   - `0.7` for moderately used features
   - `0.5` for automated/background processes
   - `0.3` for rarely used features

2. **Provide meaningful context**:
   ```dart
   context: {
     'feature': 'messaging',          // Which app feature
     'userAction': true,              // User vs system initiated
     'timeOfDay': 'evening',          // Temporal context
     'location': 'home',              // Location context
     'frequency': 'daily',            // Usage frequency
   }
   ```

3. **Donate after successful execution**:
   ```dart
   // Execute the intent action
   final result = await performAction();
   
   // Only donate if successful
   if (result.isSuccess) {
     await FlutterAppIntentsService.donateIntentWithMetadata(
       'my_intent',
       parameters,
       relevanceScore: 0.8,
       context: {'success': true},
     );
   }
   ```

4. **Use batch donations for multiple related intents**:
   ```dart
   // When user completes a workflow involving multiple intents
   final workflowDonations = userWorkflow.map((step) => 
     IntentDonation.userInitiated(
       identifier: step.intentId,
       parameters: step.parameters,
       context: {'workflow': 'onboarding', 'step': step.order},
     )
   ).toList();
   
   await FlutterAppIntentsService.donateIntentBatch(workflowDonations);
   ```

## iOS Configuration

### Info.plist

Add these permissions to your iOS `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app uses microphone for Siri integration</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app uses speech recognition for Siri integration</string>
```

### Minimum Deployment Target

Ensure your iOS deployment target is set to 16.0 or later:

```ruby
# ios/Podfile
platform :ios, '16.0'
```

## Parameter Types

The following parameter types are supported:

- `AppIntentParameterType.string` - Text input
- `AppIntentParameterType.integer` - Whole numbers
- `AppIntentParameterType.boolean` - True/false values
- `AppIntentParameterType.double` - Decimal numbers
- `AppIntentParameterType.date` - Date/time values
- `AppIntentParameterType.url` - Web URLs
- `AppIntentParameterType.file` - File references
- `AppIntentParameterType.entity` - Custom app-specific types

## Authentication Policies

Control when intents can be executed:

- `AuthenticationPolicy.none` - No authentication required
- `AuthenticationPolicy.requiresAuthentication` - User must be authenticated
- `AuthenticationPolicy.requiresUnlockedDevice` - Device must be unlocked

## Best Practices

1. **Keep intent names simple and descriptive**
2. **Use appropriate parameter types**
3. **Provide good descriptions for discoverability**
4. **Donate intents strategically**:
   - Use enhanced donation with metadata for better Siri learning
   - Donate after successful execution only
   - Use appropriate relevance scores based on usage patterns
   - Provide contextual information to improve predictions
   - Use batch donations for related intents
5. **Handle errors gracefully**
6. **Test with Siri and Shortcuts app**
7. **Monitor donation performance and adjust relevance scores based on user behavior**

## Example

Check out the [example app](example/) for a complete implementation showing:

- Multiple intent types
- Parameter handling
- Error management
- Basic and enhanced intent donation
- Batch donation examples
- Relevance score optimization
- Context-aware donations
- Siri integration testing

## Troubleshooting

### "App Intents are only supported on iOS"

This plugin only works on iOS 16.0+. Make sure you're testing on a compatible device or simulator.

### Intents not appearing in Siri

1. Ensure intents are registered successfully
2. Check that `isEligibleForPrediction` is `true`
3. Try donating the intent after manual execution
4. Restart the Shortcuts app

### Voice commands not recognized

1. Use simple, clear command phrases
2. Test different phrasings
3. Check Siri's language settings
4. Verify intent titles are descriptive

### Intent donations not improving predictions

1. **Ensure proper relevance scores**: Use higher scores (0.8-1.0) for frequently used actions
2. **Provide meaningful context**: Include feature names, user actions, and usage patterns
3. **Donate consistently**: Only donate after successful intent execution
4. **Use batch donations**: Group related intents for better learning
5. **Monitor and adjust**: Regularly review and update relevance scores based on usage analytics

### "Relevance score must be between 0.0 and 1.0"

This validation error occurs when calling `donateIntentWithMetadata()` with invalid relevance scores. Ensure your relevance score is within the valid range:

```dart
// Valid relevance scores
await FlutterAppIntentsService.donateIntentWithMetadata(
  'my_intent',
  parameters,
  relevanceScore: 0.8, // ✅ Valid: between 0.0 and 1.0
);

// Invalid relevance scores
relevanceScore: 1.5  // ❌ Invalid: greater than 1.0
relevanceScore: -0.1 // ❌ Invalid: less than 0.0
```

## Contributing

This package is an independent Flutter plugin for Apple App Intents integration.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.