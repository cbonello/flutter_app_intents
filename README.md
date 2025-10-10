# Flutter App Intents

[![pub version](https://img.shields.io/pub/v/flutter_app_intents.svg)](https://pub.dev/packages/flutter_app_intents)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![documentation](https://img.shields.io/badge/documentation-brightgreen.svg)](https://cbonello.github.io/flutter_app_intents/)

<p align="center">
  <img src="assets/logo.png" alt="Flutter App Intents Logo" width="200" height="200">
</p>

A Flutter plugin for integrating App Intents on iOS and Android. Enable your Flutter app to work seamlessly with Siri, Shortcuts, Spotlight on iOS, and Google Assistant on Android. Support both platforms with a unified Dart API.

> **📝 Note on Naming:** This package is called `flutter_app_intents` because it was originally designed for iOS App Intents. Since version 0.8.0, it supports both iOS (App Intents/Siri) and Android (App Actions/Google Assistant) with a unified API.

## Features

- **Voice Assistant Integration**: Siri on iOS, Google Assistant on Android
- **Shortcuts Support**: iOS Shortcuts app and Android App Actions
- **Spotlight Integration**: Make your app's actions discoverable in iOS search
- **Visual Intelligence**: Support for visual search results (iOS 2025+)
- **Widgets and Controls**: Enhanced widget and control center integration
- **Cross-Platform**: Unified Dart API for both iOS and Android
- **Type-Safe API**: Strongly typed Dart API with comprehensive error handling
- **Intent Donation**: Help Siri learn user patterns for improved predictions and suggestions
- **Internationalization**: Multi-language support for widgets, shortcuts, and voice commands
- **Code Generation**: Automatically generate platform-specific code from Dart definitions

## Documentation

📖 **[Complete Documentation](https://cbonello.github.io/flutter_app_intents/)** - Visit our comprehensive documentation website with tutorials, examples, and API reference.

## Requirements

### iOS
- iOS 16.0 or later
- Xcode 14.0 or later

### Android
- Android 7.1 (API level 25) or higher
- Recommended: Android 10.0 (API level 29) or higher

### Flutter
- Flutter 3.8.1 or later

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_app_intents: ^0.8.0
```

### Swift Package Manager (Advanced)

For iOS developers who want to use the native Swift components directly, this package also supports Swift Package Manager:

```swift
// In Package.swift
dependencies: [
    .package(url: "https://github.com/cbonello/flutter_app_intents", from: "0.8.0")
]
```

Or add via Xcode: **File → Add Package Dependencies** → `https://github.com/cbonello/flutter_app_intents`

> **Note:** SPM support is provided for advanced use cases. Most Flutter developers should use the standard plugin installation above. See [SPM_README.md](SPM_README.md) for detailed SPM integration instructions.

## Quick Start

Create a voice-controlled counter app that works on both iOS and Android:

### Using Code Generation (Recommended)

```dart
// 1. Define your intent in Dart
final intent = AppIntentBuilder()
    .identifier('increment_counter')
    .title('Increment Counter')
    .description('Increments the counter by one')
    .category(IntentCategory.general)
    .build();

// 2. Register with a handler
final client = FlutterAppIntentsClient.instance;
await client.registerIntent(intent, (parameters) async {
  incrementCounter();
  return AppIntentResult.successful(value: 'Counter incremented!');
});
```

```bash
# 3. Generate platform code
dart run flutter_app_intents:app_intents_cli
```

✅ That's it! The generator creates platform-specific code automatically (iOS: Swift intents, Android: shortcuts.xml).

### Manual Setup (Alternative)

> **Note:** This shows manual iOS setup. Most developers should use the code generator above instead, which supports both iOS and Android.

If you prefer not to use the code generator, you can manually write the static intents:

```swift
// 1. Define your intent in Dart (same as above)
// 2. Add static intent to iOS (AppDelegate.swift)
import AppIntents

struct IncrementCounterIntent: AppIntent {
    static var title: LocalizedStringResource = "Increment Counter"

    func perform() async throws -> some IntentResult {
        await FlutterAppIntentsPlugin.shared.handleIntent("increment_counter", [:])
        return .result()
    }
}
```

**Test it:**
- **iOS**: *"Hey Siri, increment counter with MyApp"*
- **Android**: Use ADB (`adb shell am start -a android.intent.action.VIEW -d "app://intent/increment_counter"`) or *"Hey Google, open increment counter in MyApp"* (requires publishing)

## Architecture Overview

This plugin uses a **hybrid approach** combining platform-specific configuration with shared Flutter business logic:

### iOS Architecture

1. **Static Swift intents** in your main iOS app target (required for iOS discovery)
2. **Dynamic Flutter handlers** registered through the plugin (your business logic)

```
iOS Shortcuts/Siri → Static Swift Intent → Flutter Plugin Bridge → Your Flutter Handler
```

The static Swift intents act as a bridge, calling your Flutter handlers when executed.

### Android Architecture

1. **Static shortcuts.xml** configuration (defines Google Assistant integration)
2. **Deep link routing** via MainActivity (handles intent URIs)
3. **Dynamic Flutter handlers** registered through the plugin (your business logic)

```
Google Assistant → shortcuts.xml → Deep Link (app://intent/id) → MainActivity → Flutter Plugin Bridge → Your Flutter Handler
```

The shortcuts.xml file maps voice commands to deep links, which are routed to your Flutter handlers.

## Code Generation (Recommended)

**NEW in v0.8.0**: Automatically generate platform-specific code from your Dart intent definitions!

Instead of manually writing static intents, use our code generator to create them automatically:

```bash
# Generate platform code from your Dart intents
dart run flutter_app_intents:app_intents_cli

# Output:
# 🔍 Scanning lib/ for intent definitions...
# ✅ Found 3 intent(s) in 2 file(s)
# 📱 Processing platform: android
# 📝 Generated: android/app/src/main/res/xml/shortcuts.xml
# 📱 Processing platform: ios
# 📝 Generated: ios/Runner/AppShortcuts.swift
# ✅ Code generation complete!
```

### What Gets Generated?

**For Android:**
- `android/app/src/main/res/xml/shortcuts.xml` - Google Assistant integration and app launcher shortcuts
- `android/app/src/main/res/values/strings.xml` - Auto-generated widget string resources (merged with existing)
- **For query intents** (with `presentsResult: true`) - ⚠️ **Experimental**:
  - `android/app/src/main/res/layout/widget_{intent_id}.xml` - Widget layouts for result presentation
  - `android/app/src/main/res/xml/widget_{intent_id}_info.xml` - Widget metadata
  - `android/app/src/main/kotlin/{package}/{IntentId}WidgetProvider.kt` - Widget provider classes
  - **Note**: Requires manual AndroidManifest.xml registration and result passing implementation

**For iOS:**
- `ios/Runner/AppShortcuts.swift` - Siri shortcuts and App Intents with phrase definitions

### How It Works

1. **Define intents in Dart** using `AppIntentBuilder()`
2. **Run the generator** with `dart run flutter_app_intents:app_intents_cli`
3. **Add generated files to your project**:
   - **iOS**: Add `AppShortcuts.swift` to Xcode (right-click Runner → Add Files to Runner)
   - **Android**: Files are auto-placed in correct locations (no manual steps needed)
4. **Build and test** your app

### Installation Options

**Option 1: Run from your project (Recommended for most users)**
```bash
dart run flutter_app_intents:app_intents_cli
```

**Option 2: Install globally (Convenient for frequent use)**
```bash
# Install globally
dart pub global activate flutter_app_intents

# Then run from anywhere
app_intents_cli
```

After global installation, you can use `app_intents_cli` as a command from any directory.

### CLI Options Reference

| Option | Short | Description | Default |
|--------|-------|-------------|---------|
| `--platform=<platforms>` | `-p` | Target platform(s) for code generation. Comma-separated list: `ios`, `android`, or `ios,android` | Auto-detect from project structure |
| `--main-activity=<name>` | - | Android main activity class name (e.g., `MainActivity`, `SplashActivity`) | Auto-detect from `AndroidManifest.xml` |
| `--watch` | `-w` | Watch mode: automatically regenerate when `.dart` files in `lib/` change | Disabled |
| `--version` | `-v` | Show version information and exit | - |
| `--help` | `-h` | Show help message with usage information | - |

### Generator Usage Examples

```bash
# Auto-detect platforms (recommended)
dart run flutter_app_intents:app_intents_cli

# Generate for specific platform
dart run flutter_app_intents:app_intents_cli --platform=ios
dart run flutter_app_intents:app_intents_cli -p android

# Generate for both platforms explicitly
dart run flutter_app_intents:app_intents_cli --platform=ios,android

# Watch mode (regenerate on file changes)
dart run flutter_app_intents:app_intents_cli --watch
dart run flutter_app_intents:app_intents_cli -w

# Custom main activity (Android)
dart run flutter_app_intents:app_intents_cli --main-activity=SplashActivity

# Combine options
dart run flutter_app_intents:app_intents_cli --platform=android --watch --main-activity=SplashActivity

# Show version
dart run flutter_app_intents:app_intents_cli --version
dart run flutter_app_intents:app_intents_cli -v

# Show help
dart run flutter_app_intents:app_intents_cli --help
```

> **Note:** Replace `dart run flutter_app_intents:app_intents_cli` with `app_intents_cli` if using global installation.

### Benefits

- ✅ **No manual Swift/XML coding** - Generate from Dart
- ✅ **Type-safe** - Compile-time validation
- ✅ **Consistent** - Single source of truth
- ✅ **Fast iteration** - Watch mode for instant updates
- ✅ **Error prevention** - Validates intent definitions

> **Note:** You can still manually write static intents if you prefer. The generator is optional but strongly recommended for most use cases.

## Migration Guide

### New in v0.8.0: Action vs Query Intents

**✨ New Feature:** Use `.presentsResult()` to control how intents display results.

#### Intent Types

v0.8.0 introduces a clear distinction between two types of intents:

- **Action intents** (default): Open the app silently
  - **iOS**: No dialog shown
  - **Android**: Opens app immediately
- **Query intents** (`.presentsResult(true)`): Present results to user
  - **iOS**: Shows result string in a system dialog ✅ (text only, no rich content)
  - **Android**: Generates widget infrastructure (experimental) ⚠️

#### Usage Guide

**For Action Intents** (do something):
```dart
// Increment, Send, Create, Delete, Update operations
final actionIntent = AppIntentBuilder()
    .identifier('send_message')
    .title('Send Message')
    .build();  // presentsResult defaults to false

// Both platforms: Opens app immediately ✨
```

**For Query Intents** (get information):
```dart
// Get, Check, Fetch, Retrieve operations
final queryIntent = AppIntentBuilder()
    .identifier('get_status')
    .title('Get Status')
    .presentsResult(true)  // ← Platform-specific behavior
    .build();

// iOS: Shows result string in a system dialog, then opens app 📱 (text only)
// Android: Generates widgets for result display (experimental, requires manual setup) ⚠️
```

**Quick Rule of Thumb:**
- **GET/CHECK/FETCH operations** → Add `.presentsResult(true)`
- **DO/SEND/CREATE operations** → Leave as default (omit)

#### Why This Matters

The `.presentsResult()` property provides better UX by:
- Eliminating annoying dialogs for action intents
- Showing helpful text information for query intents (iOS: system dialog with string result)
- Making intent behavior explicit in your code

**Important Limitation (iOS)**: Query dialogs can only display plain text strings. For rich content (images, formatted text, custom UI), use action intents with `needsToContinueInApp: true` to open your app and display custom UI.

## Detailed Example

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

### 3. Handle intent execution

```dart
Future<AppIntentResult> handleIncrementIntent(Map<String, dynamic> parameters) async {
  try {
    final amount = parameters['amount'] as int? ?? 1;
    
    // Perform your app's logic
    final newValue = incrementCounter(amount);
    
    // Donate the intent to help Siri learn
    await FlutterAppIntentsClient.instance.donateIntentWithMetadata(
      'increment_counter',
      parameters,
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

Our plugin excels at handling app navigation through voice commands and shortcuts on both iOS and Android. Here's how to implement navigation intents:

### Navigation Intent Pattern

Navigation intents work on both platforms with the same Flutter code. The platform-specific part is just how the intent is invoked:

**Platform-Specific Invocation:**

- **iOS**: Use `OpensIntent` return type in Swift and `needsToContinueInApp: true` in Flutter
- **Android**: Use the same deep link scheme (`app://intent/<identifier>`), navigation happens automatically when the Flutter handler returns

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

**Android Setup:**

For Android, the code generator creates the shortcuts.xml entry automatically. No additional platform-specific code is needed - the deep link routing handles navigation intents the same as any other intent.

**Flutter Handler (Works for Both Platforms):**
```dart
Future<AppIntentResult> _handleOpenProfileIntent(
  Map<String, dynamic> parameters,
) async {
  final userId = parameters['userId'] as String? ?? 'current';

  // Navigate to the target page
  // This Flutter code works identically on both iOS and Android
  Navigator.of(context).pushNamed('/profile', arguments: {'userId': userId});

  return AppIntentResult.successful(
    value: 'Opening profile for user $userId',
    needsToContinueInApp: true, // iOS: focuses the app, Android: opens the app
  );
}
```

> **Note:** The Flutter navigation code is identical for both platforms. The difference is only in how the intent is invoked (Siri/Shortcuts on iOS, Google Assistant/deep links on Android).

### Common Navigation Patterns

All these Flutter patterns work identically on both iOS and Android:

#### 1. Deep Linking with Parameters
```dart
// Navigate to specific content with parameters
// Works on both iOS and Android
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
// Works on both iOS and Android
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
// Works on both iOS and Android
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

If you're using GoRouter, the pattern works the same on both platforms:

```dart
// Works on both iOS and Android
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

### Platform-Specific Configuration

#### iOS: AppShortcuts for Navigation

Add navigation shortcuts to your `AppShortcutsProvider` (or use the code generator):

```swift
@available(iOS 16.0, *)
struct AppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
            // Navigation shortcuts
            AppShortcut(
                intent: OpenProfileIntent(),
                phrases: [
                    "Open my profile in \(.applicationName)",
                    "Show profile using \(.applicationName)",
                    "Go to profile with \(.applicationName)"
                ]
            ),
            AppShortcut(
                intent: OpenChatIntent(),
                phrases: [
                    "Chat with \\(.contactName) using \(.applicationName)",
                    "Open chat with \\(.contactName) in \(.applicationName)",
                    "Message \\(.contactName) with \(.applicationName)"
                ]
            )
        ]
    }
}
```

#### Android: Testing Navigation Intents

Test navigation intents using ADB during development:

```bash
# Open profile page
adb shell am start -a android.intent.action.VIEW -d "app://intent/open_profile"

# Open chat with parameter
adb shell am start -a android.intent.action.VIEW -d "app://intent/open_chat?contactName=Alice"

# Open settings section
adb shell am start -a android.intent.action.VIEW -d "app://intent/open_settings?section=notifications"
```

**In Production:**
- Voice: *"Hey Google, open profile in MyApp"*
- Launcher: Long-press app icon → Tap navigation shortcut

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
- `donateIntentWithMetadata(String identifier, parameters, {double relevanceScore, Map<String, dynamic>? context, DateTime? timestamp})` - Intent donation for Siri learning (iOS-only, silently ignored on Android)
- `donateIntents(List<IntentDonation> donations)` - Batch intent donation for improved performance (iOS-only, silently ignored on Android)

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
    .category(IntentCategory.general)  // Semantic category for the intent
    .parameter(myParameter)
    .eligibleForSearch(true)
    .presentsResult(false)  // Action intent - opens app silently
    .authenticationPolicy(AuthenticationPolicy.requiresAuthentication)
    .build();
```

**Available Methods:**
- `.identifier(String)` - Unique identifier for the intent (required)
- `.title(String)` - Display name shown to users (required)
- `.description(String)` - Detailed description of what the intent does
- `.category(IntentCategory)` - Semantic category (maps to platform capabilities)
- `.parameter(AppIntentParameter)` - Add a parameter (can be called multiple times)
- `.eligibleForSearch(bool)` - Make discoverable in Spotlight/search (default: true)
- `.eligibleForPrediction(bool)` - Enable Siri predictions (default: true)
- `.presentsResult(bool)` - Show result dialog vs open app silently (default: false)
- `.authenticationPolicy(AuthenticationPolicy)` - Set authentication requirements
- `.build()` - Create the AppIntent instance

### IntentCategory

Semantic categories that map to platform-specific capabilities:

```dart
enum IntentCategory {
  general,        // Default fallback for any app feature
  fitness,        // Exercise and workout activities
  messaging,      // Messaging and communication
  calling,        // Phone calls
  music,          // Music playback
  video,          // Video playback
  notes,          // Note taking
  tasks,          // Task management
  calendar,       // Calendar events
  navigation,     // Navigation and directions
  taxi,           // Ride sharing
  ordering,       // Food ordering
  cart,           // Shopping cart operations
  deviceControl,  // Smart home control
  nutrition,      // Food tracking
  timer,          // Timer management
  alarm,          // Alarm management
  reminder,       // Reminders
  weather,        // Weather information
  news,           // News and articles
}
```

**Platform Mapping:**
- **Android**: Maps to Google Built-in Intents (BII) for better voice recognition
- **iOS**: Provides semantic meaning for Siri integration

**Example:**
```dart
// Messaging app
final intent = AppIntentBuilder()
    .identifier('send_message')
    .title('Send Message')
    .category(IntentCategory.messaging)  // Maps to Android messaging BII
    .build();

// Fitness app
final workoutIntent = AppIntentBuilder()
    .identifier('start_workout')
    .title('Start Workout')
    .category(IntentCategory.fitness)  // Maps to Android exercise BII
    .build();
```

### AppIntentParameterType

Parameter types supported by the plugin:

```dart
enum AppIntentParameterType {
  string,   // Text input
  integer,  // Whole numbers
  boolean,  // True/false values
  double,   // Decimal numbers
  date,     // Date/time values
  url,      // Web URLs
  file,     // File references
  entity,   // Custom app-specific types
}
```

### AuthenticationPolicy

Control when intents can be executed:

```dart
enum AuthenticationPolicy {
  none,                      // No authentication required
  requiresAuthentication,    // User must be authenticated
  requiresUnlockedDevice,    // Device must be unlocked
}
```

#### Action vs Query Intents

Use `.presentsResult()` to control how intents display results:

> **Platform Support:**
> ✅ **iOS**: Fully supported - shows result string in system dialog (text only) or opens app silently
> ⚠️ **Android**: Experimental widget-based support - generates widget infrastructure (requires manual AndroidManifest.xml setup and result passing implementation)

**Action Intents** (default behavior):
```dart
// Actions like "Increment Counter", "Send Message", "Create Note"
final actionIntent = AppIntentBuilder()
    .identifier('increment_counter')
    .title('Increment Counter')
    .description('Increments the counter by one')
    .presentsResult(false)  // or omit - false is default
    .build();

// Opens app immediately without showing a dialog ✨
```

**Query Intents** (show results):
```dart
// Queries like "Get Counter", "Check Weather", "Get Balance"
final queryIntent = AppIntentBuilder()
    .identifier('get_counter')
    .title('Get Counter Value')
    .description('Returns the current counter value')
    .presentsResult(true)  // ← Shows result string in dialog (iOS), generates widgets (Android - experimental)
    .build();

// iOS: Shows result string in a system dialog before opening app 📱 (text only)
// Android: Generates widget infrastructure (requires manual setup)
```

> **💡 UX Tip**: Use action intents (default) for operations that modify state, and query intents for operations that return information to the user. **Important**: iOS query dialogs can only display plain text strings - use action intents with `needsToContinueInApp: true` if you need to show rich content or custom UI in your app.

## Enhanced Intent Donation

The plugin provides advanced intent donation capabilities to help Siri learn user patterns and provide better predictions.

> **📱 Platform Support:** Intent donation is an **iOS-only** feature for Siri learning and predictions. On Android and other platforms, donation calls are **silently ignored** (no-op) and return `true`. This allows you to write cross-platform code without platform checks.

### Basic Intent Donation

```dart
// Donate intent for Siri learning (iOS-only, silently ignored on Android)
await FlutterAppIntentsClient.instance.donateIntentWithMetadata(
  'my_intent',
  {'param': 'value'},
);
```

### Batch Intent Donation

For improved performance when donating multiple intents, use the batch donation API:

```dart
// Create multiple intent donations with metadata
final donations = [
  IntentDonation.userInitiated(
    identifier: 'increment_counter',
    parameters: {'amount': 5},
  ),
  IntentDonation.userInitiated(
    identifier: 'reset_counter',
    parameters: {},
  ),
  IntentDonation.automated(
    identifier: 'check_counter',
    parameters: {},
    context: {'trigger': 'background_refresh'},
  ),
];

// Donate all intents in a single batch (more efficient than individual donations)
await FlutterAppIntentsClient.instance.donateIntents(donations);
```

**Advanced batch donation with custom metadata:**

```dart
// Create donations with full control over relevance, context, and timestamp
final donations = [
  IntentDonation(
    identifier: 'send_message',
    parameters: {'recipient': 'Alice', 'message': 'Hello'},
    relevanceScore: 0.9,  // High relevance - user-initiated
    context: {'source': 'quick_action', 'time_of_day': 'morning'},
    timestamp: DateTime.now(),
  ),
  IntentDonation(
    identifier: 'send_message',
    parameters: {'recipient': 'Bob', 'message': 'Hi'},
    relevanceScore: 0.9,
    context: {'source': 'quick_action', 'time_of_day': 'morning'},
    timestamp: DateTime.now(),
  ),
  IntentDonation(
    identifier: 'check_messages',
    parameters: {},
    relevanceScore: 0.5,  // Medium relevance - automated check
    context: {'trigger': 'app_launch'},
    timestamp: DateTime.now(),
  ),
];

await FlutterAppIntentsClient.instance.donateIntents(donations);
```

**Benefits of batch donation:**
- More efficient than multiple individual `donateIntentWithMetadata()` calls
- Reduced platform channel overhead
- Atomic processing on iOS for better performance
- Ideal for bulk imports, syncing, or processing queued actions

## Donation Best Practices

Donate intents after successful execution to help Siri learn user patterns:

```dart
// Execute the intent action
final result = await performAction();

// Donate if successful
// No Platform.isIOS check needed - silently ignored on Android
if (result.isSuccess) {
  await FlutterAppIntentsClient.instance.donateIntentWithMetadata(
    'my_intent',
    parameters,
  );
}
```

**When to donate:**
- After user successfully completes an action
- When an intent is invoked via Siri or Shortcuts
- For frequently-used features to improve predictions

**When not to donate:**
- After failed operations
- For background/automated tasks
- For one-time setup actions

## iOS Configuration

### Recommended: Use Code Generator

**✨ NEW in v0.8.0**: The easiest way to set up iOS App Intents is using the code generator:

```bash
# 1. Define intents in Dart with AppIntentBuilder
# 2. Run the generator
dart run flutter_app_intents:app_intents_cli --platform=ios

# 3. Add the generated file to Xcode:
#    - Open ios/Runner.xcworkspace in Xcode
#    - Right-click on Runner folder → "Add Files to Runner"
#    - Select ios/Runner/AppShortcuts.swift
#    - Check "Copy items if needed" and "Runner" target
#    - Click "Add"
```

The generator creates `ios/Runner/AppShortcuts.swift` with all the static intents automatically configured to call your Flutter handlers.

### Manual Setup (Alternative)

**⚠️ Note**: Manual setup is only needed if you're not using the code generator.

iOS App Intents framework requires static intent declarations in your main app target. Add this code to your iOS app's `AppDelegate.swift`:

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

## Testing

### iOS Testing

**Siri Voice Commands:**
```
"Hey Siri, increment counter with MyApp"
"Hey Siri, get counter value using MyApp"
```

**iOS Shortcuts App:**
1. Open Shortcuts app
2. Find your app's shortcuts
3. Tap to test

**Spotlight Search:**
- Type your intent names in Spotlight
- Shortcuts appear in search results

### Android Testing

**⭐ ADB Testing (Recommended for Development):**

ADB is the **standard way** to test Android App Actions during local development:

```bash
# Find adb location (usually in Android SDK platform-tools)
# macOS: ~/Library/Android/sdk/platform-tools/adb
# Linux: ~/Android/Sdk/platform-tools/adb
# Windows: %LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe

# Test an intent
adb shell am start -a android.intent.action.VIEW -d "app://intent/increment_counter"

# If app is running, you'll see a "Warning" message - this is NORMAL!
# The warning means the intent was successfully delivered to your running app.

# To test from a fresh start:
adb shell am force-stop com.example.your_app
adb shell am start -a android.intent.action.VIEW -d "app://intent/increment_counter"
```

**Why ADB for Android?**
- ✅ **Works immediately** - No publishing or special setup required
- ✅ **Fast iteration** - Test changes instantly during development
- ✅ **Same code paths** - Tests the exact same code as voice commands
- ✅ **Reliable** - No dependency on Google services

**Google Assistant Voice Commands (Production Only):**

⚠️ **Important:** Google Assistant voice commands **do NOT work for unpublished apps**.

Voice commands require:
- App published on Google Play (even internal testing track), OR
- Google Assistant Plugin for Android Studio

After publishing:
```
"Hey Google, open increment counter in MyApp"
"Hey Google, open reset counter in MyApp"
```

**App Launcher Shortcuts:**
- Long-press app icon in launcher
- Shortcuts appear in menu immediately
- No publishing required

📖 **[Complete Android Testing Guide](https://cbonello.github.io/flutter_app_intents/docs/android-configuration#testing-app-actions)** - Detailed testing instructions, Google Assistant Plugin setup, and troubleshooting.

## Internationalization

The package supports internationalization (i18n) with different levels of support for each platform:

### Android - Full Support ✅

Android has complete i18n support through standard Android localization:
- **Widget strings**: Automatically generated in `strings.xml`, add translations in locale-specific files (`values-es/`, `values-fr/`, etc.)
- **Shortcut labels**: Can be localized using string resources
- **How to use**: Create `values-{locale}/strings.xml` files with translated widget text

### iOS - Partial Support ⚠️

iOS has partial i18n support:
- **Intent titles**: Automatically support `LocalizedStringResource` and `.strings` files
- **Siri phrases**: Require manual translation setup in `Localizable.strings`
- **Limitation**: Phrases must be static; regenerating code requires re-applying translations

### Example: Adding Spanish Support

**Android** (`android/app/src/main/res/values-es/strings.xml`):
```xml
<resources>
    <string name="widget_get_weather_loading">Cargando el clima...</string>
    <string name="widget_get_weather_description">Obtener información del clima</string>
</resources>
```

**iOS** (`es.lproj/Localizable.strings`):
```
"intent.get_weather.phrase1" = "Obtener Clima con %@";
"intent.get_weather.phrase2" = "Obtener Clima en %@";
```

📖 **[Full Internationalization Guide](https://cbonello.github.io/flutter_app_intents/docs/internationalization)** - Complete guide with examples, best practices, and testing instructions.

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

### Intent Donation Errors

If intent donation fails, check:
- The intent identifier matches a registered intent
- Parameters match the intent's defined parameters
- The intent was successfully registered before donation

## Apple Documentation References

For deeper understanding of the underlying iOS concepts, refer to these official Apple resources:

### Core App Intents Framework
- **[App Intents Framework](https://developer.apple.com/documentation/appintents)** - Complete framework documentation
- **[App Intent Protocol](https://developer.apple.com/documentation/appintents/appintent)** - Core protocol documentation
- **[Intent Result](https://developer.apple.com/documentation/appintents/intentresult)** - Understanding intent return values

### Siri Integration
- **[Making Your App's Functionality Available to Siri](https://developer.apple.com/documentation/appintents/making-your-app-s-functionality-available-to-siri)** - Core Siri integration guide
- **[App Shortcuts](https://developer.apple.com/documentation/appintents/appshortcut)** - AppShortcut protocol documentation
- **[App Shortcuts Provider](https://developer.apple.com/documentation/appintents/appshortcutsprovider)** - Managing app shortcuts
- **[Shortcuts App Integration](https://developer.apple.com/documentation/appintents/making-your-app-available-with-app-intents)** - Shortcuts app integration

### Parameters and Data Types
- **[App Intent Parameter](https://developer.apple.com/documentation/appintents/appintent/parameter/)** - Parameter protocol documentation
- **[Intent Parameter](https://developer.apple.com/documentation/appintents/intentparameter)** - Intent parameter wrapper
- **[App Entity](https://developer.apple.com/documentation/appintents/appentity)** - Custom entity parameters
- **[Parameter Summary](https://developer.apple.com/documentation/appintents/parametersummary)** - Parameter display configuration

### Intent Donation and Learning
- **[Making Your App's Functionality Available to Siri](https://developer.apple.com/documentation/appintents/making-your-app-s-functionality-available-to-siri)** - Core donation and prediction guide
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
- **[Human Interface Guidelines: Siri](https://developer.apple.com/design/human-interface-guidelines/siri)** - Designing for Siri interactions
- **[App Shortcuts Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-shortcuts)** - User experience patterns for shortcuts
- **[Accessibility in Siri](https://developer.apple.com/design/human-interface-guidelines/accessibility)** - Inclusive voice interface design

## Contributing

This package is an independent Flutter plugin for Apple App Intents integration.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
