# Flutter App Intents Examples

This folder contains two complete example applications demonstrating different use cases for the `flutter_app_intents` package with Apple App Intents, enabling features like Siri voice commands, Shortcuts, and Spotlight search.

## Examples Overview

### 1. [Counter Example](./counter/)
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

### 2. [Navigation Example](./navigation/)
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

## Choosing the Right Example

| Use Case | Example | Intent Type | Return Type |
|----------|---------|-------------|-------------|
| Perform app actions | Counter | Action Intent | `ReturnsValue<String>` |
| Navigate to app pages | Navigation | Navigation Intent | `OpensIntent` |
| Background operations | Counter | Action Intent | `ReturnsValue<String>` |
| Deep linking | Navigation | Navigation Intent | `OpensIntent` |

## Architecture

Both examples demonstrate the **hybrid approach** required for Flutter App Intents:

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
cd counter
flutter pub get
flutter run
```

**Navigation Example (Deep Linking):**
```bash
cd navigation
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

For detailed troubleshooting, see the main [README](../README.md).

## Implementation Guide

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

## Next Steps

1. **Start with Counter** - Learn basic App Intents concepts
2. **Try Navigation** - Understand deep linking and navigation patterns
3. **Combine Both** - Create apps with mixed intent types
4. **Customize** - Add your own intents and parameters

Both examples include comprehensive documentation and are production-ready starting points for your own App Intents implementation.