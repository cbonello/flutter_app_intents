# Counter App Intents Example

This example demonstrates **action-based App Intents** using a simple counter application. It shows how to execute specific app functions through Siri voice commands and iOS shortcuts.

## Features Demonstrated

### Intent Types

This example demonstrates both **action** and **query** intents:

**Action Intents** (silent - just open the app):
- **Increment Counter**: Add to the counter value (with optional amount parameter)
- **Reset Counter**: Set counter back to zero

**Query Intents** (show result in dialog):
- **Get Counter**: Query current counter value and display it

### Key Concepts
- Parameter handling with type safety
- Intent donation for Siri learning
- Error handling and validation
- Action-based voice commands

## Architecture

This example uses the **hybrid approach** with:

1. **Static Swift App Intents** (`ios/Runner/AppDelegate.swift`)
2. **Flutter handlers** (`lib/main.dart`) 
3. **Bridge communication** via the plugin

## Screenshots

| App Interface | iOS Shortcuts |
|---------------|---------------|
| <img src="screenshots/app_interface.png" alt="Counter App Interface" width="250"> | <img src="screenshots/ios_shortcuts.png" alt="iOS Shortcuts" width="250"> |
| Counter app | iOS Shortcuts app |

## Quick Start

### Prerequisites
- iOS 16.0+ device or simulator
- Flutter 3.8.1+
- Xcode 14.0+

### Run the Example

```bash
cd counter
flutter pub get
flutter run
```

### Test the App Intents

1. **Manual Testing**: Use the floating action button to increment the counter

2. **iOS Shortcuts**: Check the Shortcuts app for available actions

3. **Enable Siri**: ⚠️ **IMPORTANT** - In Shortcuts app, tap "Counter Example Shortcuts" and toggle ON the Siri switch (it's OFF by default)

4. **Siri Commands**:
   - "Increment counter with Counter Example"
   - "Reset counter with Counter Example"
   - "Get counter from Counter Example"

5. **Settings**: Go to Settings > Siri & Search > App Shortcuts

## Code Generation

**✨ NEW**: This example uses the code generator to automatically create iOS static intents from Dart definitions.

### How It Works

1. **Dart Intent Definitions** (`lib/main.dart`):
```dart
// Action intent - opens app silently
final incrementIntent = AppIntentBuilder()
    .identifier('increment_counter')
    .title('Increment Counter')
    .description('Increments the counter by one')
    .category(IntentCategory.general)
    .build();  // presentsResult defaults to false

// Query intent - shows result in dialog
final getCounterIntent = AppIntentBuilder()
    .identifier('get_counter')
    .title('Get Counter Value')
    .description('Returns the current counter value')
    .category(IntentCategory.general)
    .presentsResult(true)  // ← Shows result to user
    .build();
```

2. **Generate Platform Code**:
```bash
dart run flutter_app_intents:app_intents_cli
```

3. **Generated Output** (`ios/Runner/AppShortcuts.swift`):
- Swift AppIntent structs for each intent
- AppShortcutsProvider with Siri phrases
- Automatic bridging to Flutter handlers

4. **Add to Xcode** (one-time step):
   - Open `ios/Runner.xcworkspace` in Xcode
   - Right-click "Runner" folder → "Add Files to Runner..."
   - Select `ios/Runner/AppShortcuts.swift`
   - Check "Copy items if needed" and "Runner" target
   - Click "Add"

**Note**: This is only needed once. Regenerating the file later will update it automatically.

### Regenerate After Changes

If you modify the intent definitions in Dart, regenerate the Swift code:

```bash
# Auto-detect platforms
dart run flutter_app_intents:app_intents_cli

# iOS only
dart run flutter_app_intents:app_intents_cli --platform=ios

# Watch mode (regenerate on file changes)
dart run flutter_app_intents:app_intents_cli --watch
```

**Then hot restart your app (press `R` in Flutter terminal).**

> **⚠️ Why Hot Restart, Not Hot Reload?**
>
> - **Hot reload** (`r`) only updates Dart code - it's fast but limited to Flutter framework
> - **Hot restart** (`R`) restarts the entire app including native platform code
>
> `AppShortcuts.swift` is a **native iOS Swift file**, not Dart code. iOS loads these files when the app starts, so changes require a full app restart to be recognized by Siri.
>
> **What happens if you only hot reload:**
> - ❌ Siri won't see the updated intent definitions
> - ❌ Changes to phrases won't take effect
> - ❌ New intents won't appear in Shortcuts app
> - ✅ Only a hot restart will reload the native iOS code
>
> **Remember:** Press `R` (capital R) after regenerating!

## Implementation Details

### Generated Swift Intents

The code generator creates static intents in `ios/Runner/AppShortcuts.swift`:

```swift
struct CounterIntent: AppIntent {
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
```

### Flutter Handlers  

The Flutter side handles the business logic:

```dart
Future<AppIntentResult> _handleIncrementIntent(Map<String, dynamic> parameters) async {
  final amount = parameters['amount'] as int? ?? 1;
  
  setState(() => _counter += amount);
  
  // Donate intent for Siri learning
  await _client.donateIntent('increment_counter', parameters);
  
  return AppIntentResult.successful(
    value: 'Counter incremented by $amount. New value: $_counter',
  );
}
```

### App Shortcuts Provider

The static shortcuts are declared with an `AppShortcutsProvider`:

```swift
struct CounterAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CounterIntent(),
            phrases: [
                "Increment counter with \(.applicationName)",
                "Add one with \(.applicationName)",
                "Count up using \(.applicationName)"
            ],
            shortTitle: "Increment",
            systemImageName: "plus.circle"
        )
        // ... other shortcuts
    }
}
```

## What You'll Learn

- ✅ How to create action-based App Intents
- ✅ Parameter handling and type safety  
- ✅ Static intent declarations for iOS discovery
- ✅ AppShortcutsProvider for Siri phrase registration
- ✅ Flutter-iOS bridge communication
- ✅ Intent donation for Siri learning
- ✅ Error handling between iOS and Flutter
- ✅ Testing with Siri and Shortcuts app

## Next Steps

Check out the [navigation example](../navigation/) to see how App Intents can handle app navigation and deep linking.