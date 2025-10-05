---
sidebar_position: 2
---

# Tutorial

This tutorial will guide you through the process of setting up and using the Flutter App Intents plugin.

**✨ NEW in v0.8.0**: This tutorial now shows the recommended code generation approach, which automatically creates platform-specific code from your Dart definitions!

## Choose Your Approach

### Recommended: Code Generation (Easy)
Use the automatic code generator to create platform code from Dart. **Jump to [Step 1: Install the Package](#1-install-the-package)**.

### Alternative: Manual Setup (Advanced)
Manually write Swift/XML code for full customization. See [Manual Setup Guide](#manual-setup-advanced) at the end.

---

## 1. Install the Package

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_app_intents: ^0.8.0
```

Then run:
```bash
flutter pub get
```

## 2. Define Your Intent in Dart

In your `lib/main.dart` or a dedicated intents file, define your intent using `AppIntentBuilder`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_app_intents/flutter_app_intents.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get the client instance
  final client = FlutterAppIntentsClient.instance;

  // Build and register the intent with its handler
  final sayHelloIntent = AppIntentBuilder()
      .identifier('say_hello')
      .title('Say Hello')
      .description('Greet someone by name')
      .category(IntentCategory.general)  // Required for code generation
      .parameter(const AppIntentParameter(
        name: 'name',
        title: 'Name',
        type: AppIntentParameterType.string,
      ))
      .build();

  // Register with handler
  await client.registerIntent(sayHelloIntent, (parameters) async {
    final name = parameters['name'] as String? ?? 'World';
    print('Hello, $name!');
    return AppIntentResult.successful(value: 'Hello, $name!');
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Intents Demo',
      home: Scaffold(
        appBar: AppBar(title: const Text('App Intents Demo')),
        body: const Center(child: Text('Say "Hey Siri, Say Hello to John"')),
      ),
    );
  }
}
```

## 3. Generate Platform Code

Now use the code generator to create iOS and Android platform files:

```bash
dart run flutter_app_intents:app_intents_cli
```

**Optional: Install globally for convenience**
```bash
# Install once
dart pub global activate flutter_app_intents

# Then use the shorter command
app_intents_cli
```

**Output:**
```
🔍 Scanning lib/ for intent definitions...
✅ Found 1 intent(s) in 1 file(s)
📱 Processing platform: android
📝 Generated: android/app/src/main/res/xml/shortcuts.xml
📱 Processing platform: ios
📝 Generated: ios/Runner/AppShortcuts.swift
✅ Code generation complete!
```

This creates:
- **iOS**: `ios/Runner/AppShortcuts.swift` with complete Swift App Intents
- **Android**: `android/app/src/main/res/xml/shortcuts.xml` for Google Assistant

## 4. Add Generated File to Xcode (iOS Only)

For iOS, you need to add the generated Swift file to your Xcode project:

1. Open `ios/Runner.xcworkspace` in Xcode
2. Right-click on the "Runner" folder in the project navigator
3. Select "Add Files to Runner..."
4. Navigate to `ios/Runner/` and select `AppShortcuts.swift`
5. Check "Copy items if needed"
6. Make sure "Runner" target is selected
7. Click "Add"

**Note**: Android's `shortcuts.xml` is automatically included - no manual steps needed!

## 5. Build and Run

Build and run your app:

```bash
flutter run
```

That's it! The code generator has created all the platform-specific code for you.

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
Try saying:
- **iOS**: "Hey Siri, Say Hello to John"
- **Android**: "Hey Google, Say Hello to Alice with [Your App Name]"

If Siri doesn't respond, double-check that you enabled the Siri toggle in Step 2.

### Step 4: Troubleshooting
If voice commands still don't work after enabling Siri:
- Restart the Shortcuts app completely
- Try saying the exact phrase shown in the Shortcuts app
- Check the [Troubleshooting](/flutter_app_intents/docs/troubleshooting) guide for more solutions

## What's Next?

Now that you have a working App Intent, you can:

1. **Add more intents**: Define additional intents in your Dart code and regenerate
2. **Use watch mode**: Run `app_intents_cli --watch` (or `dart run flutter_app_intents:app_intents_cli --watch`) for auto-regeneration
3. **Install globally**: Run `dart pub global activate flutter_app_intents` to use the shorter `app_intents_cli` command
4. **Explore examples**: Check out the [Counter](/flutter_app_intents/docs/examples#1-counter-example), [Navigation](/flutter_app_intents/docs/examples#2-navigation-example), and [Weather](/flutter_app_intents/docs/examples#3-weather-example) examples
5. **Learn about categories**: Use different `IntentCategory` values for better voice recognition
6. **Add parameters**: Define complex parameters for richer voice interactions

## Manual Setup (Advanced)

If you need full control or want to customize the generated code, you can manually create platform files:

### iOS Manual Setup

Create `ios/Runner/AppDelegate.swift` (or add to existing):

```swift
import AppIntents
import flutter_app_intents

@available(iOS 16.0, *)
struct SayHelloIntent: AppIntent {
    static var title: LocalizedStringResource = "Say Hello"
    static var description = IntentDescription("Greet someone by name")

    @Parameter(title: "Name")
    var name: String

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "say_hello",
            parameters: ["name": name]
        )

        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Hello!"
            return .result(value: value)
        } else {
            throw IntentExecutionError.executionFailed
        }
    }
}

@available(iOS 16.0, *)
struct AppShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SayHelloIntent(),
            phrases: [
                "Say Hello to \(\.$name)",
                "Greet \(\.$name)"
            ],
            shortTitle: "Say Hello",
            systemImageName: "hand.wave"
        )
    }
}

enum IntentExecutionError: Error {
    case executionFailed
}
```

### Android Manual Setup

Create `android/app/src/main/res/xml/shortcuts.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<shortcuts xmlns:android="http://schemas.android.com/apk/res/android">
  <capability android:name="actions.intent.OPEN_APP_FEATURE">
    <intent
      android:targetPackage="com.example.myapp"
      android:targetClass="com.example.myapp.MainActivity">
      <parameter
        android:name="feature"
        android:key="feature_name"/>
    </intent>
  </capability>
</shortcuts>
```

Then add to `AndroidManifest.xml`:

```xml
<activity android:name=".MainActivity">
    <meta-data
        android:name="android.app.shortcuts"
        android:resource="@xml/shortcuts" />
</activity>
```

**Note**: Manual setup requires understanding of iOS AppIntents framework and Android App Actions. The code generator is recommended for most use cases.
