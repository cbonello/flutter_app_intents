# Counter App Intents Example

This example demonstrates **action-based App Intents** using a simple counter application. It shows how to execute specific app functions through Siri voice commands and iOS shortcuts.

## Features Demonstrated

### Action Intents
- **Increment Counter**: Add to the counter value (with optional amount parameter)
- **Reset Counter**: Set counter back to zero
- **Get Counter**: Query current counter value

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

2. **Siri Commands**:
   - "Increment counter with Counter Example"
   - "Reset counter with Counter Example"
   - "Get counter from Counter Example"

3. **iOS Shortcuts**: Check the Shortcuts app for available actions

4. **Settings**: Go to Settings > Siri & Search > App Shortcuts

## Implementation Details

### Static Swift Intents

The iOS side defines static intents in `AppDelegate.swift`:

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