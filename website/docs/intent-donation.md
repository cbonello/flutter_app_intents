---
sidebar_position: 5
---

# Intent Donation

Intent donation helps Siri learn user patterns and provide better predictions. When you donate an intent, you're telling iOS that the user performed a specific action, which helps Siri suggest it at appropriate times.

## Platform Support

> **📱 Platform Support:** Intent donation is an **iOS-only** feature for Siri learning and predictions. On Android and other platforms, donation calls are **silently ignored** (no-op) and return `true`. This allows you to write cross-platform code without platform checks.

**Why iOS-only?**
- iOS uses intent donations to power Siri Suggestions and predictive features
- Android uses a different system for app actions (no equivalent donation mechanism)
- The API silently succeeds on Android to maintain code consistency across platforms

## Basic Intent Donation

```dart
// Donate after successful intent execution
// (iOS-only feature, silently ignored on Android)
await FlutterAppIntentsClient.instance.donateIntentWithMetadata(
  'my_intent',
  {'param': 'value'},
);
```

## Batch Intent Donation

For improved performance when donating multiple intents, use the batch donation API:

```dart
// Create multiple intent donations
final donations = [
  IntentDonation.userInitiated(
    identifier: 'increment_counter',
    parameters: {'amount': 5},
  ),
  IntentDonation.userInitiated(
    identifier: 'reset_counter',
    parameters: {},
  ),
  IntentDonation.automated(
    identifier: 'check_counter',
    parameters: {},
    context: {'trigger': 'background_refresh'},
  ),
];

// Donate all intents in a single batch
await FlutterAppIntentsClient.instance.donateIntents(donations);
```

### Advanced Batch Donation

Create donations with full control over relevance, context, and timestamp:

```dart
final donations = [
  IntentDonation(
    identifier: 'send_message',
    parameters: {'recipient': 'Alice', 'message': 'Hello'},
    relevanceScore: 0.9,  // High relevance - user-initiated
    context: {
      'source': 'quick_action',
      'time_of_day': 'morning',
    },
    timestamp: DateTime.now(),
  ),
  IntentDonation(
    identifier: 'check_messages',
    parameters: {},
    relevanceScore: 0.5,  // Medium relevance - automated
    context: {'trigger': 'app_launch'},
    timestamp: DateTime.now(),
  ),
];

await FlutterAppIntentsClient.instance.donateIntents(donations);
```

### When to Use Batch Donation

✅ **Use batch donation for:**
- Processing multiple related user actions at once
- Bulk importing historical intent data
- Syncing intent history across devices
- Reducing platform channel overhead

**Benefits:**
- More efficient than multiple individual `donateIntentWithMetadata()` calls
- Atomic processing on iOS for better performance
- Single platform channel call reduces overhead

## Best Practices

### When to Donate

✅ **DO donate:**
- After user successfully completes an action
- When an intent is invoked via Siri or Shortcuts
- For frequently-used features to improve predictions

❌ **DON'T donate:**
- After failed operations
- For background/automated tasks
- For one-time setup actions

### Integration with Intent Handlers

Donate intents within your handler after successful execution:

```dart
Future<AppIntentResult> handleIncrementIntent(
  Map<String, dynamic> parameters,
) async {
  try {
    final amount = parameters['amount'] as int? ?? 1;

    // Perform your app's logic
    final newValue = incrementCounter(amount);

    // Donate the intent to help Siri learn
    // No Platform.isIOS check needed - silently ignored on Android
    await FlutterAppIntentsClient.instance.donateIntentWithMetadata(
      'increment_counter',
      parameters,
    );

    return AppIntentResult.successful(
      value: 'Counter is now $newValue',
    );
  } catch (e) {
    // Don't donate if the action failed
    return AppIntentResult.failed(
      error: 'Failed to increment counter: $e',
    );
  }
}
```

## How Intent Donation Improves Siri (iOS)

When you consistently donate intents on iOS:

1. **Proactive Suggestions**: Siri learns when users typically perform actions and suggests them at relevant times
2. **Shortcuts Discovery**: Donated intents appear more prominently in the Shortcuts app
3. **Spotlight Integration**: Actions become searchable in Spotlight
4. **Contextual Awareness**: Siri learns patterns based on time, location, and usage frequency

> **Note:** These benefits are iOS-specific. On Android, while donations are safely ignored, app actions are still fully functional through Google Assistant.

## Example: Navigation Intent

```dart
await client.registerIntent(openProfileIntent, (parameters) async {
  final userId = parameters['userId'] as String;

  // Navigate to profile
  navigateToProfile(userId);

  // Donate so Siri learns this pattern (iOS-only, ignored on Android)
  await FlutterAppIntentsClient.instance.donateIntentWithMetadata(
    'open_profile',
    {'userId': userId},
  );

  return AppIntentResult.successful(
    value: 'Opened profile for $userId',
    needsToContinueInApp: true,
  );
});
```

## Troubleshooting

### Intent donations not improving predictions (iOS)

1. **Donate consistently**: Make sure you're donating after every successful execution
2. **Use correct parameters**: Ensure parameter names and values match your intent definition
3. **Check registration**: Verify the intent is registered before donating
4. **Give it time**: Siri needs multiple donations over time to learn patterns

### Donation returns true but nothing happens (Android)

This is expected behavior:
- On Android, `donateIntentWithMetadata()` always returns `true` and does nothing (no-op)
- Android App Actions don't use donation-based learning like iOS
- Your app actions will still work perfectly via Google Assistant
- The silent success allows cross-platform code without platform checks

### Donation fails on iOS

If `donateIntentWithMetadata()` returns false on iOS:
- Verify the intent identifier matches a registered intent
- Check that parameters are valid for the intent
- Ensure the iOS device is running iOS 16.0+

## Privacy Considerations

- Intent donations stay on the user's device and are not sent to your servers
- Users can clear donation history in iOS Settings → Siri & Search
- Donations are automatically managed by iOS and expire over time
- No personally identifiable information should be included in donation parameters
