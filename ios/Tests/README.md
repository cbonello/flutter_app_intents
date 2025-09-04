# iOS Tests for Flutter App Intents Plugin

This directory contains comprehensive unit tests for the iOS native implementation of the Flutter App Intents plugin.

## Test Structure

- `FlutterAppIntentsPluginTests.swift` - Complete test suite for the iOS Swift implementation
- `Info.plist` - Bundle configuration for the test target

## What's Tested

### Intent Protocol Conformance ✅
- `NoParameterIntent` - Tests AppIntent protocol conformance, execution, and both initializers
- `OneStringParameterIntent` - Tests string parameter handling and default initialization
- `OneIntegerParameterIntent` - Tests integer parameter handling and protocol conformance
- `OneBooleanParameterIntent` - Tests boolean parameter handling and initialization
- `OneDoubleParameterIntent` - Tests double parameter handling and AppIntent compliance

### Factory and Support Classes ✅
- `DynamicAppIntentFactory` - Tests intent creation based on parameter types and edge cases
- `AppIntentParameterInfo` - Tests parameter parsing, validation, and error handling
- `AppIntentParameterType` - Tests type conversion, Swift type mapping, and unknown type handling
- `DonationMetadata` - Tests metadata handling, validation, and relevance score clamping
- `IntentExecutionError` - Tests error types, descriptions, and custom error messages

### Plugin Integration ✅
- Plugin singleton instance verification
- Default initializer compatibility with iOS 16+ AppIntent framework
- AppIntent protocol conformance for all intent types
- Intent identifier handling for both custom and default initialization

## Running the Tests

### Option 1: Through Xcode (Recommended)
1. Open the example project in Xcode: `example/ios/Runner.xcworkspace`
2. In Xcode, go to File → New → Target
3. Choose "Unit Testing Bundle" 
4. Set Target Name: "FlutterAppIntentsPluginTests"
5. Add the test files from this directory to the test target
6. Add `flutter_app_intents` as a dependency to the test target
7. Run tests with ⌘+U or through the Test Navigator

### Option 2: Command Line
```bash
# From the example/ios directory
xcodebuild test -workspace Runner.xcworkspace -scheme Runner -destination 'platform=iOS Simulator,name=iPhone 14'
```

## Test Requirements

- iOS 16.0+ (required by AppIntents framework)
- Xcode 14.0+
- The tests use `@testable import flutter_app_intents` to access internal classes

## Recent Updates

### Fixed AppIntent Protocol Conformance ✅
- Added proper `perform()` method implementations for all intent types
- Added default `init()` initializers for iOS 16+ AppIntent framework compatibility
- Fixed IntentResult return type consistency issues

### Modernized iOS Integration ✅
- Updated to use iOS 16+ automatic AppShortcuts management
- Removed deprecated INInteraction property assignments
- Simplified donation system for modern AppIntents

### Enhanced Test Coverage ✅
- Added tests for default initializers
- Added plugin integration tests
- Verified AppIntent protocol conformance for all intent types

## Notes

- Tests that involve actual intent execution will fail in the unit test environment since they require a Flutter method channel
- The tests focus on protocol conformance, object creation, and data validation
- Full integration testing should be done through the Dart test suite or manual testing in the example app
- All tests are compatible with iOS 16+ and the modern AppIntents framework
- Default initializers are tested to ensure compatibility with Xcode's AppIntent requirements