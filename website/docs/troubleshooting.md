---
sidebar_position: 7
---

# Troubleshooting

## Common Issues

### iOS Issues

#### "App Intents are only supported on iOS"

This plugin only works on iOS 16.0+. Make sure you're testing on a compatible device or simulator.

#### Intents not appearing in Siri/Shortcuts

**Most Common Issues**: Missing static App Intents or disabled Siri integration

1. **Verify static intents are declared** in your `AppDelegate.swift` (see [iOS Configuration](../ios-configuration))
2. **Ensure AppShortcutsProvider exists** in your main app target
3. **Enable Siri for App Shortcuts**: In iOS Shortcuts app → [Your App] Shortcuts → Toggle ON the Siri switch (it's OFF by default)
   📱 **See the [Tutorial](../tutorial#step-2-enable-siri-critical-step) for detailed screenshots** showing exactly how to enable Siri
4. **Check intent identifiers match** between static Swift intents and Flutter handlers
5. **Restart the app completely** after adding static intents
6. Ensure intents are registered successfully on Flutter side
7. Check that `isEligibleForPrediction` is `true`
8. Try donating the intent after manual execution
9. Restart the Shortcuts app

**Architecture Note**: iOS App Intents framework requires static intent declarations at compile time for Siri/Shortcuts discovery. Dynamic registration from Flutter plugins alone is not sufficient.

#### Voice commands not recognized (iOS)

1. **Enable Siri toggle first**: In Shortcuts app → [Your App] Shortcuts → Toggle ON the Siri switch
   📱 **See the [Tutorial](../tutorial#step-2-enable-siri-critical-step) with screenshots** for the exact steps
2. Use simple, clear command phrases
3. Test different phrasings
4. Check Siri's language settings
5. Verify intent titles are descriptive

### Android Issues

#### Shortcuts not appearing in Google Assistant

**Most Common Issues**: Missing or invalid `shortcuts.xml` file

1. **Verify shortcuts.xml exists**: Check `android/app/src/main/res/xml/shortcuts.xml`
2. **Rebuild the app**: Run `flutter clean && flutter build apk`
3. **Check AndroidManifest.xml**: Ensure `android.app.shortcuts` meta-data is present in main activity
4. **Clear Google app data**: Settings → Apps → Google → Storage → Clear Cache
5. **Reinstall the app**: Uninstall and reinstall to refresh Assistant integration
6. **Use hot restart**: Press `R` (not `r`) after regenerating `shortcuts.xml`

#### Voice commands not recognized (Android)

1. **Check BII mapping**: Ensure your intent category matches the voice command type (see [Android Configuration](../android-configuration))
2. **Use correct phrasing**: Match Google's expected voice patterns for each Built-in Intent (BII)
3. **Test with ADB first**: Verify the intent works before testing voice commands
4. **Check Google Assistant language**: Must match your app's supported languages
5. **Enable developer mode**: Say "Hey Google, talk to \<your app name\>" to enable testing mode

#### Invalid shortcuts.xml errors

1. **Regenerate with code generator**: `dart run flutter_app_intents:app_intents_cli --platform=android`
2. **Validate XML syntax**: Check for missing closing tags or invalid characters
3. **Check package name**: Ensure `targetPackage` in `shortcuts.xml` matches your app's package in `build.gradle`
4. **Verify parameter mappings**: BII parameters must use correct Google-defined names (e.g., `exercise.name`, `message.recipient`)
5. **Check minimum SDK**: Android App Actions require minSdkVersion 23 or higher

### Navigation intents not working

1. **Verify `needsToContinueInApp: true`** in Flutter result
2. **Check `OpensIntent` return type** in Swift intent
3. **Ensure routes exist** in your app's navigation setup
4. **Test app lifecycle** - try when app is backgrounded vs foreground
5. **Check mounted context** before navigation calls
6. **Verify parameter passing** to destination screens

### Intent donations not improving predictions

1. **Ensure proper relevance scores**: Use higher scores (0.8-1.0) for frequently used actions
2. **Provide meaningful context**: Include feature names, user actions, and usage patterns
3. **Donate consistently**: Only donate after successful intent execution
4. **Use batch donations**: Group related intents for better learning
5. **Monitor and adjust**: Regularly review and update relevance scores based on usage analytics

### Intent Donation Fails

If `donateIntent()` returns false or fails:
- Verify the intent identifier matches a registered intent
- Check that parameters match the intent definition
- Ensure the intent was successfully registered before donation

## Debug Steps

### 1. Check Platform Configuration

**iOS:**
- Static intents declared in `AppDelegate.swift`
- `AppShortcutsProvider` implemented
- Minimum deployment target set to iOS 16.0
- Required permissions in `Info.plist`

**Android:**
- `shortcuts.xml` exists in `android/app/src/main/res/xml/`
- `android.app.shortcuts` meta-data in `AndroidManifest.xml`
- Minimum SDK version set to 23 or higher in `build.gradle`
- Package name matches across `build.gradle` and `shortcuts.xml`

### 2. Verify Intent Registration

```dart
// Check if intents are properly registered
final registeredIntents = await FlutterAppIntentsClient.instance.getRegisteredIntents();
print('Registered intents: ${registeredIntents.map((i) => i.identifier)}');
```

### 3. Test Intent Execution

```dart
// Add logging to your intent handlers
Future<AppIntentResult> handleMyIntent(Map<String, dynamic> parameters) async {
  print('Intent invoked with parameters: $parameters');
  
  try {
    // Your logic here
    final result = await doSomething();
    print('Intent completed successfully: $result');
    
    return AppIntentResult.successful(value: result);
  } catch (e) {
    print('Intent execution failed: $e');
    return AppIntentResult.failed(error: e.toString());
  }
}
```

### 4. Check Voice Assistant Integration

**iOS (Siri):**
1. Open the Shortcuts app
2. Look for your app in the "Apps" section
3. Check if your intents are listed
4. Try creating a shortcut manually
5. Test voice commands with Siri

**Android (Google Assistant):**
1. Say "Hey Google, talk to \<your app name\>" to enable developer mode
2. Try voice commands: "Hey Google, \<action\> with \<your app name\>"
3. Use ADB testing: `adb shell am start -a android.intent.action.VIEW -d "yourapp://action"`
4. Use Android Studio's App Actions Test Tool (Tools → App Actions Test Tool)
5. Check logcat for errors: `adb logcat | grep flutter_app_intents`

### 5. Verify Intent Donation

```dart
// Add logging to donation calls
final success = await FlutterAppIntentsClient.instance.donateIntent(
  'my_intent',
  parameters,
);

if (success) {
  print('Intent donated successfully');
} else {
  print('Intent donation failed');
}
```

## Best Practices for Debugging

### 1. Use Descriptive Identifiers

Use clear, consistent identifiers across Swift and Flutter:

```dart
// Flutter
identifier: 'open_user_profile'

// Swift
identifier: "open_user_profile"
```

### 2. Add Comprehensive Logging

```dart
class IntentLogger {
  static void logIntentInvocation(String identifier, Map<String, dynamic> parameters) {
    print('[INTENT] Invoked: $identifier with params: $parameters');
  }
  
  static void logIntentResult(String identifier, AppIntentResult result) {
    print('[INTENT] Result for $identifier: ${result.isSuccess ? 'SUCCESS' : 'FAILED'}');
    if (result.error != null) {
      print('[INTENT] Error: ${result.error}');
    }
  }
  
  static void logIntentDonation(String identifier) {
    print('[INTENT] Donated: $identifier');
  }
}
```

### 3. Test in Isolation

Create minimal test cases for each intent:

```dart
// Test intent registration
await testIntentRegistration();

// Test intent execution
await testIntentExecution();

// Test intent donation
await testIntentDonation();
```

### 4. Use iOS Simulator Console

Monitor iOS Simulator console for system-level errors:
1. Open Console app on macOS
2. Filter by device/simulator name
3. Look for App Intents related errors

### 5. Use Android Logcat (Android)

Monitor Android logcat for debugging App Actions:

```bash
# Filter for flutter_app_intents plugin logs
adb logcat | grep flutter_app_intents

# Filter for Google Assistant logs
adb logcat | grep Assistant

# Filter for shortcuts.xml parsing
adb logcat | grep Shortcuts

# Full app logs
adb logcat -s flutter
```

### 6. Test with ADB Commands (Android)

Test Android App Actions without voice commands:

```bash
# Test a specific intent via deep link
adb shell am start -a android.intent.action.VIEW \
  -d "yourapp://intent_name?param1=value1"

# Test Google Assistant integration
adb shell am start -a com.google.android.voiceinteraction.testapp.START_TEST

# Check if shortcuts.xml is valid
adb shell dumpsys package com.yourpackage.name | grep shortcuts
```

### 7. Verify shortcuts.xml (Android)

Check that your Android shortcuts file is properly configured:

```bash
# Navigate to your Android project
cd android/app/src/main/res/xml/

# Verify shortcuts.xml exists
ls -la shortcuts.xml

# Check file contents
cat shortcuts.xml
```

Ensure the file contains:
- Valid XML structure
- Correct package name matching `build.gradle`
- Proper BII capability mappings
- Correct parameter names for each BII

### 8. Use Android Studio App Actions Test Tool (Android)

The App Actions Test Tool provides visual debugging:

1. **Install Plugin**: Android Studio → Preferences → Plugins → "Google Assistant"
2. **Open Tool**: Tools → App Actions Test Tool
3. **Select App**: Choose your app from the dropdown
4. **Test Actions**:
   - Select a capability/shortcut
   - Fill in parameters
   - Preview Google Assistant response
   - Test without voice commands

### 9. Check AndroidManifest.xml (Android)

Verify the shortcuts reference in your manifest:

```xml
<activity android:name=".MainActivity">
    <!-- This meta-data MUST be present -->
    <meta-data
        android:name="android.app.shortcuts"
        android:resource="@xml/shortcuts" />

    <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
</activity>
```

If missing, add it to your main activity.

## Performance Considerations

### 1. Long-Running Operations

For operations that take time, use the app continuation pattern:

```dart
Future<AppIntentResult> handleLongOperation(Map<String, dynamic> parameters) async {
  // Start background work but return immediately
  _startBackgroundWork();
  
  return AppIntentResult.successful(
    value: 'Operation started, opening app for progress...',
    needsToContinueInApp: true,  // Opens your app where you can show progress
  );
}
```

### 2. Avoid Over-Donation

Don't donate too frequently:

```dart
// Donate after each successful execution
for (final intent in intents) {
  await FlutterAppIntentsClient.instance.donateIntent(
    intent.id,
    intent.params,
  );
}
```

### 3. Memory Management

- Unregister unused intents
- Avoid holding references to large objects in intent handlers
- Use weak references where appropriate to prevent memory leaks

**Note on Weak References**: When your intent handlers need to reference Flutter widgets or state objects that may be disposed, use weak references to avoid memory leaks. For example:

```dart
class MyIntentHandler {
  final WeakReference<MyWidgetState> _stateRef;

  MyIntentHandler(MyWidgetState state)
    : _stateRef = WeakReference(state);

  Future<AppIntentResult> handleIntent(Map<String, dynamic> params) async {
    final state = _stateRef.target;

    // Check if widget is still mounted before accessing
    if (state == null || !state.mounted) {
      return AppIntentResult.failed(
        error: 'Widget is no longer available',
      );
    }

    // Safe to use state now
    state.updateCounter();
    return AppIntentResult.successful(value: 'Counter updated');
  }
}
```

This prevents memory leaks when widgets are disposed while intent handlers are still registered.

## Getting Help

If you're still experiencing issues:

1. Check the [GitHub Issues](https://github.com/christophebonello/flutter_app_intents/issues)
2. Review the [example apps](https://github.com/christophebonello/flutter_app_intents/tree/main/example)
3. Consult platform documentation:
   - **iOS**: [Apple's App Intents documentation](https://developer.apple.com/documentation/appintents)
   - **Android**: [Google's App Actions documentation](https://developers.google.com/assistant/app/overview)
4. Create a minimal reproduction case
5. Open a new issue with detailed information about your setup (include platform, OS version, and logs)
