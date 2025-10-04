# Flutter App Intents Tutorial: Simple Counter with Siri Integration

> **Note:** This tutorial guides you through a simplified version of the counter example. For a more advanced implementation with multiple intents and parameter handling, please refer to the `example/counter` directory in this project.

This tutorial will guide you through creating a simple Flutter counter app that can be controlled by Siri voice commands using the `flutter_app_intents` plugin.

## Prerequisites

- Flutter SDK installed
- Xcode (for iOS development)
- iOS device or simulator running iOS 16.0+
- macOS for development

## Step 1: Create a New Flutter Project

```bash
flutter create counter_intents_tutorial
cd counter_intents_tutorial
```

## Step 2: Add the flutter_app_intents Dependency

Edit `pubspec.yaml` and add the dependency:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_app_intents: ^0.7.0  # Use the latest version
  cupertino_icons: ^1.0.8
```

Then run:

```bash
flutter pub get
```

## Step 3: Update iOS Deployment Target

The App Intents framework requires iOS 16.0+. Update the deployment target:

1. Open `ios/Podfile` and ensure the platform is set to iOS 16.0:

```ruby
platform :ios, '16.0'
```

2. Open `ios/Runner.xcodeproj/project.pbxproj` and update the deployment target:
   - Search for `IPHONEOS_DEPLOYMENT_TARGET` 
   - Change all instances from `11.0` (or whatever version) to `16.0`

## Step 4: Create the Flutter Counter App

Replace the contents of `lib/main.dart`:

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app_intents/flutter_app_intents.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter App Intents Tutorial',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CounterHomePage(),
    );
  }
}

class CounterHomePage extends StatefulWidget {
  const CounterHomePage({super.key});

  @override
  State<CounterHomePage> createState() => _CounterHomePageState();
}

class _CounterHomePageState extends State<CounterHomePage> {
  final FlutterAppIntentsClient _client = FlutterAppIntentsClient.instance;
  int _counter = 0;
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _setupAppIntents();
  }

  Future<void> _setupAppIntents() async {
    if (!Platform.isIOS) {
      setState(() {
        _status = 'App Intents are only supported on iOS';
      });
      return;
    }

    try {
      // Create the increment counter intent
      final incrementIntent = AppIntentBuilder()
          .identifier('increment_counter')
          .title('Increment Counter')
          .description('Increment the counter by one')
          .build();

      // Register the intent with its handler
      await _client.registerIntents({
        incrementIntent: _handleIncrementIntent,
      });

      await _client.updateShortcuts();

      setState(() {
        _status = 'App Intent registered successfully!\nTry saying: "Hey Siri, increment counter with counter intents tutorial"';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  Future<AppIntentResult> _handleIncrementIntent(
    Map<String, dynamic> parameters,
  ) async {
    setState(() {
      _counter++;
    });

    // Donate the intent to help Siri learn user patterns
    await _client.donateIntent('increment_counter', parameters);

    return AppIntentResult.successful(
      value: 'Counter incremented to $_counter',
      needsToContinueInApp: true,
    );
  }

  void _incrementCounter() {
    _handleIncrementIntent({});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Counter App Intents Tutorial'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'App Intents Status:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            const Card(
              color: Colors.green,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Try saying:\n"Hey Siri, increment counter with counter intents tutorial"',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

> **Note:** The status message and the UI card in the example above include a suggested Siri command with the app name "counter intents tutorial". When you test with Siri, make sure to use your app's actual display name, which might be different.

## Step 5: Create iOS App Intent Implementation

For Siri to discover our intents, we need to declare them statically in Swift. We'll separate our App Intents logic from the `AppDelegate` to keep the code organized.

### 5.1: Update AppDelegate.swift

First, ensure your `ios/Runner/AppDelegate.swift` file is clean and only contains the standard Flutter setup. Replace its contents with the following:

```swift
import Flutter
import UIKit

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
```

### 5.2: Create AppShortcuts.swift

Next, create a new file named `ios/Runner/AppShortcuts.swift`. This file will contain the App Intent definition and the App Shortcuts provider.

```swift
import AppIntents
import flutter_app_intents

// Simple error for App Intents
enum AppIntentError: Error {
    case executionFailed(String)
}

// App Intent that bridges to Flutter plugin
@available(iOS 16.0, *)
struct CounterIntent: AppIntent {
    static var title: LocalizedStringResource = "Increment Counter"
    static var description = IntentDescription("Increment the counter by one")
    static var isDiscoverable = true
    static var openAppWhenRun: Bool = true
    
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

@available(iOS 16.0, *)
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
    }
}
```

### Understanding the Swift Code Components

Let's break down each part of the `AppShortcuts.swift` file:

#### 1. **Imports and Error Handling**
```swift
import AppIntents
import flutter_app_intents

enum AppIntentError: Error {
    case executionFailed(String)
}
```
- **`import AppIntents`**: iOS 16+ framework for Siri integration
- **`import flutter_app_intents`**: The Flutter plugin's native iOS module
- **`AppIntentError`**: Custom error type for handling intent failures

#### 2. **App Intent Definition (`CounterIntent`)**
```swift
@available(iOS 16.0, *) 
struct CounterIntent: AppIntent {
    static var title: LocalizedStringResource = "Increment Counter"
    static var description = IntentDescription("Increment the counter by one")
    static var isDiscoverable = true
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        // ...
    }
}
```
- **`@available(iOS 16.0, *)`**: Ensures this only runs on iOS 16+
- **`static var title`**: What Siri will say/display to users
- **`static var description`**: Detailed description for the Shortcuts app
- **`static var isDiscoverable`**: Makes the intent visible in Shortcuts app
- **`ReturnsValue<String>`**: Tells iOS this intent returns a text response

#### 3. **Intent Performance (The Bridge to Flutter)**
The `perform()` function is where the magic happens:
1. **Gets the plugin instance**: `FlutterAppIntentsPlugin.shared`
2. **Calls Flutter code**: Using `handleIntentInvocation` with the identifier `"increment_counter"`
3. **Handles the response**: Checks if Flutter returned success or error
4. **Returns result to Siri**: Either a success message or throws an error

#### 4. **App Shortcuts Provider (`CounterAppShortcuts`)**
```swift
@available(iOS 16.0, *) 
struct CounterAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        // ...
    }
}
```
This struct tells iOS about your shortcuts:
- **`AppShortcut`**: Defines a shortcut that appears in the Shortcuts app
- **`intent`**: Links to the `CounterIntent` we defined above
- **`phrases`**: The exact words users can say to Siri
  - `\(.applicationName)`: Automatically replaced with your app's name
- **`shortTitle`**: Short name shown in Shortcuts app
- **`systemImageName`**: iOS system icon to display

### How It All Works Together

1. **iOS discovers your intents** via `CounterAppShortcuts`.
2. **User says a voice command** matching one of the phrases.
3. **iOS calls `CounterIntent.perform()`**.
4. **Swift calls your Flutter code** via `FlutterAppIntentsPlugin.shared.handleIntentInvocation()`.
5. **Flutter processes the request** using the handler you registered in `main.dart`.
6. **Flutter returns a result** back to Swift.
7. **Swift returns the result to iOS/Siri**.
8. **Siri speaks the response** and optionally opens your app.

## Step 6: Build and Run

1. **Clean and install dependencies:**
   ```bash
   flutter clean
   flutter pub get
   cd ios && pod install && cd ..
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

## Step 7: Test Siri Integration

1. **Make sure the app is installed** on your device (not just running in debug mode).

2. **Open the Shortcuts app** on your iOS device. You should see "Counter Intents Tutorial" in the "App Shortcuts" section.

3. **⚠️ CRITICAL STEP - Enable Siri (OFF by default):**
   - In the Shortcuts app, tap "Counter Intents Tutorial >"
   - Tap the **info icon (ⓘ)** in the top-right corner
   - **Toggle ON the Siri switch** (it's OFF by default!)
   - Make sure the toggle is **green**
   - **Without this step, voice commands will NOT work!**

4. **Test with Siri:**
   - "Hey Siri, increment counter with counter intents tutorial"
   - "Hey Siri, add one with counter intents tutorial"
   - "Hey Siri, count up using counter intents tutorial"

5. **The app should open** and the counter should increment.

## Troubleshooting

### Common Issues:

1. **Shortcuts don't appear:**
   - Make sure your iOS deployment target is 16.0+.
   - Rebuild and reinstall the app.
   - Check iOS Settings > Siri & Search > [Your App] > "Learn from this App" is enabled.

2. **Siri doesn't recognize commands:**
   - **FIRST: Check that Siri toggle is ON** in Shortcuts app → [Your App] → Info icon → Siri toggle (green)
   - Try the exact phrases from the `AppShortcuts` definition.
   - Make sure the app name matches what Siri expects.
   - Check that Siri is enabled for your app in Settings.
   - Restart the Shortcuts app completely.

3. **Build errors:**
   - Ensure Xcode is updated to support iOS 16+ features.
   - Check that all deployment targets are set to 16.0+.
   - Clean the build folder in Xcode: Product > Clean Build Folder.

### Debug Tips:

- Check the console output when running the app for any error messages.
- Use Xcode's debugger to see if the Swift intents are being called.
- Verify that the Flutter intent handlers are being registered correctly.

## What's Next?

Now that you have a basic working example, you can:

1. **Add more intents** (reset counter, get counter value, etc.).
2. **Add parameters** to intents for more complex interactions.
3. **Implement different return types** (with dialogs, opening specific screens, etc.).
4. **Add intent donations** to improve Siri's learning and suggestions.

## Key Concepts Learned

- **App Intents Framework**: iOS 16+ feature for Siri integration.
- **Flutter-iOS Bridge**: How Flutter communicates with native iOS code.
- **Intent Registration**: Both Flutter (functional) and iOS (declarative) sides.
- **App Shortcuts Provider**: Makes intents discoverable by iOS.
- **Voice Phrases**: Natural language commands for Siri.

Congratulations! You now have a working Flutter app with Siri integration using App Intents.
