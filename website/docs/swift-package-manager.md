---
sidebar_position: 8
---

# Swift Package Manager

This package provides Swift Package Manager (SPM) support for advanced iOS developers who want to manage the native Swift components directly in their projects.

## Requirements

- iOS 16.0 or later
- Xcode 14.0 or later
- Swift 5.9 or later

## Installation

### Adding to Xcode Project

1. In Xcode, select **File → Add Package Dependencies**
2. Enter the repository URL: `https://github.com/cbonello/flutter_app_intents`
3. Select the version or branch you want to use
4. Click **Add Package**

### Adding to Package.swift

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/cbonello/flutter_app_intents", from: "0.6.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "FlutterAppIntents", package: "flutter_app_intents")
        ]
    )
]
```

## Usage with Flutter Projects

This SPM package is designed to work alongside Flutter projects. The native Swift code provides the iOS App Intents integration that communicates with your Flutter app.

### Integration Steps

1. **Add the Swift Package** to your iOS project using the instructions above
2. **Configure your Flutter app** to use the flutter_app_intents plugin
3. **Implement static App Intents** in your iOS target using the provided Swift classes
4. **Register Flutter handlers** for the intents in your Flutter code

### Example Implementation

```swift
import FlutterAppIntents
import AppIntents

@available(iOS 16.0, *)
struct MyAppIntent: AppIntent {
    static var title: LocalizedStringResource = "My App Intent"
    static var description = IntentDescription("Description of what this intent does")
    static var openAppWhenRun = true
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & OpensIntent {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "my_intent_id",
            parameters: [:]
        )
        
        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Intent executed"
            return .result(value: value)
        } else {
            let errorMessage = result["error"] as? String ?? "Intent failed"
            throw AppIntentError.executionFailed(errorMessage)
        }
    }
}
```

## Important Notes

⚠️ **Flutter Framework Dependency**: This package requires the Flutter framework to be available in your iOS project. The Swift code imports Flutter and uses FlutterMethodChannel for communication.

⚠️ **Build Requirements**: This package will not build in isolation using `swift build` because it depends on the Flutter framework. It's designed to be used within Xcode projects that already have Flutter integrated.

⚠️ **Primary Use Case**: SPM support is provided for advanced use cases and iOS-specific integrations where you want to manage the native Swift dependencies separately. Most Flutter developers should use the standard plugin installation.

## Standalone Building

Note that running `swift build` on this package will fail with:
```
error: no such module 'Flutter'
```

This is expected behavior. The package is designed to work within the context of a Flutter-enabled iOS project.

## Standard Flutter Plugin Installation

For most Flutter developers, use the standard plugin installation:

```yaml
dependencies:
  flutter_app_intents: ^0.7.0
```

Then follow the setup instructions in the [Getting Started](getting-started) guide.

## When to Use SPM vs Flutter Plugin

| Use Case | Installation Method | Best For |
|----------|-------------------|----------|
| **Standard Flutter App** | Flutter Plugin (`pubspec.yaml`) | Most developers |
| **Advanced iOS Integration** | Swift Package Manager | iOS developers who need native Swift control |
| **Hybrid Projects** | Both (SPM for native, Plugin for Flutter) | Complex architectures |
| **Pure iOS Apps** | Not applicable | Use native App Intents framework directly |

## Support

For issues and questions:
- [GitHub Issues](https://github.com/cbonello/flutter_app_intents/issues)
- [Documentation Website](https://cbonello.github.io/flutter_app_intents/)