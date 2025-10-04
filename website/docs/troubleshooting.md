---
sidebar_position: 7
---

# Troubleshooting

## Common Issues

### "App Intents are only supported on iOS"

This plugin only works on iOS 16.0+. Make sure you're testing on a compatible device or simulator.

### Intents not appearing in Siri/Shortcuts

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

### Voice commands not recognized

1. **Enable Siri toggle first**: In Shortcuts app → [Your App] Shortcuts → Toggle ON the Siri switch  
   📱 **See the [Tutorial](../tutorial#step-2-enable-siri-critical-step) with screenshots** for the exact steps
2. Use simple, clear command phrases
3. Test different phrasings
4. Check Siri's language settings
5. Verify intent titles are descriptive

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

### 1. Check iOS Configuration

Verify your iOS setup is correct:

- Static intents declared in `AppDelegate.swift`
- `AppShortcutsProvider` implemented
- Minimum deployment target set to iOS 16.0
- Required permissions in `Info.plist`

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

### 4. Check Siri Integration

1. Open the Shortcuts app
2. Look for your app in the "Apps" section
3. Check if your intents are listed
4. Try creating a shortcut manually
5. Test voice commands with Siri

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
- Use weak references where appropriate

## Getting Help

If you're still experiencing issues:

1. Check the [GitHub Issues](https://github.com/christophebonello/flutter_app_intents/issues)
2. Review the [example apps](https://github.com/christophebonello/flutter_app_intents/tree/main/example)
3. Consult [Apple's App Intents documentation](https://developer.apple.com/documentation/appintents)
4. Create a minimal reproduction case
5. Open a new issue with detailed information about your setup
