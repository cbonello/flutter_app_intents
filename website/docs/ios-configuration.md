---
sidebar_position: 3
---

# iOS Configuration

## Required Setup: Static App Intents in Main App Target

**⚠️ Important**: iOS App Intents framework requires static intent declarations in your main app target, not just dynamic registration from the plugin. 

Add this code to your iOS app's `AppDelegate.swift`:

```swift
import Flutter
import UIKit
import AppIntents
import flutter_app_intents

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// Static App Intents that bridge to Flutter handlers
@available(iOS 16.0, *)
struct MyCounterIntent: AppIntent {
    static var title: LocalizedStringResource = "Increment Counter"
    static var description = IntentDescription("Increment the counter by one")
    static var isDiscoverable = true
    static var openAppWhenRun = true
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & OpensIntent {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "increment_counter", 
            parameters: [:]
        )
        
        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Counter incremented"
            return .result(value: value)
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to increment counter"
            throw AppIntentError.executionFailed(errorMessage)
        }
    }
}

// Error handling for App Intents
enum AppIntentError: Error {
    case executionFailed(String)
}

// AppShortcutsProvider for Siri/Shortcuts discovery
@available(iOS 16.0, *)
struct AppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
            AppShortcut(
                intent: MyCounterIntent(),
                phrases: [
                    "Increment counter with ${applicationName}",
                    "Add one with ${applicationName}",
                    "Count up using ${applicationName}"
                ]
            )
        ]
    }
}
```

## Info.plist Configuration

Add these permissions and configuration to your iOS `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app uses microphone for Siri integration</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app uses speech recognition for Siri integration</string>

<!-- App Intents Configuration -->
<key>NSAppIntentsConfiguration</key>
<dict>
    <key>NSAppIntentsPackage</key>
    <string>your_app_bundle_id</string>
</dict>
<key>NSAppIntentsMetadata</key>
<dict>
    <key>NSAppIntentsSupported</key>
    <true/>
</dict>
```

## Minimum Deployment Target

Ensure your iOS deployment target is set to 16.0 or later:

```ruby
# ios/Podfile
platform :ios, '16.0'
```

## Navigation Intent Example

For navigation intents that should open your app, use this pattern:

```swift
@available(iOS 16.0, *)
struct OpenProfileIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Profile"
    static var description = IntentDescription("Open user profile page")
    static var isDiscoverable = true
    static var openAppWhenRun = true
    
    @Parameter(title: "User ID")
    var userId: String?
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & OpensIntent {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "open_profile",
            parameters: ["userId": userId ?? "current"]
        )
        
        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Profile opened"
            return .result(value: value) // This opens/focuses the app
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to open profile"
            throw AppIntentError.executionFailed(errorMessage)
        }
    }
}
```

## Adding App Shortcuts

Add navigation shortcuts to your `AppShortcutsProvider`:

```swift
@available(iOS 16.0, *)
struct AppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
            // Navigation shortcuts
            AppShortcut(
                intent: OpenProfileIntent(),
                phrases: [
                    "Open my profile in ${applicationName}",
                    "Show profile using ${applicationName}",
                    "Go to profile with ${applicationName}"
                ]
            ),
            AppShortcut(
                intent: OpenChatIntent(),
                phrases: [
                    "Chat with \\(.contactName) using ${applicationName}",
                    "Open chat with \\(.contactName) in ${applicationName}",
                    "Message \\(.contactName) with ${applicationName}"
                ]
            )
        ]
    }
}
```

## Important Notes

- **Static intents must match Flutter handlers** - ensure identifier consistency
- **Architecture Note**: iOS App Intents framework requires static intent declarations at compile time for Siri/Shortcuts discovery. Dynamic registration from Flutter plugins alone is not sufficient.
- Always use `openAppWhenRun = true` for intents that should open your app
- Use `ReturnsValue<String> & OpensIntent` return type for intents that open the app