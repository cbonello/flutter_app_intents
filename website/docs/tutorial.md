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

struct SayHelloIntent: AppIntent {
    static var title: LocalizedStringResource = "Say Hello"

    @Parameter(title: "Name")
    var name: String

    func perform() async throws -> some IntentResult {
        // Your intent logic here
        return .result(dialog: "Hello, \(name)!")
    }
}
```

## 3. Register the Intent in Dart

In your Dart code, create an `AppIntent` object that matches the Swift definition.

```dart
import 'package:flutter_app_intents/flutter_app_intents.dart';

final sayHelloIntent = AppIntent(
  identifier: 'SayHelloIntent',
  title: 'Say Hello',
  parameters: [
    AppIntentParameter(
      name: 'name',
      title: 'Name',
      type: AppIntentParameterType.string,
    ),
  ],
);
```

Then, register the intent when your app starts.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterAppIntents.registerIntent(sayHelloIntent);
  runApp(MyApp());
}
```

## 4. Handle the Intent

Set up a handler to execute code when your intent is invoked.

```dart
FlutterAppIntents.setIntentHandler((identifier, parameters) async {
  if (identifier == 'SayHelloIntent') {
    final name = parameters['name'] as String;
    // Show a dialog, navigate, or perform any other action
    print('Hello, $name!');
    return AppIntentResult.successful();
  }
  return AppIntentResult.failed(error: 'Unknown intent');
});
```

That's it! You can now run your app and test your new Siri integration.

## Testing Your App Intent

1. **Check Shortcuts App**: Look for your app's shortcuts under "App Shortcuts"
2. **Enable Siri**: ⚠️ **IMPORTANT** - In Shortcuts app, tap your app's shortcuts and toggle ON the Siri switch (it's OFF by default)
3. **Test with Siri**: Try saying "Say Hello John" to test your intent
4. **Troubleshooting**: If it doesn't work, see the [Troubleshooting](troubleshooting) guide
