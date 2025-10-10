---
sidebar_position: 2
---

# Getting Started

## Installation

### Flutter Plugin (Recommended)

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_app_intents: ^0.8.0
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

### iOS
- iOS 16.0 or later
- Xcode 14.0 or later

### Android
- Android API 23+ (Android 6.0 or later)
- Android Studio (recommended for testing)

### General
- Flutter 3.8.1 or later

## Platform Support

This package provides full voice assistant integration for **iOS** and **Android**:

- ✅ **iOS 16.0+**: Complete App Intents support with Siri voice commands and Shortcuts app integration
- ✅ **Android API 23+**: Full App Actions support with Google Assistant voice commands

The package also compiles and runs on **macOS**, **Windows**, and **Linux**, with graceful degradation:
- ✅ **UI functionality**: All user interface elements work normally
- ✅ **Business logic**: Your app's core functionality remains intact
- ❌ **Voice commands**: App Intents/App Actions are disabled (not supported by these platforms)
- ℹ️ **Status indication**: Apps display `"App Intents disabled - unsupported platform (macOS)"` (or the respective platform name)

**Use case for desktop platforms**: This allows developers to test UI and business logic on desktop platforms during development, even though voice assistant integration won't be available. For example, you can develop and debug your app's navigation logic on macOS before testing the full voice command integration on iOS.

## Architecture Overview

This plugin uses a **hybrid approach** combining:

1. **Static platform intents** (Swift for iOS, XML for Android) - Required for voice assistant discovery
2. **Dynamic Flutter handlers** registered through the plugin (your business logic)

### iOS Architecture
```
iOS Shortcuts/Siri → Static Swift Intent → Flutter Plugin Bridge → Your Flutter Handler
```

### Android Architecture
```
Google Assistant → shortcuts.xml → Flutter Plugin Bridge → Your Flutter Handler
```

The static platform intents act as a bridge, calling your Flutter handlers when executed.

## Code Generation (Recommended)

**NEW in v0.8.0**: Automatically generate platform-specific code from your Dart intent definitions!

The easiest way to set up App Intents is using our code generator:

```bash
# Generate platform code from your Dart intents
dart run flutter_app_intents:app_intents_cli
```

**Optional: Install globally for convenience**
```bash
# Install once
dart pub global activate flutter_app_intents

# Then run from anywhere
app_intents_cli
```

This creates:
- **iOS**: `ios/Runner/AppShortcuts.swift` - Complete Swift App Intents implementation
- **Android**: `android/app/src/main/res/xml/shortcuts.xml` - Google Assistant integration

### Benefits

- ✅ **No manual Swift/XML coding** - Generate from Dart
- ✅ **Type-safe** - Compile-time validation
- ✅ **Consistent** - Single source of truth
- ✅ **Fast iteration** - Watch mode for instant updates
- ✅ **Error prevention** - Validates intent definitions

### Generator Options

```bash
# Auto-detect platforms (default)
dart run flutter_app_intents:app_intents_cli

# Specific platform
dart run flutter_app_intents:app_intents_cli --platform=ios
dart run flutter_app_intents:app_intents_cli --platform=android,ios

# Watch mode (regenerate on file changes)
dart run flutter_app_intents:app_intents_cli --watch
```

## Quick Start

### 1. Import the package

```dart
import 'package:flutter_app_intents/flutter_app_intents.dart';
```

### 2. Define and register your intents

Create intents using `AppIntentBuilder` and register them with handlers:

```dart
final incrementIntent = AppIntentBuilder()
    .identifier('increment_counter')
    .title('Increment Counter')
    .description('Increments the counter by one')
    .category(IntentCategory.general)  // Required for code generation
    .build();

await client.registerIntent(incrementIntent, (parameters) async {
  // Your business logic here
  incrementCounter();
  return AppIntentResult.successful(value: 'Counter incremented!');
});
```

### 3. Generate platform code (Recommended)

Run the code generator to create platform-specific files:

```bash
dart run flutter_app_intents:app_intents_cli
```

Then add the generated `AppShortcuts.swift` file to your Xcode project:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Right-click on Runner → "Add Files to Runner"
3. Select `ios/Runner/AppShortcuts.swift`
4. Check "Copy items if needed" and "Runner" target

> **Alternative**: You can manually write Swift intents - see [iOS Configuration](../ios-configuration)

### 4. Test with Siri

Build and run your app:

```bash
flutter run
```

Then test your intent:
1. Open iOS Shortcuts app
2. Find your app's shortcuts
3. Enable Siri (toggle the switch - it's OFF by default)
4. Say "Hey Siri, increment counter with [Your App Name]"

**Result:** Your Flutter handler executes and Siri responds! 🎉

### 5. Test with Google Assistant (Android)

Build and run your app on an Android device:

```bash
flutter run
```

Then test your intent with Google Assistant:

**Method 1: Voice Commands**
1. Ensure your Android device has Google Assistant enabled
2. Say "Hey Google, [action] with [Your App Name]"
   - Example: "Hey Google, increment counter with My App"
   - The exact phrasing depends on your intent's category and BII mapping

**Method 2: ADB Testing**
You can test without voice using ADB commands:

```bash
# Test a specific action
adb shell am start -a android.intent.action.VIEW \
  -d "yourapp://action_name"

# Or test via Google Assistant Test Tool (if installed)
adb shell am start -a com.google.android.voiceinteraction.testapp.START_TEST
```

**Method 3: Google Assistant Plugin (Android Studio)**
1. Install "Google Assistant" plugin in Android Studio
2. Tools → App Actions Test Tool
3. Select your app and test shortcuts directly

**Troubleshooting:**
- If Google Assistant doesn't recognize your command, check the BII mapping in [Android Configuration](../android-configuration)
- Ensure `shortcuts.xml` was generated correctly
- Try rebuilding your app: `flutter clean && flutter run`
- Check logcat for errors: `adb logcat | grep flutter_app_intents`

**Result:** Your Flutter handler executes and Google Assistant responds! 🎉

## Next Steps

- Explore complete [Examples](/flutter_app_intents/docs/examples) with Counter, Navigation, and Weather apps
- Follow our [Step-by-Step Tutorial](../tutorial) for a complete walkthrough
- Learn about [Navigation with App Intents](../navigation)
- Explore [Enhanced Intent Donation](../intent-donation)
- Check out the [API Reference](../api-reference)
