---
sidebar_position: 3
---

# Examples

This section provides three complete example applications demonstrating different use cases for the `flutter_app_intents` package with Apple App Intents, enabling features like Siri voice commands, Shortcuts, and Spotlight search.

## Examples Overview

### 1. [Counter Example](https://github.com/christophebonello/flutter_app_intents/tree/main/example/counter)
**Action-based App Intents** - Demonstrates intents that perform operations without navigation.

**Features:**
- Increment counter (with optional amount parameter)
- Reset counter to zero
- Get current counter value
- Intent donation for Siri learning
- Parameter handling and validation

**Best for learning:**
- Basic App Intents implementation
- Parameter handling
- Action-based voice commands
- iOS static intent declarations

### 2. [Navigation Example](https://github.com/christophebonello/flutter_app_intents/tree/main/example/navigation)
**Navigation-based App Intents** - Demonstrates deep linking and app navigation through intents.

**Features:**
- Open user profile page
- Launch chat with specific contact
- Navigate to search with query
- Open app settings
- Deep linking with route parameters

**Best for learning:**
- Navigation intents with `OpensIntent`
- Deep linking with parameters
- Multi-page Flutter navigation
- Route configuration and argument passing

### 3. [Weather Example](https://github.com/christophebonello/flutter_app_intents/tree/main/example/weather)
**Query-based App Intents** - Demonstrates background data queries with voice responses.

**Features:**
- Get current weather information
- Check specific temperature data
- Retrieve multi-day forecasts
- Boolean rain checks
- Background operation without opening app

**Best for learning:**
- Query intents with `ProvidesDialog`
- Background data processing
- Voice response formatting
- Multiple parameter types
- Information retrieval patterns

## Choosing the Right Example

| Use Case | Example | Intent Type | Return Type |
|----------|---------|-------------|-------------|
| Perform app actions | Counter | Action Intent | `ReturnsValue<String>` |
| Navigate to app pages | Navigation | Navigation Intent | `OpensIntent` |
| Query data with voice | Weather | Query Intent | `ProvidesDialog` |
| Background operations | Weather | Query Intent | `ProvidesDialog` |
| Deep linking | Navigation | Navigation Intent | `OpensIntent` |

## Architecture

All examples demonstrate the **hybrid approach** required for Flutter App Intents:

1. **Static Swift App Intents** (`ios/Runner/AppDelegate.swift`) - Required for iOS discovery
2. **Flutter handlers** (`lib/main.dart`) - Your app's business logic
3. **Bridge communication** - Static intents call Flutter handlers via the plugin

## Quick Start

### Prerequisites
- Flutter environment with iOS development setup
- **iOS 16.0 or later** device or simulator
- Xcode 14.0 or later

### Running the Examples

**Counter Example (Action Intents):**
```bash
cd example/counter
flutter pub get
flutter run
```

**Navigation Example (Deep Linking):**
```bash
cd example/navigation
flutter pub get
flutter run
```

**Weather Example (Query Intents):**
```bash
cd example/weather
flutter pub get
flutter run
```

### Testing App Intents

1. **Shortcuts App**: Check for your app's shortcuts under "App Shortcuts"
2. **Siri Commands**: Use voice commands with your app name
3. **Settings**: Go to Settings > Siri & Search > App Shortcuts
4. **Manual Testing**: Use in-app buttons to test functionality

## Common Troubleshooting

**Shortcuts not appearing?**
1. Ensure iOS 16.0+ device/simulator
2. Wait for iOS to register static intents
3. Check console logs for registration status
4. Try restarting the Shortcuts app

**Siri not recognizing commands?**
1. Use exact app name in voice commands
2. Try manual shortcuts first to help Siri learn
3. Add custom phrases in Settings > Siri & Search

For detailed troubleshooting, see the [Troubleshooting](troubleshooting) section.

## Implementation Patterns

### For Action Intents (like Counter):
```dart
return AppIntentResult.successful(
  value: 'Action completed successfully',
  needsToContinueInApp: false, // Optional for actions
);
```

### For Navigation Intents (like Navigation):
```dart
return AppIntentResult.successful(
  value: 'Opening page...',
  needsToContinueInApp: true, // Required for navigation
);
```

### For Query Intents (like Weather):
```dart
return AppIntentResult.successful(
  value: 'Weather data: 72°F and sunny',
  needsToContinueInApp: false, // Background operation
);
```

## App Shortcuts Phrase Best Practices

### ⚠️ Important Limitation: Static Phrases Only
**App Shortcuts phrases CANNOT be defined dynamically.** They must be declared statically in your Swift code at compile time.

### Key Guidelines

1. **Phrase Quantity**: Include 3-5 phrase variations per intent
   - Provides users with natural alternatives
   - Helps Siri recognition accuracy
   - Accounts for different speech patterns

2. **Natural Language Patterns**:
   ```swift
   // Good: Uses natural prepositions and variations
   "Increment counter by \(amount) with \(.applicationName)"
   "Add \(amount) to counter using \(.applicationName)"
   "Increase counter in \(.applicationName)"
   
   // Avoid: Unnatural or overly complex phrasing
   "Execute increment functionality with parameter \(amount)"
   ```

3. **Application Name Integration**: Always include `\(.applicationName)` to:
   - Distinguish from other apps with similar intents
   - Improve Siri recognition accuracy
   - Follow iOS App Shortcuts conventions

4. **Parameter Placement**: Place parameters naturally within phrases:
   ```swift
   // Good: Natural parameter placement
   "Check weather in \(location) using \(.applicationName)"
   
   // Less ideal: Parameters at the end
   "Check weather using \(.applicationName) for \(location)"
   ```

### Testing Phrases
- Test each phrase variation with Siri
- Verify phrases work across different accents
- Check that parameters are correctly captured
- Use Settings > Siri & Search > App Shortcuts for manual testing

## Next Steps

1. **Start with Counter** - Learn basic App Intents concepts
2. **Try Navigation** - Understand deep linking and navigation patterns
3. **Explore Weather** - Master query intents and background operations
4. **Combine Patterns** - Create apps with mixed intent types
5. **Customize** - Add your own intents and parameters

All examples include comprehensive documentation and are production-ready starting points for your own App Intents implementation.