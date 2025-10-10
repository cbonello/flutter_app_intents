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

1. **Static Swift/XML App Intents** (generated or manual) - Required for platform discovery
2. **Flutter handlers** (`lib/main.dart`) - Your app's business logic
3. **Bridge communication** - Static intents call Flutter handlers via the plugin

## Code Generation

**✨ NEW in v0.8.0**: All examples now support automatic code generation!

Instead of manually writing platform-specific code, the examples use the code generator:

```bash
# From any example directory
cd example/counter  # or navigation, or weather

# Generate platform code
dart run flutter_app_intents:app_intents_cli
```

This automatically creates:
- **iOS**: `ios/Runner/AppShortcuts.swift` with complete App Intents implementation
- **Android**: `android/app/src/main/res/xml/shortcuts.xml` for Google Assistant

### Using the Examples with Code Generation

1. **Navigate to an example**:
```bash
cd example/counter
```

2. **Install dependencies**:
```bash
flutter pub get
```

3. **Generate platform code**:
```bash
dart run flutter_app_intents:app_intents_cli
```

4. **Add iOS file to Xcode** (iOS only):
   - Open `ios/Runner.xcworkspace` in Xcode
   - Right-click on Runner → "Add Files to Runner"
   - Select `ios/Runner/AppShortcuts.swift`
   - Check "Copy items if needed" and "Runner" target

5. **Run the example**:
```bash
flutter run
```

### Regenerating After Changes

If you modify intent definitions in any example's `lib/main.dart`, regenerate the platform code:

```bash
# Auto-regenerate (recommended for development)
dart run flutter_app_intents:app_intents_cli --watch

# Or manually
dart run flutter_app_intents:app_intents_cli
```

**Then hot restart your app (press `R` in Flutter terminal).**

> **⚠️ Why Hot Restart, Not Hot Reload?**
>
> - **Hot reload** (`r`) only updates Dart code changes - it's fast but limited to Flutter framework
> - **Hot restart** (`R`) restarts the entire app including native platform code
>
> The generated files (`AppShortcuts.swift` for iOS, `shortcuts.xml` for Android) are **native platform resources**, not Dart code. They require a full app restart to be loaded by the operating system.
>
> **What happens if you only hot reload:**
> - ❌ iOS: Siri won't see the updated intent definitions
> - ❌ Android: Google Assistant won't recognize new shortcuts
> - ❌ Your changes won't take effect until full restart
>
> **Remember:** Press `R` (capital R) after regenerating platform files!

## Quick Start

### Prerequisites

**iOS:**
- iOS 16.0 or later device or simulator
- Xcode 14.0 or later

**Android:**
- Android API 23+ (Android 6.0 or later)
- Android device or emulator with Google Assistant
- Android Studio (recommended)

**General:**
- Flutter 3.8.1 or later

### Platform Support

All three examples (Counter, Navigation, Weather) are fully functional on **iOS** and **Android** with complete voice assistant integration.

The examples also compile and run on **macOS**, **Windows**, and **Linux**, but with limited functionality:
- ✅ **UI works**: You can use manual buttons to test all functionality
- ❌ **Voice commands disabled**: App Intents/App Actions are not available on these platforms
- ℹ️ **Status message**: Each example displays `"App Intents disabled - unsupported platform (macOS)"` (or the respective platform name)

**Development tip**: Use desktop platforms to quickly iterate on UI and business logic, then test voice command integration on iOS/Android devices.

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

**iOS (Siri):**
1. **Shortcuts App**: Check for your app's shortcuts under "App Shortcuts"
2. **Enable Siri**: ⚠️ **IMPORTANT** - In Shortcuts app, tap your app's shortcuts and toggle ON the Siri switch (it's OFF by default)
3. **Test Voice Commands**:
   - "Hey Siri, [action] with [Your App Name]"
   - Example: "Hey Siri, increment counter with Counter Example"
4. **Settings**: Go to Settings → Siri & Search → App Shortcuts

**Android (Google Assistant):**
1. **Voice Commands**: Say "Hey Google, [action] with [Your App Name]"
   - Example: "Hey Google, increment counter with My App"
2. **ADB Testing**: Use `adb shell am start` commands for testing without voice
3. **Google Assistant Plugin**: Use Android Studio's App Actions Test Tool
4. **Logcat**: Check logs with `adb logcat | grep flutter_app_intents`

**Manual Testing (Both Platforms):**
- Use in-app buttons to test functionality without voice commands

## Common Troubleshooting

### iOS Issues

**Shortcuts not appearing?**
1. Ensure iOS 16.0+ device/simulator
2. Verify `AppShortcuts.swift` was added to Xcode project
3. Wait for iOS to register static intents (can take a minute)
4. Check console logs for registration status
5. Try restarting the Shortcuts app

**Siri not recognizing commands?**
1. **Enable Siri toggle first**: In Shortcuts app → [Your App] Shortcuts → Toggle ON the Siri switch (⚠️ **OFF by default**)
2. Use exact app name in voice commands
3. Try manual shortcuts first to help Siri learn
4. Add custom phrases in Settings → Siri & Search

### Android Issues

**Google Assistant not recognizing commands?**
1. Ensure `shortcuts.xml` was generated in `android/app/src/main/res/xml/`
2. Check BII mapping matches your intent category
3. Use correct phrasing for your BII type (see [Android Configuration](/flutter_app_intents/docs/android-configuration))
4. Clear Google app data: Settings → Apps → Google → Storage → Clear Cache
5. Rebuild your app: `flutter clean && flutter run`

**Hot reload not updating shortcuts?**
- Use **hot restart** (press `R` in terminal) after regenerating platform files
- Android: XML resources require full restart
- iOS: Swift files require full rebuild

**Testing without devices?**
- iOS: Use iOS Simulator (iOS 16.0+ required)
- Android: Use emulator with Google Play Services installed

For detailed troubleshooting, see the [Troubleshooting](/flutter_app_intents/docs/troubleshooting) section.

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