# Swift Package Manager Support for Flutter App Intents

This package provides Swift Package Manager (SPM) support for the Flutter App Intents plugin, allowing iOS developers to use the native Swift components directly in their projects.

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

This SPM package is primarily designed to work alongside Flutter projects. The native Swift code provides the iOS App Intents integration that communicates with your Flutter app.

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

⚠️ **Flutter Framework Dependency**: This package requires the Flutter framework to be available in your iOS project. The Swift code imports Flutter and uses FlutterMethodChannel for communication. Make sure your project includes Flutter through the standard Flutter iOS integration.

⚠️ **Build Requirements**: This package will not build in isolation using `swift build` because it depends on the Flutter framework. It's designed to be used within Xcode projects that already have Flutter integrated.

⚠️ **Primary Use Case**: This SPM package is provided for advanced use cases and iOS-specific integrations where you want to manage the native Swift dependencies separately. Most Flutter developers should use the standard plugin installation method through `pubspec.yaml`.

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

Then follow the setup instructions in the main [README](README.md).

## Documentation

- [Main Documentation](README.md) - Complete plugin documentation
- [Flutter Integration Guide](https://cbonello.github.io/flutter_app_intents/docs/getting-started) - Flutter-specific setup
- [iOS Configuration](https://cbonello.github.io/flutter_app_intents/docs/ios-configuration) - Native iOS setup guide

## Support

For issues and questions:
- [GitHub Issues](https://github.com/cbonello/flutter_app_intents/issues)
- [Documentation Website](https://cbonello.github.io/flutter_app_intents/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.