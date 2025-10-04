---
sidebar_position: 5
---

# Intent Donation

Intent donation helps Siri learn user patterns and provide better predictions. When you donate an intent, you're telling iOS that the user performed a specific action, which helps Siri suggest it at appropriate times.

## Basic Intent Donation

```dart
// Donate after successful intent execution
await FlutterAppIntentsClient.instance.donateIntent(
  'my_intent',
  {'param': 'value'},
);
```

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
    await FlutterAppIntentsClient.instance.donateIntent(
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

## How Intent Donation Improves Siri

When you consistently donate intents:

1. **Proactive Suggestions**: Siri learns when users typically perform actions and suggests them at relevant times
2. **Shortcuts Discovery**: Donated intents appear more prominently in the Shortcuts app
3. **Spotlight Integration**: Actions become searchable in Spotlight
4. **Contextual Awareness**: Siri learns patterns based on time, location, and usage frequency

## Example: Navigation Intent

```dart
await client.registerIntent(openProfileIntent, (parameters) async {
  final userId = parameters['userId'] as String;

  // Navigate to profile
  navigateToProfile(userId);

  // Donate so Siri learns this pattern
  await FlutterAppIntentsClient.instance.donateIntent(
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

### Intent donations not improving predictions

1. **Donate consistently**: Make sure you're donating after every successful execution
2. **Use correct parameters**: Ensure parameter names and values match your intent definition
3. **Check registration**: Verify the intent is registered before donating
4. **Give it time**: Siri needs multiple donations over time to learn patterns

### Donation fails silently

If `donateIntent()` returns false:
- Verify the intent identifier matches a registered intent
- Check that parameters are valid for the intent
- Ensure the iOS device is running iOS 16.0+

## Privacy Considerations

- Intent donations stay on the user's device and are not sent to your servers
- Users can clear donation history in iOS Settings → Siri & Search
- Donations are automatically managed by iOS and expire over time
- No personally identifiable information should be included in donation parameters
