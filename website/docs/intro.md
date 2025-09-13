---
sidebar_position: 1
---

# Flutter App Intents

<p align="center">
  <img src="/flutter_app_intents/img/logo.png" alt="Flutter App Intents Logo" width="200" height="200" />
</p>

A Flutter plugin for integrating Apple App Intents with your iOS applications. This package provides a streamlined way to define, register, and handle custom intents, enabling powerful integrations with Siri and the Shortcuts app.

## Features

- **Siri Integration**: Create custom voice commands for your app's actions.
- **Shortcuts Support**: Allow users to create and manage shortcuts for your app's functionality.
- **Modern iOS Support**: Built for iOS 16+ using the latest AppIntents framework.
- **Type-Safe API**: A strongly-typed Dart API for defining intents and parameters.
- **Intent Donation**: Proactively donate intents to the system for predictive suggestions.
- **Error Handling**: Comprehensive exception management for robust integrations.
- **Detailed Documentation**: Includes extensive documentation and example apps.

## Getting Started

### Flutter Plugin Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_app_intents: ^0.6.0
```

### Swift Package Manager (Advanced)

For iOS developers who want to use the native Swift components directly, this package also supports Swift Package Manager:

**Via Xcode:** File → Add Package Dependencies → `https://github.com/cbonello/flutter_app_intents`

**Via Package.swift:**
```swift
dependencies: [
    .package(url: "https://github.com/cbonello/flutter_app_intents", from: "0.6.0")
]
```

> **Note:** SPM support is provided for advanced use cases. Most Flutter developers should use the standard plugin installation above.

Then, follow the instructions in the [Getting Started](getting-started) guide to set up and use the plugin.

## Examples

This package includes three example apps:
- **Counter**: A simple app demonstrating action-based intent registration and handling.
- **Navigation**: A navigation app showcasing deep linking, parameter passing, and multi-page routing.
- **Weather**: A query app demonstrating background data queries with voice responses and Siri speech output.

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue.