# Flutter App Intents

<p align="center">
  <img src="assets/logo.png" alt="Flutter App Intents Logo" width="200" height="200">
</p>

<p align="center">
  <a href="https://github.com/christophebonello/flutter_app_intents/actions/workflows/ci.yml">
    <img src="https://github.com/christophebonello/flutter_app_intents/workflows/CI%20-%20Test%20Examples/badge.svg" alt="CI Status">
  </a>
</p>

A Flutter plugin for integrating Apple App Intents with your iOS applications. This plugin enables your Flutter app to work seamlessly with Siri, Shortcuts, Spotlight, and other system experiences on iOS 16.0 and later.

## Features

- **Siri Integration**: Create custom voice commands for your app
- **Shortcuts Support**: Allow users to create custom shortcuts
- **Spotlight Integration**: Make your app's actions discoverable in search
- **Visual Intelligence**: Support for visual search results (iOS 2025+)
- **Widgets and Controls**: Enhanced widget and control center integration
- **Type-Safe API**: Strongly typed Dart API with comprehensive error handling
- **Enhanced Intent Donation**: Advanced intent donation with metadata, relevance scoring, and batch processing for improved Siri learning

## Documentation

📖 **[Complete Documentation](https://cbonello.github.io/flutter_app_intents/)** - Visit our comprehensive documentation website with tutorials, examples, and API reference.

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

> 📖 **New to App Intents?** Check out our [Step-by-Step Tutorial](documentation/TUTORIAL.md) for a complete walkthrough from `flutter create` to working Siri integration!

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
    static var openAppWhenRun = true
    
    @Parameter(title: "User ID")
    var userId: String?
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & OpensIntent {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "open_profile",
            parameters: ["userId": userId ?? "current"]
        )
        
        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Profile opened"
            return .result(value: value) // This opens/focuses the app
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
| **Query** | `ReturnsValue<String>` | Get information only | "Get counter value", "Check weather" |
| **Action + App Opening** | `ReturnsValue<String> & OpensIntent` | Execute + show result | "Increment counter", "Send message" |
| **Navigation** | `ReturnsValue<String> & OpensIntent` | Navigate to pages | "Open profile", "Show chat" |

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
    static var openAppWhenRun = true
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & OpensIntent {
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
                    "Increment counter with \(.applicationName)",
                    "Add one with \(.applicationName)",
                    "Count up using \(.applicationName)"
                ]
            )
        ]
    }
}
```

### App Shortcuts Phrase Best Practices

When defining phrases for your App Shortcuts, follow these best practices for optimal user experience and Siri recognition:

#### ⚠️ Important Limitation: Static Phrases Only

**App Shortcuts phrases CANNOT be defined dynamically.** This is a fundamental limitation of Apple's App Intents framework:

```swift
// ❌ DOES NOT WORK - phrases must be static literals
phrases: [
    "\(userDefinedPhrase) with \(.applicationName)",     // Won't compile
    dynamicPhraseVariable,                               // Won't compile
    generatePhrase()                                     // Won't compile
]

// ✅ WORKS - static phrases with dynamic parameters
phrases: [
    "Send message to \(.contactName) with \(.applicationName)",    // ✅ Parameter is dynamic
    "Set timer for \(.duration) using \(.applicationName)",       // ✅ Parameter is dynamic
    "Play \(.songName) in \(.applicationName)"                    // ✅ Parameter is dynamic
]
```

**Why phrases must be static:**
- **Compile-time registration**: iOS requires phrases for Siri's speech recognition engine at build time
- **App Store review**: Apple analyzes all possible voice commands during app review
- **Performance**: Siri's recognition is optimized based on the known phrase list
- **Security**: Prevents apps from creating potentially malicious or conflicting commands dynamically

**Workarounds for dynamic content:**
1. **Use parameters** for the dynamic parts (user names, amounts, etc.)
2. **Provide comprehensive variations** to cover common use cases
3. **Create multiple intent types** for different scenarios instead of one dynamic intent

#### 📊 Phrase Quantity Limits and Guidelines

While Apple doesn't publish exact hard limits, there are practical constraints on the number of phrases:

**Recommended Limits:**
- **Per AppShortcut**: 3-5 phrases (optimal), up to 8 phrases (maximum recommended)
- **Total per app**: 50-100 phrases across all shortcuts (practical limit)
- **Quality over quantity**: Focus on natural, distinct variations rather than exhaustive lists

```swift
// ✅ GOOD - Focused, natural variations (4 phrases)
AppShortcut(
    intent: SendMessageIntent(),
    phrases: [
        "Send message to \(.contactName) with \(.applicationName)",
        "Text \(.contactName) using \(.applicationName)",
        "Message \(.contactName) in \(.applicationName)",
        "Write to \(.contactName) with \(.applicationName)"
    ]
)

// ❌ EXCESSIVE - Too many similar phrases (impacts performance)
AppShortcut(
    intent: SendMessageIntent(),
    phrases: [
        "Send message to \(.contactName) with \(.applicationName)",
        "Send a message to \(.contactName) with \(.applicationName)",
        "Send text message to \(.contactName) with \(.applicationName)",
        "Send a text message to \(.contactName) with \(.applicationName)",
        // ... 15+ more variations
    ]
)
```

**Performance Impact:**
- **More phrases = longer Siri processing time**
- **Diminishing returns**: Beyond 5-8 phrases, recognition accuracy may decrease
- **Memory usage**: Each phrase consumes system resources
- **User confusion**: Too many options can overwhelm users

**Best Strategy:**
1. **Start with 3-4 core phrases** that feel most natural
2. **Test with real users** to see which phrases they actually use
3. **Add variations based on user feedback** rather than guessing
4. **Remove unused phrases** to optimize performance

#### 1. Include App Name for Disambiguation
**✅ Recommended:**
```swift
phrases: [
    "Increment counter with \(.applicationName)",
    "Add one using \(.applicationName)",
    "Count up in \(.applicationName)"
]
```

**❌ Avoid:**
```swift
phrases: [
    "Increment counter",  // Too generic, conflicts with other apps
    "Add one"             // Ambiguous without context
]
```

#### 2. Use Natural Prepositions
Choose prepositions that sound natural in conversation:
- **"with \(.applicationName)"** - Most common, works for actions
- **"using \(.applicationName)"** - Good for tool-like actions  
- **"in \(.applicationName)"** - Natural for location-based commands
- **"from \(.applicationName)"** - Perfect for queries and data retrieval

#### 3. Provide Multiple Variations
Offer 3-5 phrase variations to accommodate different user preferences:
```swift
phrases: [
    "Increment counter with \(.applicationName)",      // Formal
    "Add one using \(.applicationName)",               // Casual
    "Count up in \(.applicationName)",                 // Alternative verb
    "Bump counter with \(.applicationName)",           // Colloquial
    "Increase count using \(.applicationName)"         // Descriptive
]
```

#### 4. Keep Phrases Concise but Descriptive
- **Ideal length**: 3-6 words (excluding app name)
- **Be specific**: "Increment counter" vs. "Do something"
- **Avoid filler words**: Skip "please", "can you", "I want to"

#### 5. Alternative Patterns

**App Name at Beginning** (less common but valid):
```swift
phrases: [
    "Use \(.applicationName) to increment counter",
    "Tell \(.applicationName) to reset timer"
]
```

**Action-First Pattern** (most natural):
```swift
phrases: [
    "Start workout with \(.applicationName)",
    "Send message using \(.applicationName)",
    "Check weather in \(.applicationName)"
]
```

#### 6. Testing Your Phrases
- **Test with Siri**: Speak each phrase to ensure recognition
- **Try variations**: Users might not say exactly what you expect
- **Check conflicts**: Ensure phrases don't overlap with system commands
- **User feedback**: Monitor which phrases users actually use

#### 7. Common Phrase Patterns by Intent Type

**Action Intents:**
```swift
"[Action] [Object] with \(.applicationName)"
"[Verb] [Noun] using \(.applicationName)"
```

**Query Intents:**
```swift
"Get [Data] from \(.applicationName)"
"Check [Status] in \(.applicationName)"
"What's [Information] using \(.applicationName)"
```

**Navigation Intents:**
```swift
"Open [Page] in \(.applicationName)"
"Go to [Section] using \(.applicationName)"
"Show [Content] with \(.applicationName)"
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

### Long-Running Operations and Loading States
6. **No loading indicators during intent execution** - App Intents run outside your Flutter app's UI context through iOS's system-level framework, so you cannot display loading indicators during execution
7. **Use `needsToContinueInApp: true` for long operations** - Return immediately and continue processing in your app:
   ```dart
   Future<AppIntentResult> _handleLongOperation(Map<String, dynamic> parameters) async {
     // Start background work but return immediately
     _startBackgroundWork();
     
     return AppIntentResult.successful(
       value: 'Operation started, opening app for progress...',
       needsToContinueInApp: true,  // Opens your app where you can show progress
     );
   }
   ```
8. **Show progress in Flutter app after intent redirect** - Display loading indicators in your Flutter UI after the intent opens your app
9. **Consider timeout handling** - Long-running intents may timeout at the system level, so break work into smaller chunks

### App Opening Behavior
10. **Use `static var openAppWhenRun = true`** in Swift intents that should open the app
11. **Add `& OpensIntent`** to the return type for intents that open the app
12. **Include `needsToContinueInApp: true`** in Flutter results for visual feedback
13. **Choose appropriate behavior**: Some intents (like queries) may not need to open the app

### Navigation Intents
14. **Always use `needsToContinueInApp: true`** for navigation intents
15. **Add `static var openAppWhenRun = true`** to force app opening
16. **Use `ReturnsValue<String> & OpensIntent`** return type in Swift
17. **Handle app state properly** - check if context is still mounted
18. **Pass meaningful parameters** to destination pages
19. **Consider app lifecycle** - navigation may happen when app is backgrounded

### Intent Donation Strategy
20. **Donate intents strategically**:
   - Use enhanced donation with metadata for better Siri learning
   - Donate after successful execution only
   - Use appropriate relevance scores based on usage patterns
   - Provide contextual information to improve predictions
   - Use batch donations for related intents
21. **Navigation intents should have high relevance** (0.8-1.0) when user-initiated
22. **Monitor donation performance and adjust relevance scores** based on user behavior

### App Integration
23. **Static intents must match Flutter handlers** - ensure identifier consistency
24. **Handle app cold starts** - navigation intents may launch your app
25. **Test edge cases** - what happens when target pages don't exist?
26. **Provide fallback navigation** - graceful handling of invalid routes

## Examples

### 📚 Tutorial: Simple Counter App
Our [Step-by-Step Tutorial](documentation/TUTORIAL.md) walks you through building a complete counter app with Siri integration from scratch.

### 🔍 Example Apps
Check out the [example apps](example/) for complete implementations showing different App Intent patterns:

#### 1. [Counter Example](example/counter/) - Action Intents
- Counter increment/reset/query intents
- Parameter handling with type safety
- Error management and validation
- Action-based voice commands

#### 2. [Navigation Example](example/navigation/) - Navigation Intents  
- Deep linking with parameters
- Search navigation patterns
- Settings page navigation
- App focusing and lifecycle management
- Multi-page Flutter navigation

#### 3. [Weather Example](example/weather/) - Query Intents
- Background data queries with voice responses
- Weather information retrieval
- Temperature and forecast queries
- Boolean rain checks without opening app
- `ProvidesDialog` for Siri speech output

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

**Most Common Issues**: Missing static App Intents or disabled Siri integration

1. **Verify static intents are declared** in your `AppDelegate.swift` (see iOS Configuration above)
2. **Ensure AppShortcutsProvider exists** in your main app target
3. **Enable Siri for App Shortcuts**: In iOS Shortcuts app → [Your App] Shortcuts → Toggle ON the Siri switch (it's OFF by default)
4. **Check intent identifiers match** between static Swift intents and Flutter handlers
5. **Restart the app completely** after adding static intents
6. Ensure intents are registered successfully on Flutter side
7. Check that `isEligibleForPrediction` is `true`
8. Try donating the intent after manual execution
9. Restart the Shortcuts app

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

## Apple Documentation References

For deeper understanding of the underlying iOS concepts, refer to these official Apple resources:

### Core App Intents Framework
- **[App Intents Framework](https://developer.apple.com/documentation/appintents)** - Complete framework documentation
- **[App Intent Protocol](https://developer.apple.com/documentation/appintents/appintent)** - Core protocol documentation
- **[Intent Result](https://developer.apple.com/documentation/appintents/intentresult)** - Understanding intent return values

### Siri Integration
- **[Making App Intents Available to Siri](https://developer.apple.com/documentation/appintents/making-app-intents-available-to-siri)** - Core Siri integration guide
- **[App Shortcuts](https://developer.apple.com/documentation/appintents/appshortcut)** - AppShortcut protocol documentation
- **[App Shortcuts Provider](https://developer.apple.com/documentation/appintents/appshortcutsprovider)** - Managing app shortcuts
- **[Shortcuts App Integration](https://developer.apple.com/documentation/appintents/making-your-app-available-with-app-intents)** - Shortcuts app integration

### Parameters and Data Types
- **[App Intent Parameter](https://developer.apple.com/documentation/appintents/appintent/parameter/)** - Parameter protocol documentation
- **[Intent Parameter](https://developer.apple.com/documentation/appintents/intentparameter)** - Intent parameter wrapper
- **[App Entity](https://developer.apple.com/documentation/appintents/appentity)** - Custom entity parameters
- **[Parameter Summary](https://developer.apple.com/documentation/appintents/parametersummary)** - Parameter display configuration

### Intent Donation and Learning
- **[Making App Intents Available to Siri](https://developer.apple.com/documentation/appintents/making-app-intents-available-to-siri)** - Core donation and prediction guide
- **[App Intents and User Activity](https://developer.apple.com/documentation/appintents/making-your-app-available-with-app-intents)** - Integration patterns
- **[Siri Tips and Suggestions](https://developer.apple.com/documentation/sirikit/donating_shortcuts_to_siri)** - Improving suggestions and learning

### Navigation and App Opening
- **[Opening Your App](https://developer.apple.com/documentation/appintents/making-app-intents-available-to-siri#Open-your-app-through-an-app-intent)** - App opening patterns
- **[Opens Intent Protocol](https://developer.apple.com/documentation/appintents/opensintent)** - Protocol for opening apps
- **[App Intent Execution](https://developer.apple.com/documentation/appintents/making-your-app-available-with-app-intents)** - Managing app state during intent execution

### Authentication and Security
- **[Intent Authentication](https://developer.apple.com/documentation/appintents/making-app-intents-available-to-siri#Require-authentication-for-an-app-intent)** - Securing your intents
- **[Authentication Policy](https://developer.apple.com/documentation/appintents/intentauthenticationpolicy)** - Authentication policy options
- **[App Intents Privacy](https://developer.apple.com/documentation/appintents/making-your-app-available-with-app-intents#Privacy-considerations)** - Privacy best practices

### Advanced Topics
- **[Interactive Widgets](https://developer.apple.com/documentation/widgetkit/making-a-configurable-widget)** - Widget integration with App Intents
- **[App Extensions](https://developer.apple.com/documentation/appintents/making-your-app-available-with-app-intents#App-extensions)** - Extension-based intents
- **[Intent Phrases](https://developer.apple.com/documentation/appintents/making-app-intents-available-to-siri#Use-phrases-to-customize-what-users-can-say)** - Custom phrases and recognition
- **[App Intents Testing](https://developer.apple.com/documentation/appintents/making-your-app-available-with-app-intents#Testing-your-app-intent)** - Testing and debugging

### WWDC Sessions
- **[WWDC 2022: Dive into App Intents](https://developer.apple.com/videos/play/wwdc2022/10032/)** - Introduction to App Intents
- **[WWDC 2022: Implement App Shortcuts with App Intents](https://developer.apple.com/videos/play/wwdc2022/10170/)** - Practical implementation
- **[WWDC 2023: Explore enhancements to App Intents](https://developer.apple.com/videos/play/wwdc2023/10103/)** - Latest features and improvements

### Design Guidelines
- **[Human Interface Guidelines: Siri](https://developer.apple.com/design/human-interface-guidelines/technologies/siri/)** - Designing for Siri interactions
- **[App Shortcuts Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-shortcuts)** - User experience patterns for shortcuts
- **[Accessibility in Siri](https://developer.apple.com/design/human-interface-guidelines/accessibility)** - Inclusive voice interface design

## Contributing

This package is an independent Flutter plugin for Apple App Intents integration.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.