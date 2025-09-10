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
                    "Increment counter with \(.applicationName)",
                    "Add one with \(.applicationName)",
                    "Count up using \(.applicationName)"
                ],
                shortTitle: "Increment",
                systemImageName: "plus.circle"
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

## App Shortcuts Phrase Best Practices

When defining phrases for your App Shortcuts, follow these best practices for optimal user experience and Siri recognition:

### ⚠️ Important Limitation: Static Phrases Only

**App Shortcuts phrases CANNOT be defined dynamically.** This is a fundamental limitation of Apple's App Intents framework:

```swift
// ❌ DOES NOT WORK - phrases must be static literals
phrases: [
    "\(userDefinedPhrase) with \(.applicationName)",     // Won't compile
    dynamicPhraseVariable,                               // Won't compile
    generatePhrase()                                     // Won't compile
]

// ✅ WORKS - static phrases with dynamic parameters
phrases: [
    "Send message to \(.contactName) with \(.applicationName)",    // ✅ Parameter is dynamic
    "Set timer for \(.duration) using \(.applicationName)",       // ✅ Parameter is dynamic
    "Play \(.songName) in \(.applicationName)"                    // ✅ Parameter is dynamic
]
```

**Why phrases must be static:**
- **Compile-time registration**: iOS requires phrases for Siri's speech recognition engine at build time
- **App Store review**: Apple analyzes all possible voice commands during app review
- **Performance**: Siri's recognition is optimized based on the known phrase list
- **Security**: Prevents apps from creating potentially malicious or conflicting commands dynamically

### 📊 Phrase Quantity Limits and Guidelines

While Apple doesn't publish exact hard limits, there are practical constraints on the number of phrases:

**Recommended Limits:**
- **Per AppShortcut**: 3-5 phrases (optimal), up to 8 phrases (maximum recommended)
- **Total per app**: 50-100 phrases across all shortcuts (practical limit)
- **Quality over quantity**: Focus on natural, distinct variations rather than exhaustive lists

```swift
// ✅ GOOD - Focused, natural variations (4 phrases)
AppShortcut(
    intent: SendMessageIntent(),
    phrases: [
        "Send message to \(.contactName) with \(.applicationName)",
        "Text \(.contactName) using \(.applicationName)",
        "Message \(.contactName) in \(.applicationName)",
        "Write to \(.contactName) with \(.applicationName)"
    ]
)

// ❌ EXCESSIVE - Too many similar phrases (impacts performance)
AppShortcut(
    intent: SendMessageIntent(),
    phrases: [
        "Send message to \(.contactName) with \(.applicationName)",
        "Send a message to \(.contactName) with \(.applicationName)",
        "Send text message to \(.contactName) with \(.applicationName)",
        "Send a text message to \(.contactName) with \(.applicationName)",
        // ... 15+ more variations
    ]
)
```

### Include App Name for Disambiguation

**✅ Recommended:**
```swift
phrases: [
    "Increment counter with \(.applicationName)",
    "Add one using \(.applicationName)",
    "Count up in \(.applicationName)"
]
```

**❌ Avoid:**
```swift
phrases: [
    "Increment counter",  // Too generic, conflicts with other apps
    "Add one"             // Ambiguous without context
]
```

### Use Natural Prepositions

Choose prepositions that sound natural in conversation:
- **"with \(.applicationName)"** - Most common, works for actions
- **"using \(.applicationName)"** - Good for tool-like actions  
- **"in \(.applicationName)"** - Natural for location-based commands
- **"from \(.applicationName)"** - Perfect for queries and data retrieval

### Provide Multiple Variations

Offer 3-5 phrase variations to accommodate different user preferences:
```swift
phrases: [
    "Increment counter with \(.applicationName)",      // Formal
    "Add one using \(.applicationName)",               // Casual
    "Count up in \(.applicationName)",                 // Alternative verb
    "Bump counter with \(.applicationName)",           // Colloquial
    "Increase count using \(.applicationName)"         // Descriptive
]
```

### Keep Phrases Concise but Descriptive

- **Ideal length**: 3-6 words (excluding app name)
- **Be specific**: "Increment counter" vs. "Do something"
- **Avoid filler words**: Skip "please", "can you", "I want to"

### Common Phrase Patterns by Intent Type

**Action Intents:**
```swift
"[Action] [Object] with \(.applicationName)"
"[Verb] [Noun] using \(.applicationName)"
```

**Query Intents:**
```swift
"Get [Data] from \(.applicationName)"
"Check [Status] in \(.applicationName)"
"What's [Information] using \(.applicationName)"
```

**Navigation Intents:**
```swift
"Open [Page] in \(.applicationName)"
"Go to [Section] using \(.applicationName)"
"Show [Content] with \(.applicationName)"
```

### Testing Your Phrases

- **Test with Siri**: Speak each phrase to ensure recognition
- **Try variations**: Users might not say exactly what you expect
- **Check conflicts**: Ensure phrases don't overlap with system commands
- **User feedback**: Monitor which phrases users actually use

## Important Notes

- **Static intents must match Flutter handlers** - ensure identifier consistency
- **Architecture Note**: iOS App Intents framework requires static intent declarations at compile time for Siri/Shortcuts discovery. Dynamic registration from Flutter plugins alone is not sufficient.
- Always use `openAppWhenRun = true` for intents that should open your app
- Use `ReturnsValue<String> & OpensIntent` return type for intents that open the app