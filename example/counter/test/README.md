# Counter Example Tests

This directory contains comprehensive tests for the counter App Intents example.

## Test Files

### `counter_ui_test.dart`
**UI widget tests for counter app**

Tests the counter app's user interface and basic functionality:
- App startup and initialization
- Counter display and increment functionality
- Status message display and theming
- App layout structure and responsive behavior
- Floating action button interactions
- Siri command examples display

Run with: `flutter test test/counter_ui_test.dart`

### `app_intents_integration_test.dart` 
**Flutter App Intents integration tests**

Tests integration between counter app and flutter_app_intents package:
- Package component accessibility and demonstrations
- Intent builder functionality and patterns
- Model class usage (AppIntent, AppIntentParameter, AppIntentResult, AppIntentBuilder)
- Platform-specific behavior handling
- FlutterAppIntentsClient singleton usage
- Best practices for voice commands and Siri integration

Run with: `flutter test test/app_intents_integration_test.dart`

### `models_validation_test.dart`
**Models and validation tests**

Tests error handling, model validation, and data integrity:
- FlutterAppIntentsException creation and handling
- Model validation for AppIntent, AppIntentParameter, AppIntentResult
- Builder validation and method chaining
- Service error handling on non-iOS platforms
- Data integrity and serialization round-trips
- Equality contracts and copyWith functionality

Run with: `flutter test test/models_validation_test.dart`

### `intent_donation_test.dart`
**Intent donation functionality tests**

Tests enhanced intent donation features:
- IntentDonation factory constructors (highRelevance, mediumRelevance, etc.)
- Relevance score validation and handling
- Metadata and context management
- Batch donation functionality
- Performance with large parameter sets
- Special character handling in identifiers
- Integration with existing donation APIs

Run with: `flutter test test/intent_donation_test.dart`

## Running All Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/counter_ui_test.dart
flutter test test/app_intents_integration_test.dart
flutter test test/models_validation_test.dart
flutter test test/intent_donation_test.dart

# Run tests in watch mode
flutter test --watch
```

## Test Coverage

The tests cover:

✅ **Core App Functionality** - Counter increment, UI display, theme handling
✅ **Flutter App Intents Integration** - Package usage, model demonstrations
✅ **Error Handling** - Platform limitations, invalid inputs, edge cases
✅ **Intent Donations** - Enhanced donation API, relevance scoring, batching
✅ **Model Validation** - Serialization, equality, builder patterns
✅ **Platform Behavior** - iOS vs non-iOS handling, appropriate error messages
✅ **Performance** - Large datasets, special characters, edge cases

## Test Structure

```
test/
├── README.md                      # This file
├── counter_ui_test.dart          # UI widget tests for counter app
├── app_intents_integration_test.dart # Flutter App Intents integration tests  
├── models_validation_test.dart   # Models and validation tests
└── intent_donation_test.dart     # Intent donation functionality tests
```

## Key Test Scenarios

### App Functionality
- Counter starts at 0 and increments correctly
- Floating action button works properly
- Status messages display appropriately
- App handles different screen sizes
- Siri command examples are shown to users

### Flutter App Intents Integration
- Models (AppIntent, AppIntentParameter, AppIntentResult) work correctly
- Builder patterns function as expected
- Client singleton operates properly
- Platform-specific behavior handled gracefully

### Error Handling
- Invalid parameters handled gracefully
- Non-iOS platforms show appropriate warnings
- Service methods throw correct exceptions
- Data serialization maintains integrity

### Enhanced Donations
- Factory constructors create correct relevance scores
- Metadata and context preserved properly
- Batch donations handle multiple intents
- Performance acceptable with large datasets
- Special characters and Unicode supported

### Platform Support
- iOS-only functionality clearly identified
- Non-iOS platforms receive helpful error messages
- App continues functioning despite platform limitations
- Developer guidance provided for cross-platform usage

These tests ensure the counter example demonstrates proper flutter_app_intents usage patterns and provides a reliable foundation for developers building App Intents functionality.