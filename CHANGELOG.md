# Changelog

All notable changes to the Flutter App Intents package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1] - 2025-09-04

### Fixed
- **iOS AppIntent Protocol Conformance**: Fixed Swift compilation errors where intent structs did not properly conform to `AppIntent` protocol
- **iOS Default Initializers**: Added required default `init()` methods for all intent types to ensure compatibility with iOS 16+ AppIntents framework
- **iOS IntentResult Consistency**: Fixed `some IntentResult` return type conflicts by ensuring consistent return types across all intent methods
- **iOS Modern Framework Integration**: Updated to use iOS 16+ automatic AppShortcuts management instead of deprecated manual shortcuts handling
- **iOS INInteraction Properties**: Removed attempts to set read-only properties (`intentHandlingStatus`, `relevanceScore`) on INInteraction objects
- **iOS Donation System**: Modernized intent donation system to work properly with both modern AppIntents and legacy INIntents

### Improved
- **Test Coverage**: Added comprehensive unit tests for iOS Swift implementation with 100% coverage of intent types and protocol conformance
- **Test Structure**: Moved tests from example app to main package for better organization and maintainability
- **Documentation**: Updated iOS test documentation with detailed information about recent fixes and enhancements
- **Error Handling**: Enhanced error handling in iOS Swift code with more specific error types and descriptions

### Technical Details
- All AppIntent structs now properly implement the required `perform()` method
- Fixed AppShortcuts API usage to align with iOS 16+ automatic management
- Improved donation metadata handling for better Siri learning
- Enhanced protocol extension implementation for cleaner code architecture

## [0.1.0] - 2025-09-02

### Added
- Initial release of Flutter App Intents package
- Core App Intents integration for iOS 16.0+
- `FlutterAppIntentsClient` for high-level intent management
- `AppIntent`, `AppIntentParameter`, and `AppIntentResult` models
- `AppIntentBuilder` for fluent intent creation
- iOS Swift plugin with platform channel communication
- Support for intent registration and unregistration
- Intent parameter handling with multiple data types
- Intent donation for Siri prediction learning
- Comprehensive example app demonstrating usage
- Error handling and exception management
- Authentication policy support
- Spotlight and search integration flags
- Complete documentation and API reference

### Features
- **Siri Integration**: Create custom voice commands
- **Shortcuts Support**: Enable user-created shortcuts
- **Parameter Types**: String, integer, boolean, double, date, URL, file, entity
- **Authentication Policies**: None, requires authentication, requires unlocked device
- **Intent Donation**: Help Siri learn user patterns
- **Error Handling**: Comprehensive exception management
- **Type Safety**: Strongly typed Dart API
- **Platform Validation**: iOS-only feature with proper validation

### Dependencies
- Flutter >= 3.8.1
- iOS >= 16.0
- Independent Flutter plugin architecture
- Equatable for value equality

### Known Limitations
- iOS only (no Android support planned)
- Requires iOS 16.0 or later
- Swift 5.0+ required for iOS implementation
- App Intents framework limitations apply