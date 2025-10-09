# Flutter App Intents Tutorial: Cross-Platform Counter with Voice Commands

> **Note:** This tutorial guides you through a simplified version of the counter example. For a more advanced implementation with multiple intents and parameter handling, please refer to the `example/counter` directory in this project.

This tutorial will guide you through creating a simple Flutter counter app that can be controlled by voice commands on both iOS (Siri) and Android (Google Assistant) using the `flutter_app_intents` plugin.

## Prerequisites

### For iOS Development
- Flutter SDK installed
- Xcode 14.0 or later
- iOS device or simulator running iOS 16.0+
- macOS for development

### For Android Development
- Flutter SDK installed
- Android Studio or VS Code with Flutter plugin
- Android device or emulator running Android 7.1 (API 25) or higher
- ADB (Android Debug Bridge) for testing

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
  flutter_app_intents: ^0.8.0  # Use the latest version
  cupertino_icons: ^1.0.8
```

Then run:

```bash
flutter pub get
```

## Step 3: Update Platform Requirements

### iOS Configuration

The App Intents framework requires iOS 16.0+. Update the deployment target:

1. Open `ios/Podfile` and ensure the platform is set to iOS 16.0:

```ruby
platform :ios, '16.0'
```

2. Open `ios/Runner.xcodeproj/project.pbxproj` and update the deployment target:
   - Search for `IPHONEOS_DEPLOYMENT_TARGET`
   - Change all instances from `11.0` (or whatever version) to `16.0`

3. **Set the iOS app display name** (recommended to avoid awkward Siri phrases):
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select the "Runner" project in the navigator
   - Select the "Runner" target
   - Go to the "General" tab
   - Under "Identity", change "Display Name" from "counter_intents_tutorial" to **"CounterApp"**
   - This makes Siri phrases cleaner: "increment counter with CounterApp" instead of "increment counter with counter intents tutorial"

### Android Configuration

App Actions require Android 7.1 (API level 25) or higher:

1. Open `android/app/build.gradle` and ensure minSdkVersion is set to 25:

```gradle
android {
    defaultConfig {
        minSdkVersion 25  // Android 7.1+ required for App Actions
        targetSdkVersion flutter.targetSdkVersion
    }
}
```

## Step 4: Create the Flutter Counter App

Replace the contents of `lib/main.dart`:

> **Note:** We use "CounterApp" as the app title to create natural-sounding Siri phrases like "Hey Siri, increment counter with CounterApp". This avoids the awkward repetition of "increment counter with counter intents tutorial".

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
      title: 'CounterApp',
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
    try {
      // Create the increment counter intent
      final incrementIntent = AppIntentBuilder()
          .identifier('increment_counter')
          .title('Increment Counter')
          .description('Increment the counter by one')
          .category(IntentCategory.general)
          .build();

      // Register the intent with its handler
      await _client.registerIntents({
        incrementIntent: _handleIncrementIntent,
      });

      if (Platform.isIOS) {
        await _client.updateShortcuts();
      }

      setState(() {
        if (Platform.isIOS) {
          _status = 'App Intent registered successfully!\n\n'
              'iOS: Try saying "Hey Siri, increment counter with CounterApp"';
        } else if (Platform.isAndroid) {
          _status = 'App Intent registered successfully!\n\n'
              'Android: Use ADB command:\n'
              'adb shell am start -a android.intent.action.VIEW -d "app://intent/increment_counter"';
        } else {
          _status = 'Platform not supported';
        }
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
    // (iOS-only feature, silently ignored on Android)
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
        title: const Text('CounterApp'),
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
            Card(
              color: Colors.green,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  Platform.isIOS
                      ? 'Try saying:\n"Hey Siri, increment counter with CounterApp"'
                      : Platform.isAndroid
                          ? 'Test with ADB:\nadb shell am start -a android.intent.action.VIEW -d "app://intent/increment_counter"'
                          : 'Platform not supported',
                  style: const TextStyle(
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

> **Note:** The app now supports both iOS and Android. The status message will show platform-specific testing instructions.

## Step 5: Generate Platform-Specific Code (Recommended)

The easiest way to set up platform intents is using the code generator. Run this command from your project root:

```bash
dart run flutter_app_intents:app_intents_cli
```

This will automatically generate:
- **For iOS**: `ios/Runner/AppShortcuts.swift` - Static Swift intents
- **For Android**: `android/app/src/main/res/xml/shortcuts.xml` - App Actions configuration

### Add Generated iOS File to Xcode

After running the generator, you need to add the Swift file to your Xcode project:

1. Open `ios/Runner.xcworkspace` in Xcode
2. Right-click on the "Runner" folder in the Project Navigator
3. Select "Add Files to Runner"
4. Navigate to `ios/Runner/AppShortcuts.swift`
5. Check "Copy items if needed" and ensure "Runner" target is selected
6. Click "Add"

### Android Setup

For Android, the generated files are automatically placed in the correct locations. However, you need to ensure your `AndroidManifest.xml` is configured to handle deep links.

Open `android/app/src/main/AndroidManifest.xml` and add the following inside the `<activity>` tag that contains the `MAIN` intent filter:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="app" android:host="intent" />
</intent-filter>
```

**Complete example:**
```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop"
    android:theme="@style/LaunchTheme"
    android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
    android:hardwareAccelerated="true"
    android:windowSoftInputMode="adjustResize">

    <!-- Standard Flutter main launcher -->
    <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>

    <!-- Deep link intent filter for App Actions -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="app" android:host="intent" />
    </intent-filter>
</activity>
```

> **Tip**: You can also use the `--watch` flag to automatically regenerate code when your Dart files change:
> ```bash
> dart run flutter_app_intents:app_intents_cli --watch
> ```

---

## Alternative: Manual iOS Setup

If you prefer not to use the code generator, you can manually write the iOS intents. For Siri to discover our intents, we need to declare them statically in Swift. We'll separate our App Intents logic from the `AppDelegate` to keep the code organized.

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

## Step 7: Test Your App Intents

### iOS Testing with Siri

1. **Make sure the app is installed** on your device (not just running in debug mode).

2. **Open the Shortcuts app** on your iOS device. You should see "CounterApp" in the "App Shortcuts" section.

3. **⚠️ CRITICAL STEP - Enable Siri (OFF by default):**
   - In the Shortcuts app, tap "CounterApp >"
   - Tap the **info icon (ⓘ)** in the top-right corner
   - **Toggle ON the Siri switch** (it's OFF by default!)
   - Make sure the toggle is **green**
   - **Without this step, voice commands will NOT work!**

4. **Test with Siri:**
   - "Hey Siri, increment counter with CounterApp"
   - "Hey Siri, add one with CounterApp"
   - "Hey Siri, count up with CounterApp"

5. **The app should open** and the counter should increment.

### Android Testing with ADB

**⭐ ADB is the recommended way to test during development:**

1. **Ensure your device/emulator is connected:**
   ```bash
   adb devices
   ```

2. **Build and install your app:**
   ```bash
   flutter build apk
   flutter install
   ```

3. **Test the intent using ADB:**
   ```bash
   adb shell am start -a android.intent.action.VIEW -d "app://intent/increment_counter"
   ```

4. **The app should open** and the counter should increment.

**Testing from a fresh start:**
```bash
# Stop the app
adb shell am force-stop com.example.counter_intents_tutorial

# Launch the intent
adb shell am start -a android.intent.action.VIEW -d "app://intent/increment_counter"
```

> **Note:** If you see a "Warning" message when the app is already running, this is normal! It means the intent was successfully delivered.

**Google Assistant Voice Commands (Production Only):**

Voice commands with Google Assistant require:
- App published on Google Play (even internal testing track), OR
- Google Assistant Plugin for Android Studio

After publishing:
```
"Hey Google, increment counter with CounterApp"
```

**App Launcher Shortcuts:**

You can also test shortcuts without ADB:
- Long-press the app icon in your launcher
- Shortcuts should appear in the menu
- Tap to test

## Troubleshooting

### iOS Issues

1. **Shortcuts don't appear:**
   - Make sure your iOS deployment target is 16.0+.
   - Verify `AppShortcuts.swift` is added to Xcode project (check in Build Phases → Compile Sources).
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
   - Verify `import flutter_app_intents` is correct (lowercase with underscores).

### Android Issues

1. **Intent not working via ADB:**
   - Verify `AndroidManifest.xml` contains the deep link intent filter (see Step 5).
   - Check that `shortcuts.xml` exists in `android/app/src/main/res/xml/`.
   - Ensure minSdkVersion is 25 or higher in `android/app/build.gradle`.
   - Check ADB is connected: `adb devices`.
   - Try force-stopping the app first: `adb shell am force-stop com.example.counter_intents_tutorial`.

2. **Shortcuts don't appear in launcher:**
   - Rebuild the app after running the code generator.
   - Long-press the app icon - shortcuts may take a moment to appear.
   - Check that `shortcuts.xml` is properly formatted.

3. **Deep link not routing to Flutter handler:**
   - Verify the deep link scheme in `AndroidManifest.xml` matches `app://intent`.
   - Check that the intent identifier in `shortcuts.xml` matches your Dart code.
   - Look for errors in Logcat: `adb logcat | grep flutter`.

### General Debug Tips:

- **Check console output** when running the app for any error messages.
- **iOS**: Use Xcode's debugger to see if the Swift intents are being called.
- **Android**: Use Logcat to see if deep links are being received.
- **Verify intent registration**: Check that the Flutter intent handlers are being registered correctly.
- **Use the generator**: If manual setup isn't working, try using the code generator instead.

## What's Next?

Now that you have a basic working example, you can:

1. **Add more intents** (reset counter, get counter value, etc.).
2. **Add parameters** to intents for more complex interactions.
3. **Use `.presentsResult(true)`** for query intents that show results without opening the app.
4. **Add intent donations** to improve Siri's learning and suggestions (iOS).
5. **Explore the code generator options**:
   - Use `--watch` mode for automatic regeneration
   - Generate for specific platforms with `--platform=ios` or `--platform=android`
   - Customize Android main activity with `--main-activity=YourActivity`
6. **Test different intent categories** (general, productivity, health, etc.).
7. **Implement navigation intents** to open specific screens in your app.

## Key Concepts Learned

- **Cross-Platform App Intents**: Support for both iOS (Siri) and Android (Google Assistant).
- **Code Generation**: Automatically create platform-specific code from Dart definitions.
- **App Intents Framework**: iOS 16+ feature for Siri integration.
- **Android App Actions**: Google Assistant integration via shortcuts.xml.
- **Flutter-Native Bridge**: How Flutter communicates with native platform code.
- **Intent Registration**: Both Flutter (functional) and platform (declarative) sides.
- **App Shortcuts Provider**: Makes intents discoverable by iOS.
- **Deep Links**: Android routing mechanism for App Actions.
- **ADB Testing**: Standard development workflow for Android App Actions.

## Additional Resources

- **[Main README](../README.md)** - Complete plugin documentation
- **[Example Apps](../example/)** - Counter, Navigation, and Weather examples
- **[iOS Configuration Guide](https://cbonello.github.io/flutter_app_intents/docs/ios-configuration)**
- **[Android Configuration Guide](https://cbonello.github.io/flutter_app_intents/docs/android-configuration)**
- **[Code Generator Documentation](../README.md#code-generation-recommended)**

Congratulations! You now have a working cross-platform Flutter app with voice command integration using App Intents.
