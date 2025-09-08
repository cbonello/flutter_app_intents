---
sidebar_position: 6
---

# API Reference

## Flutter App IntentsClient

The main client class for managing App Intents:

### Methods

- `registerIntent(AppIntent intent, handler)` - Register a single intent with handler
- `registerIntents(Map&lt;AppIntent, handler&gt;)` - Register multiple intents
- `unregisterIntent(String identifier)` - Remove an intent
- `getRegisteredIntents()` - Get all registered intents
- `updateShortcuts()` - Refresh app shortcuts
- `donateIntent(String identifier, parameters)` - Basic intent donation for prediction
- `donateIntentWithMetadata(identifier, parameters, {relevanceScore, context, timestamp})` - Enhanced donation with metadata
- `donateIntentBatch(List&lt;IntentDonation&gt; donations)` - Batch donate multiple intents efficiently

## AppIntent

Represents an App Intent configuration:

```dart
const AppIntent({
  required String identifier,      // Unique ID
  required String title,          // Display name
  required String description,    // What it does
  List&lt;AppIntentParameter&gt; parameters = const [],
  bool isEligibleForSearch = true,
  bool isEligibleForPrediction = true,
  AuthenticationPolicy authenticationPolicy = AuthenticationPolicy.none,
});
```

### Properties

- `identifier` (String): Unique identifier for the intent
- `title` (String): Human-readable title shown in Siri/Shortcuts
- `description` (String): Description of what the intent does
- `parameters` (List&lt;AppIntentParameter&gt;): List of parameters this intent accepts
- `isEligibleForSearch` (bool): Whether intent appears in Spotlight search
- `isEligibleForPrediction` (bool): Whether Siri can suggest this intent
- `authenticationPolicy` (AuthenticationPolicy): Authentication requirements

## AppIntentParameter

Defines parameters that can be passed to intents:

```dart
const AppIntentParameter({
  required String name,           // Parameter name
  required String title,          // Display title
  required AppIntentParameterType type,
  String? description,
  bool isOptional = false,
  dynamic defaultValue,
});
```

### Properties

- `name` (String): Internal parameter name used in code
- `title` (String): Human-readable title shown to users
- `type` (AppIntentParameterType): Data type of the parameter
- `description` (String?): Optional description of the parameter
- `isOptional` (bool): Whether the parameter is required
- `defaultValue` (dynamic): Default value if not provided

## AppIntentParameterType

Supported parameter types:

- `AppIntentParameterType.string` - Text input
- `AppIntentParameterType.integer` - Whole numbers
- `AppIntentParameterType.boolean` - True/false values
- `AppIntentParameterType.double` - Decimal numbers
- `AppIntentParameterType.date` - Date/time values
- `AppIntentParameterType.url` - Web URLs
- `AppIntentParameterType.file` - File references
- `AppIntentParameterType.entity` - Custom app-specific types

## AppIntentResult

Result returned from intent execution:

### Successful Result
```dart
AppIntentResult.successful(
  value: 'Operation completed',
  needsToContinueInApp: false,
);
```

### Failed Result
```dart
AppIntentResult.failed(
  error: 'Something went wrong',
);
```

### Properties

- `isSuccess` (bool): Whether the intent executed successfully
- `value` (String?): Result message or value returned
- `error` (String?): Error message if execution failed
- `needsToContinueInApp` (bool): Whether the app should be opened/focused

## AppIntentBuilder

Fluent API for creating intents:

```dart
final intent = AppIntentBuilder()
    .identifier('my_intent')
    .title('My Intent')
    .description('Does something useful')
    .parameter(myParameter)
    .eligibleForSearch(true)
    .authenticationPolicy(AuthenticationPolicy.requiresAuthentication)
    .build();
```

### Methods

- `identifier(String id)` - Set the unique identifier
- `title(String title)` - Set the display title
- `description(String desc)` - Set the description
- `parameter(AppIntentParameter param)` - Add a parameter
- `eligibleForSearch(bool eligible)` - Set search eligibility
- `eligibleForPrediction(bool eligible)` - Set prediction eligibility
- `authenticationPolicy(AuthenticationPolicy policy)` - Set auth requirements
- `build()` - Build the final AppIntent object

## Authentication Policies

Control when intents can be executed:

- `AuthenticationPolicy.none` - No authentication required
- `AuthenticationPolicy.requiresAuthentication` - User must be authenticated
- `AuthenticationPolicy.requiresUnlockedDevice` - Device must be unlocked

## Intent Donation Classes

### IntentDonation

Represents a single intent donation with metadata:

```dart
const IntentDonation({
  required String identifier,
  required Map&lt;String, dynamic&gt; parameters,
  required double relevanceScore,
  Map&lt;String, dynamic&gt;? context,
  DateTime? timestamp,
});
```

### Factory Constructors

- `IntentDonation.highRelevance()` - Creates donation with relevance 1.0
- `IntentDonation.userInitiated()` - Creates donation with relevance 0.9
- `IntentDonation.mediumRelevance()` - Creates donation with relevance 0.7
- `IntentDonation.automated()` - Creates donation with relevance 0.5
- `IntentDonation.lowRelevance()` - Creates donation with relevance 0.3

## Error Handling

### Common Exceptions

- `AppIntentException` - Base exception class for intent-related errors
- `IntentRegistrationException` - Errors during intent registration
- `IntentExecutionException` - Errors during intent execution
- `InvalidParameterException` - Invalid parameter values or types

### Best Practices

```dart
try {
  final result = await handleIntent(parameters);
  return AppIntentResult.successful(value: result);
} catch (e) {
  // Log the error for debugging
  print('Intent execution failed: $e');
  
  // Return user-friendly error message
  return AppIntentResult.failed(
    error: 'Unable to complete the requested action',
  );
}
```

## FlutterAppIntentsService

Static service class providing utility methods:

### Methods

```dart
// Enhanced intent donation
static Future<void> donateIntentWithMetadata(
  String identifier,
  Map&lt;String, dynamic&gt; parameters, {
  required double relevanceScore,
  Map&lt;String, dynamic&gt;? context,
  DateTime? timestamp,
});

// Batch intent donation
static Future<void> donateIntentBatch(
  List&lt;IntentDonation&gt; donations,
);

// Basic intent donation
static Future<void> donateIntent(
  String identifier,
  Map&lt;String, dynamic&gt; parameters,
);
```

## Example Usage

### Complete Intent Setup

```dart
class MyAppIntents {
  static Future<void> setupIntents() async {
    final client = FlutterAppIntentsClient.instance;
    
    // Create intent with builder
    final incrementIntent = AppIntentBuilder()
        .identifier('increment_counter')
        .title('Increment Counter')
        .description('Increments the counter by one')
        .parameter(const AppIntentParameter(
          name: 'amount',
          title: 'Amount',
          type: AppIntentParameterType.integer,
          isOptional: true,
          defaultValue: 1,
        ))
        .eligibleForSearch(true)
        .eligibleForPrediction(true)
        .build();
    
    // Register with handler
    await client.registerIntent(incrementIntent, _handleIncrement);
  }
  
  static Future<AppIntentResult> _handleIncrement(
    Map&lt;String, dynamic&gt; parameters,
  ) async {
    try {
      final amount = parameters['amount'] as int? ?? 1;
      
      // Your business logic
      final newValue = await incrementCounter(amount);
      
      // Enhanced donation
      await FlutterAppIntentsService.donateIntentWithMetadata(
        'increment_counter',
        parameters,
        relevanceScore: 0.9,
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
}
```