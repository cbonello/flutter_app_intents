---
sidebar_position: 2
---

# Getting Started

## Installation

### Flutter Plugin (Recommended)

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_app_intents: ^0.6.0
```

### Swift Package Manager (Advanced)

For iOS developers who want to use the native Swift components directly:

**Via Xcode:** File → Add Package Dependencies → `https://github.com/cbonello/flutter_app_intents`

**Via Package.swift:**
```swift
dependencies: [
    .package(url: "https://github.com/cbonello/flutter_app_intents", from: "0.6.0")
]
```

> **Note:** SPM support is provided for advanced use cases and iOS-specific integrations. Most Flutter developers should use the standard plugin installation above.

## Requirements

- iOS 16.0 or later
- Flutter 3.8.1 or later
- Xcode 14.0 or later

## Architecture Overview

This plugin uses a **hybrid approach** combining:

1. **Static Swift intents** in your main iOS app target (required for iOS discovery)
2. **Dynamic Flutter handlers** registered through the plugin (your business logic)

```
iOS Shortcuts/Siri → Static Swift Intent → Flutter Plugin Bridge → Your Flutter Handler
```

The static Swift intents act as a bridge, calling your Flutter handlers when executed.

## Quick Start

### 1. Import the package

```dart
import 'package:flutter_app_intents/flutter_app_intents.dart';
```

### 2. Add static intents to iOS (Required)

⚠️ **First, add static App Intents to your iOS `AppDelegate.swift`** (see [iOS Configuration](ios-configuration) section)

### 3. Create and register Flutter handlers

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
    final client = FlutterAppIntentsClient.instance;
    
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

### 4. Handle intent execution

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

## Next Steps

- Explore complete [Examples](examples) with Counter, Navigation, and Weather apps
- Follow our [Step-by-Step Tutorial](tutorial) for a complete walkthrough
- Learn about [Navigation with App Intents](navigation)
- Explore [Enhanced Intent Donation](intent-donation)
- Check out the [API Reference](api-reference)