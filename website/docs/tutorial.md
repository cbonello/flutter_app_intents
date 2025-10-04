---
sidebar_position: 2
---

# Tutorial

This tutorial will guide you through the process of setting up and using the Flutter App Intents plugin.

## 1. iOS Project Setup

First, you need to configure your iOS project to support App Intents.

1.  Open your iOS project in Xcode (`ios/Runner.xcworkspace`).
2.  Select the "Runner" target and go to the "Signing & Capabilities" tab.
3.  Click "+ Capability" and add "App Intents".

## 2. Define an App Intent

Create a new Swift file in your Xcode project (e.g., `MyAppIntents.swift`) and define your intent.

```swift
import AppIntents
import flutter_app_intents

struct SayHelloIntent: AppIntent {
    static var title: LocalizedStringResource = "Say Hello"
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Name")
    var name: String

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "SayHelloIntent",
            parameters: ["name": name]
        )

        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Hello, \(name)!"
            return .result(value: value)
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to say hello"
            throw NSError(domain: "SayHelloIntent", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
    }
}

// Define App Shortcuts to enable Siri voice commands
struct MyAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SayHelloIntent(),
            phrases: [
                "Say hello to \(\.$name)",
                "Greet \(\.$name)"
            ],
            shortTitle: "Say Hello",
            systemImageName: "hand.wave"
        )
    }
}
```

## 3. Register the Intent in Dart

In your Dart code, create an `AppIntent` using the builder pattern and register it with a handler.

```dart
import 'package:flutter_app_intents/flutter_app_intents.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get the client instance
  final client = FlutterAppIntentsClient.instance;

  // Build and register the intent with its handler
  final sayHelloIntent = AppIntentBuilder()
      .identifier('SayHelloIntent')
      .title('Say Hello')
      .description('Greet someone by name')
      .parameter(AppIntentParameter(
        name: 'name',
        title: 'Name',
        type: AppIntentParameterType.string,
      ))
      .build();

  await client.registerIntent(sayHelloIntent, (parameters) async {
    final name = parameters['name'] as String;
    // Show a dialog, navigate, or perform any other action
    print('Hello, $name!');
    return AppIntentResult.successful(value: 'Greeted $name');
  });

  runApp(MyApp());
}
```

That's it! You can now run your app and test your new Siri integration.

## Testing Your App Intent

### Step 1: Check Shortcuts App
Look for your app's shortcuts under "App Shortcuts" in the iOS Shortcuts app.

### Step 2: Enable Siri (CRITICAL STEP)
⚠️ **MOST IMPORTANT STEP** - Siri integration is **disabled by default**:

#### Visual Step-by-Step Guide:

**1. Open iOS Shortcuts app and tap "Counter Example >":**

<img src="/flutter_app_intents/img/siri-enable-step1.png" alt="Shortcuts app - tap Counter Example" width="300" />

In the iOS Shortcuts app, find your app under "All Shortcuts" and **tap "Counter Example >"** to access your app's shortcuts.

**2. Tap the info icon:**

<img src="/flutter_app_intents/img/siri-enable-step2.png" alt="Counter Example shortcuts page - tap info icon" width="300" />

You'll see the individual shortcuts for your app (Increment, Reset, Get Counter). **Tap the info icon (ⓘ)** in the top-right corner.

**3. Enable Siri for all shortcuts:**

<img src="/flutter_app_intents/img/siri-enable-step3.png" alt="Siri toggle enabled for the app" width="300" />

- **Toggle ON the Siri switch** (it's OFF by default)  
- Make sure the toggle is **green** as shown above
- This enables Siri for **all shortcuts** in your app at once

**Without this step, voice commands will NOT work!**

> **Why this happens**: Apple disables Siri for new App Shortcuts by default for privacy reasons. Users must explicitly enable voice access for each app's shortcuts.

### Step 3: Test with Siri
Try saying **"Say hello to John"** or **"Greet Alice"** to test your intent. If Siri doesn't respond, double-check that you enabled the Siri toggle in Step 2.

### Step 4: Troubleshooting
If voice commands still don't work after enabling Siri:
- Restart the Shortcuts app completely
- Try saying the exact phrase shown in the Shortcuts app
- Check the [Troubleshooting](/flutter_app_intents/docs/troubleshooting) guide for more solutions
