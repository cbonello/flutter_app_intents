# Navigation Example Tests

This directory contains comprehensive tests for the navigation App Intents example.

## Test Files

### `parameter_logic_test.dart`
**Unit tests for intent parameter handling logic**

Tests the core logic for processing App Intent parameters:
- Parameter extraction and validation
- Default value handling for missing/null parameters
- AppIntentResult creation and success/failure scenarios
- Route argument preparation and formatting

Run with: `flutter test test/parameter_logic_test.dart`

### `page_widgets_test.dart`
**UI widget tests for all navigation pages**

Tests the rendering and content of navigation page widgets:
- ProfilePage, ChatPage, SearchPage, SettingsPage widget rendering
- NavigationHomePage UI components and buttons
- Parameter-based content display
- App route configuration
- Widget structure validation

Run with: `flutter test test/page_widgets_test.dart`

### `navigation_flows_test.dart`
**End-to-end navigation flow tests**

Tests complete navigation scenarios and flows:
- Route navigation with arguments and parameter passing
- Deep link handling and direct route access
- Error handling for missing/null arguments
- Back navigation behavior
- App startup and initialization flows

Run with: `flutter test test/navigation_flows_test.dart`

## Running All Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/parameter_logic_test.dart
flutter test test/page_widgets_test.dart
flutter test test/navigation_flows_test.dart

# Run tests in watch mode
flutter test --watch
```

## Test Coverage

The tests cover:

✅ **Intent Logic** - Parameter handling, validation, defaults
✅ **UI Components** - All navigation pages render correctly
✅ **Navigation Flow** - Route navigation with arguments
✅ **Error Handling** - Missing/null parameters, invalid routes
✅ **User Interactions** - Button presses, navigation actions
✅ **Deep Linking** - Direct route access with parameters

## Test Structure

```
test/
├── README.md                    # This file
├── parameter_logic_test.dart   # Unit tests for intent parameter handling logic  
├── page_widgets_test.dart      # UI widget tests for all navigation pages
└── navigation_flows_test.dart  # End-to-end navigation flow tests
```

## Key Test Scenarios

### Parameter Handling
- Valid parameters passed through intents
- Missing parameters use defaults
- Null parameters handled gracefully
- Empty string parameters processed correctly

### Navigation Testing  
- Manual button navigation works
- Route navigation with arguments
- Back navigation returns to previous page
- Deep links open correct pages

### UI Validation
- All pages display expected content
- Parameters appear in UI correctly
- Intent indicators show on pages
- App bars and navigation elements present

### Error Scenarios
- Missing route arguments use defaults
- Null arguments handled gracefully
- Invalid navigation handled properly
- App continues functioning after errors

These tests ensure the navigation example works correctly across all use cases and provides confidence when making changes to the codebase.