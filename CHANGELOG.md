# Changelog

All notable changes to the Flutter App Intents package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.7.0] - 2025-10-02

### Fixed
- **Thread Safety**: Added concurrent dispatch queue for thread-safe access to shared state
  - Implemented `intentQueue` with `.concurrent` attribute and `.barrier` flags for writes
  - Protected `registeredIntents` and `activeIntents` dictionaries from race conditions
  - All dictionary reads now use `.sync` and writes use `.async(flags: .barrier)`
  - Eliminates potential crashes from concurrent access during intent registration/execution
- **Intent Donation**: Fixed DonationManager to properly handle AppIntent donations
  - Implemented actual donation logic for AppIntents using INInteraction API
  - Added `createLegacyIntentFromAppIntent` method to convert AppIntents for donation
  - Enhanced donation with proper async/await continuation handling
  - Added detailed logging with relevance scores and error messages
  - Fixed non-functional donation path that was only printing without donating
- **Relevance Score Calculation**: Fixed calculateRelevanceScore logic bug
  - Changed base score from 1.0 to 0.5 to allow proper score range (0.5-1.0)
  - Fixed score clamping issue where all scores were being reduced back to 1.0
  - Enables proper Siri learning with varied relevance scores for better predictions

### Removed
- **Non-Functional Code**: Removed `ios/Runner/AppShortcuts.swift`
  - File attempted dynamic shortcut registration which is not supported by iOS
  - iOS requires AppShortcuts to be statically defined at compile time
  - Examples correctly use static AppIntent definitions in AppDelegate.swift
  - Removal simplifies codebase and eliminates confusion about architecture

### Technical Improvements
- **Concurrency**: Enhanced thread safety across all platform channel methods
- **Error Handling**: Improved error reporting in donation system with specific failure messages
- **Code Quality**: Removed dead code that created architectural confusion
- **Performance**: Optimized concurrent dictionary access with proper synchronization primitives

## [0.6.0] - 2025-09-12

### Added
- **Swift Package Manager Support**: Full SPM integration for advanced iOS development
  - `Package.swift` configuration file with proper iOS 16.0+ platform support
  - SPM-specific documentation (`SPM_README.md`) with installation and usage instructions
  - Website documentation page for Swift Package Manager integration
  - Support for both Xcode Package Dependencies and Package.swift inclusion
- **Enhanced Documentation Website**: Comprehensive Swift Package Manager documentation
  - New dedicated SPM page in website documentation
  - Updated installation instructions across all documentation pages
  - Clear guidance on when to use SPM vs standard Flutter plugin installation

### Fixed
- **Security Vulnerabilities**: Resolved webpack-dev-server security issues
  - Updated webpack-dev-server from vulnerable 4.15.2 to secure 5.2.2 via npm overrides
  - Fixed CVE-2025-30359 vulnerabilities in development dependencies
  - Zero security vulnerabilities now reported by npm audit
- **Website Navigation Issues**: Fixed GitHub repository URL redirects
  - Corrected navbar GitHub link from christophebonello to cbonello repository
  - Fixed footer GitHub link to point to correct repository
  - Fixed documentation edit links to correct repository
  - Fixed broken logo display in documentation pages
- **CI/CD Pipeline**: Removed failing CI workflow, keeping website deployment
  - Removed problematic ci.yml workflow that was causing analyze phase errors
  - Maintained deploy-docs.yml for reliable GitHub Pages deployment
  - Simplified CI/CD pipeline focused on documentation deployment

### Infrastructure
- **Git Configuration**: Added Swift Package Manager build directories to .gitignore
  - Added `.build/` and `.swiftpm/` to prevent SPM build artifacts from being committed
  - Maintains clean repository while supporting SPM development workflows
- **Package Management**: Updated all documentation to reference version 0.6.0
  - Updated version numbers across README, documentation, and Package.swift
  - Consistent version references in all installation instructions

## [0.5.0] - 2025-09-10

### Added
- **Weather Example - Query & Data Pattern**: Complete third example demonstrating background data queries
  - Background weather information retrieval without opening app
  - Voice responses optimized for Siri speech with `ProvidesDialog`
  - Multiple parameter types: location (string), days (integer), optional parameters
  - Boolean queries with yes/no voice responses (rain checks)
  - Multi-day forecast queries with formatted voice output
  - Query intent pattern using `needsToContinueInApp: false` for background operation
- **Complete App Intent Pattern Coverage**: Now includes all three core patterns
  - Action Intents (Counter example) - perform app operations
  - Navigation Intents (Navigation example) - deep linking and routing  
  - Query Intents (Weather example) - background data retrieval with voice responses
- **Comprehensive Test Suite**: Weather example includes 21 passing tests
  - Mock implementations for all intent handlers
  - Parameter validation and error handling tests
  - Data formatting and response generation tests
  - AppIntentResult creation and conversion tests
- **Enhanced Documentation**: Complete integration across all documentation
  - Updated main README with all three examples
  - New comprehensive Examples page on website with pattern comparison
  - Updated Getting Started guide and website navigation
  - Screenshots placeholder structure for weather example

### Enhanced
- **Examples Organization**: Improved structure and categorization
  - Clear intent type classifications (Action, Navigation, Query)
  - Detailed feature lists and learning objectives for each example
  - Comparison table showing use cases and return types
  - Enhanced architectural explanations with background operation patterns

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