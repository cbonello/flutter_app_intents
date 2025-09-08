---
sidebar_position: 5
---

# Enhanced Intent Donation

The plugin provides advanced intent donation capabilities to help Siri learn user patterns and provide better predictions.

## Basic Intent Donation

```dart
// Simple donation (legacy API)
await FlutterAppIntentsService.donateIntent('my_intent', {'param': 'value'});
```

## Enhanced Donation with Metadata

```dart
// Enhanced donation with relevance scoring and context
await FlutterAppIntentsService.donateIntentWithMetadata(
  'my_intent',
  {'param': 'value'},
  relevanceScore: 0.8,           // 0.0-1.0 relevance score
  context: {                     // Additional context for better learning
    'feature': 'messaging',
    'userAction': true,
    'timeOfDay': 'morning',
  },
  timestamp: DateTime.now(),     // Optional custom timestamp
);
```

## Batch Intent Donation

For better performance when donating multiple intents:

```dart
final donations = [
  IntentDonation.highRelevance(
    identifier: 'send_message',
    parameters: {'recipient': 'Alice'},
    context: {'recent_contact': true},
  ),
  IntentDonation.userInitiated(
    identifier: 'set_reminder',
    parameters: {'title': 'Meeting'},
    context: {'calendar_event': true},
  ),
  IntentDonation.automated(
    identifier: 'background_sync',
    parameters: {'sync_type': 'incremental'},
  ),
];

await FlutterAppIntentsService.donateIntentBatch(donations);
```

## IntentDonation Factory Constructors

The `IntentDonation` class provides convenient factory constructors for different use cases:

### High Relevance (1.0)
```dart
IntentDonation.highRelevance(
  identifier: 'frequent_action',
  parameters: {'key': 'value'},
  context: {'usage': 'daily'},
)
```

### User Initiated (0.9)
```dart
IntentDonation.userInitiated(
  identifier: 'manual_action',
  parameters: {'trigger': 'button_press'},
)
```

### Medium Relevance (0.7)
```dart
IntentDonation.mediumRelevance(
  identifier: 'occasional_action',
  parameters: {'frequency': 'weekly'},
)
```

### Automated (0.5)
```dart
IntentDonation.automated(
  identifier: 'background_process',
  parameters: {'type': 'sync'},
)
```

### Low Relevance (0.3)
```dart
IntentDonation.lowRelevance(
  identifier: 'rare_action',
  parameters: {'last_used': '6_months_ago'},
)
```

## Donation Best Practices

### 1. Use Appropriate Relevance Scores

- `1.0` for frequently used, critical actions
- `0.9` for user-initiated actions
- `0.7` for moderately used features
- `0.5` for automated/background processes
- `0.3` for rarely used features

### 2. Provide Meaningful Context

```dart
context: {
  'feature': 'messaging',          // Which app feature
  'userAction': true,              // User vs system initiated
  'timeOfDay': 'evening',          // Temporal context
  'location': 'home',              // Location context
  'frequency': 'daily',            // Usage frequency
}
```

### 3. Donate After Successful Execution

```dart
// Execute the intent action
final result = await performAction();

// Only donate if successful
if (result.isSuccess) {
  await FlutterAppIntentsService.donateIntentWithMetadata(
    'my_intent',
    parameters,
    relevanceScore: 0.8,
    context: {'success': true},
  );
}
```

### 4. Use Batch Donations for Related Intents

```dart
// When user completes a workflow involving multiple intents
final workflowDonations = userWorkflow.map((step) => 
  IntentDonation.userInitiated(
    identifier: step.intentId,
    parameters: step.parameters,
    context: {'workflow': 'onboarding', 'step': step.order},
  )
).toList();

await FlutterAppIntentsService.donateIntentBatch(workflowDonations);
```

## Integration with Intent Handlers

Here's how to integrate donation into your intent handlers:

```dart
Future<AppIntentResult> handleIncrementIntent(Map<String, dynamic> parameters) async {
  try {
    final amount = parameters['amount'] as int? ?? 1;
    
    // Perform your app's logic
    final newValue = incrementCounter(amount);
    
    // Donate the intent to help Siri learn (enhanced donation)
    await FlutterAppIntentsService.donateIntentWithMetadata(
      'increment_counter',
      parameters,
      relevanceScore: 0.9, // High relevance for user-initiated actions
      context: {'feature': 'counter', 'userAction': true},
    );
    
    return AppIntentResult.successful(
      value: 'Counter is now $newValue',
    );
  } catch (e) {
    return AppIntentResult.failed(
      error: 'Failed to increment counter: $e',
    );
  }
}
```

## Troubleshooting Intent Donations

### Intent donations not improving predictions

1. **Ensure proper relevance scores**: Use higher scores (0.8-1.0) for frequently used actions
2. **Provide meaningful context**: Include feature names, user actions, and usage patterns
3. **Donate consistently**: Only donate after successful intent execution
4. **Use batch donations**: Group related intents for better learning
5. **Monitor and adjust**: Regularly review and update relevance scores based on usage analytics

### "Relevance score must be between 0.0 and 1.0"

This validation error occurs when calling `donateIntentWithMetadata()` with invalid relevance scores:

```dart
// Valid relevance scores
await FlutterAppIntentsService.donateIntentWithMetadata(
  'my_intent',
  parameters,
  relevanceScore: 0.8, // ✅ Valid: between 0.0 and 1.0
);

// Invalid relevance scores
relevanceScore: 1.5  // ❌ Invalid: greater than 1.0
relevanceScore: -0.1 // ❌ Invalid: less than 0.0
```

## Donation Strategy Guidelines

### Navigation Intents
- **High relevance** (0.8-1.0) when user-initiated
- Include contextual information about the destination
- Monitor donation performance and adjust relevance scores

### Action Intents
- Use enhanced donation with metadata for better learning
- Donate after successful execution only
- Use appropriate relevance scores based on usage patterns

### Background Operations
- Lower relevance scores (0.3-0.5) for automated processes
- Include context about the operation type and frequency
- Use batch donations for related background tasks