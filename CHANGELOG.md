# Changelog

All notable changes to the Flutter App Intents package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0] - 2025-09-09

### Added
- **Brand Identity**: Complete visual branding overhaul with custom logo design
  - Flutter App Intents logo combining Flutter bird with iOS voice/microphone elements
  - Cohesive blue color scheme (#007AFF iOS blue, #02569B Flutter blue)
  - Custom feature icons: microphone (Siri), lightning bolt (Shortcuts), shield (Type-Safe API)
- **Website Enhancement**: Comprehensive Docusaurus website improvements
  - Custom logo integration in navbar and hero section
  - Blue color theme replacing default green
  - Professional homepage with branded feature icons
  - Enhanced visual hierarchy and drop shadows
- **Documentation Screenshots**: Visual documentation with example screenshots
  - Counter example: App interface, iOS Shortcuts, Siri integration screenshots
  - Side-by-side table layout for better visual organization
  - Proper image sizing and responsive design

### Enhanced
- **Website Design**: Complete visual redesign
  - Replaced default Docusaurus illustrations with custom branded icons
  - Improved CTA button styling with white background and blue text
  - Logo drop shadows for depth and professional appearance
  - Optimized image sizes for better performance
- **Documentation Quality**: Improved example documentation
  - Added comprehensive Screenshots sections to example READMEs
  - Visual walkthrough of App Intents functionality
  - Table-based layout for better space utilization
- **Asset Management**: Clean and organized static assets
  - Removed unused default Docusaurus images
  - Optimized website static directory structure
  - Consistent naming conventions for branding assets

### Improved
- **User Experience**: Enhanced developer onboarding
  - Visual examples showing actual app interfaces
  - Clear demonstration of Siri integration workflow
  - Professional presentation increasing confidence in the package
- **Brand Consistency**: Unified visual identity across all documentation
  - Consistent blue color palette throughout
  - Matching feature icons and main logo design
  - Professional appearance suitable for production use

## [0.3.0] - 2025-09-07

### Fixed
- Addressed linter warnings to improve code quality and maintainability
- Removed misleading `phrases()` method from `AppIntentBuilder` that was non-functional
- Updated all examples to use proper Swift `AppShortcut` phrase implementation
- Clarified documentation about how phrases actually work in iOS App Intents

## [0.2.0] - 2025-09-05

### Added
- **Enhanced Intent Donation API**: New `IntentDonation` class with factory constructors for different relevance levels
  - `IntentDonation.highRelevance()` for user-initiated actions (0.8-1.0 relevance)
  - `IntentDonation.mediumRelevance()` for contextual suggestions (0.4-0.7 relevance)  
  - `IntentDonation.lowRelevance()` for background/automated actions (0.1-0.3 relevance)
  - `IntentDonation.userInitiated()` and `IntentDonation.automated()` convenience constructors
- **Metadata and Context Support**: Enhanced donation with metadata and context information for better Siri learning
- **Batch Donation Functionality**: Support for donating multiple related intents efficiently
- **Loading Indicator Documentation**: Added comprehensive guidance on handling long-running operations in App Intents
- **Navigation Example**: Complete navigation app demonstrating route handling, parameter passing, and deep linking
- **Counter Example Documentation**: Enhanced counter example with better integration patterns

### Enhanced
- **Documentation**: Updated README with extensive best practices including:
  - Long-running operations and loading states guidance
  - Navigation intent patterns and deep linking
  - Intent donation strategies with relevance scoring
  - Platform-specific behavior handling
  - Error handling and app integration patterns
- **Test Coverage**: Comprehensive test suites for both examples:
  - **Navigation Example**: 45 focused tests across 3 well-organized files
    - `parameter_logic_test.dart`: Unit tests for intent parameter handling
    - `page_widgets_test.dart`: UI widget tests for all navigation pages  
    - `navigation_flows_test.dart`: End-to-end navigation flow tests
  - **Counter Example**: 95+ tests across 4 specialized files
    - `counter_ui_test.dart`: UI widget tests for counter app
    - `app_intents_integration_test.dart`: Flutter App Intents integration tests
    - `models_validation_test.dart`: Models and validation tests
    - `intent_donation_test.dart`: Intent donation functionality tests
- **Example Apps**: Both examples now include comprehensive test documentation with clear running instructions

### Improved  
- **Test Organization**: Consolidated and renamed test files with descriptive, purpose-driven names
- **File Structure**: Clean separation of concerns across test files (UI → integration → logic)
- **Developer Experience**: Clear test file names that immediately indicate what each file tests
- **Maintainability**: Eliminated redundant tests and improved test focus
- **Error Handling**: Enhanced validation and edge case handling across models

### Fixed
- **Test Reliability**: Fixed multiple test failures across both examples:
  - Navigation example: Fixed text assertions, icon types, and widget finder conflicts
  - Counter example: Addressed platform-specific test issues and UI rendering edge cases
- **Icon Consistency**: Updated icon references to match actual implementations (`Icons.chat` → `Icons.chat_bubble`)
- **Text Assertions**: Corrected text expectations to match actual UI content
- **Widget Structure**: Resolved multiple widget finder conflicts in tests

### Technical Improvements
- **Intent Donation**: Enhanced with proper relevance scoring (0.0-1.0 range validation)
- **Performance**: Optimized for large parameter sets and special character handling
- **Serialization**: Improved data integrity and round-trip serialization
- **Error Messages**: More descriptive error handling and validation feedback
- **Platform Handling**: Better iOS vs non-iOS platform behavior management

### Breaking Changes
- **Test File Structure**: Renamed test files for clarity - developers may need to update any references to old test file names

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