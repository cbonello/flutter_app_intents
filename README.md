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

⚠️ **First, add static App Intents to your iOS `AppDelegate.swift`** (see iOS Configuration section below)

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

## Navigation with App Intents

Our plugin excels at handling app navigation through voice commands and shortcuts. Here's how to implement navigation intents:

### Navigation Intent Pattern

For navigation, use `needsToContinueInApp: true` to tell iOS to focus your app and `OpensIntent` return type in Swift:

**iOS Implementation:**
```swift
@available(iOS 16.0, *)
struct OpenProfileIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Profile"
    static var description = IntentDescription("Open user profile page")
    static var isDiscoverable = true
    
    @Parameter(title: "User ID")
    var userId: String?
    
    func perform() async throws -> some IntentResult & OpensIntent {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "open_profile",
            parameters: ["userId": userId ?? "current"]
        )
        
        if let success = result["success"] as? Bool, success {
            return .result() // This opens/focuses the app
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to open profile"
            throw AppIntentError.executionFailed(errorMessage)
        }
    }
}
```

**Flutter Handler:**
```dart
Future<AppIntentResult> _handleOpenProfileIntent(
  Map<String, dynamic> parameters,
) async {
  final userId = parameters['userId'] as String? ?? 'current';
  
  // Navigate to the target page
  Navigator.of(context).pushNamed('/profile', arguments: {'userId': userId});
  
  return AppIntentResult.successful(
    value: 'Opening profile for user $userId',
    needsToContinueInApp: true, // Critical: focuses the app
  );
}
```

### Common Navigation Patterns

#### 1. Deep Linking with Parameters
```dart
// Navigate to specific content with parameters
Future<AppIntentResult> _handleOpenChatIntent(Map<String, dynamic> parameters) async {
  final contactName = parameters['contactName'] as String;
  
  Navigator.of(context).pushNamed('/chat', arguments: {
    'contactName': contactName,
    'openedViaIntent': true,
  });
  
  return AppIntentResult.successful(
    value: 'Opening chat with $contactName',
    needsToContinueInApp: true,
  );
}
```

#### 2. Search Navigation
```dart
// Handle search queries with navigation
Future<AppIntentResult> _handleSearchIntent(Map<String, dynamic> parameters) async {
  final query = parameters['query'] as String;
  
  Navigator.of(context).pushNamed('/search', arguments: {'query': query});
  
  return AppIntentResult.successful(
    value: 'Searching for "$query"',
    needsToContinueInApp: true,
  );
}
```

#### 3. Settings/Configuration Navigation
```dart
// Navigate to specific settings pages
Future<AppIntentResult> _handleOpenSettingsIntent(Map<String, dynamic> parameters) async {
  final section = parameters['section'] as String? ?? 'general';
  
  Navigator.of(context).pushNamed('/settings/$section');
  
  return AppIntentResult.successful(
    value: 'Opening $section settings',
    needsToContinueInApp: true,
  );
}
```

### Navigation with GoRouter

If you're using GoRouter, the pattern is similar:

```dart
Future<AppIntentResult> _handleNavigationIntent(Map<String, dynamic> parameters) async {
  final route = parameters['route'] as String;
  
  // Use GoRouter for navigation
  context.go(route);
  
  return AppIntentResult.successful(
    value: 'Navigating to $route',
    needsToContinueInApp: true,
  );
}
```

### AppShortcuts for Navigation

Add navigation shortcuts to your `AppShortcutsProvider`:

```swift
@available(iOS 16.0, *)
struct AppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
            // Navigation shortcuts
            AppShortcut(
                intent: OpenProfileIntent(),
                phrases: [
                    "Open my profile in ${applicationName}",
                    "Show profile using ${applicationName}",
                    "Go to profile with ${applicationName}"
                ]
            ),
            AppShortcut(
                intent: OpenChatIntent(),
                phrases: [
                    "Chat with \\(.contactName) using ${applicationName}",
                    "Open chat with \\(.contactName) in ${applicationName}",
                    "Message \\(.contactName) with ${applicationName}"
                ]
            )
        ]
    }
}
```

### Navigation vs Action Intents

| Intent Type | Return Type | Use Case | Example |
|-------------|-------------|----------|---------|
| **Action** | `ReturnsValue<String>` | Execute functionality | "Increment counter", "Send message" |
| **Navigation** | `OpensIntent` | Navigate to pages | "Open profile", "Show chat" |
| **Combined** | `ReturnsValue<String> & OpensIntent` | Action + navigation | "Create note and open editor" |

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

### Required Setup: Static App Intents in Main App Target

**⚠️ Important**: iOS App Intents framework requires static intent declarations in your main app target, not just dynamic registration from the plugin. 

Add this code to your iOS app's `AppDelegate.swift`:

```swift
import Flutter
import UIKit
import AppIntents
import flutter_app_intents

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// Static App Intents that bridge to Flutter handlers
@available(iOS 16.0, *)
struct MyCounterIntent: AppIntent {
    static var title: LocalizedStringResource = "Increment Counter"
    static var description = IntentDescription("Increment the counter by one")
    static var isDiscoverable = true
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "increment_counter", 
            parameters: [:]
        )
        
        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Counter incremented"
            return .result(value: value)
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to increment counter"
            throw AppIntentError.executionFailed(errorMessage)
        }
    }
}

// Error handling for App Intents
enum AppIntentError: Error {
    case executionFailed(String)
}

// AppShortcutsProvider for Siri/Shortcuts discovery
@available(iOS 16.0, *)
struct AppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
            AppShortcut(
                intent: MyCounterIntent(),
                phrases: [
                    "Increment counter with ${applicationName}",
                    "Add one with ${applicationName}",
                    "Count up using ${applicationName}"
                ]
            )
        ]
    }
}
```

### Info.plist Configuration

Add these permissions and configuration to your iOS `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app uses microphone for Siri integration</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app uses speech recognition for Siri integration</string>

<!-- App Intents Configuration -->
<key>NSAppIntentsConfiguration</key>
<dict>
    <key>NSAppIntentsPackage</key>
    <string>your_app_bundle_id</string>
</dict>
<key>NSAppIntentsMetadata</key>
<dict>
    <key>NSAppIntentsSupported</key>
    <true/>
</dict>
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

### General Practices
1. **Keep intent names simple and descriptive**
2. **Use appropriate parameter types**
3. **Provide good descriptions for discoverability**
4. **Handle errors gracefully**
5. **Test with Siri and Shortcuts app**

### Navigation Intents
6. **Always use `needsToContinueInApp: true`** for navigation intents
7. **Use `OpensIntent` return type** in Swift for navigation
8. **Handle app state properly** - check if context is still mounted
9. **Pass meaningful parameters** to destination pages
10. **Consider app lifecycle** - navigation may happen when app is backgrounded

### Intent Donation Strategy
11. **Donate intents strategically**:
   - Use enhanced donation with metadata for better Siri learning
   - Donate after successful execution only
   - Use appropriate relevance scores based on usage patterns
   - Provide contextual information to improve predictions
   - Use batch donations for related intents
12. **Navigation intents should have high relevance** (0.8-1.0) when user-initiated
13. **Monitor donation performance and adjust relevance scores** based on user behavior

### App Integration
14. **Static intents must match Flutter handlers** - ensure identifier consistency
15. **Handle app cold starts** - navigation intents may launch your app
16. **Test edge cases** - what happens when target pages don't exist?
17. **Provide fallback navigation** - graceful handling of invalid routes

## Example

Check out the [example app](example/) for a complete implementation showing:

### Action Intents
- Counter increment/reset/query intents
- Parameter handling with type safety
- Error management and validation

### Navigation Intents  
- Deep linking with parameters
- Search navigation patterns
- Settings page navigation
- App focusing and lifecycle management

### Advanced Features
- Basic and enhanced intent donation
- Batch donation examples
- Relevance score optimization
- Context-aware donations
- Siri integration testing
- Navigation with Flutter Router and GoRouter

## Troubleshooting

### "App Intents are only supported on iOS"

This plugin only works on iOS 16.0+. Make sure you're testing on a compatible device or simulator.

### Intents not appearing in Siri/Shortcuts

**Most Common Issue**: Missing static App Intents in main app target

1. **Verify static intents are declared** in your `AppDelegate.swift` (see iOS Configuration above)
2. **Ensure AppShortcutsProvider exists** in your main app target
3. **Check intent identifiers match** between static Swift intents and Flutter handlers
4. **Restart the app completely** after adding static intents
5. Ensure intents are registered successfully on Flutter side
6. Check that `isEligibleForPrediction` is `true`
7. Try donating the intent after manual execution
8. Restart the Shortcuts app

**Architecture Note**: iOS App Intents framework requires static intent declarations at compile time for Siri/Shortcuts discovery. Dynamic registration from Flutter plugins alone is not sufficient.

### Voice commands not recognized

1. Use simple, clear command phrases
2. Test different phrasings
3. Check Siri's language settings
4. Verify intent titles are descriptive

### Navigation intents not working

1. **Verify `needsToContinueInApp: true`** in Flutter result
2. **Check `OpensIntent` return type** in Swift intent
3. **Ensure routes exist** in your app's navigation setup
4. **Test app lifecycle** - try when app is backgrounded vs foreground
5. **Check mounted context** before navigation calls
6. **Verify parameter passing** to destination screens

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