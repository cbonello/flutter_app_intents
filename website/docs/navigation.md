---
sidebar_position: 4
---

# Navigation with App Intents

Our plugin excels at handling app navigation through voice commands and shortcuts. This guide shows you how to implement navigation intents effectively.

## Navigation Intent Pattern

For navigation, use `needsToContinueInApp: true` to tell iOS to focus your app and `OpensIntent` return type in Swift:

### iOS Implementation

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

### Flutter Handler

```dart
Future<AppIntentResult> _handleOpenProfileIntent(
  Map<String, dynamic> parameters,
) async {
  final userId = parameters['userId'] as String? ?? 'current';
  
  // Navigate to the target page
  Navigator.of(context).pushNamed('/profile', arguments: {'userId': userId});
  
  return AppIntentResult.successful(
    value: 'Opening profile for user $userId',
    needsToContinueInApp: true, // Critical: focuses the app
  );
}
```

## Common Navigation Patterns

### 1. Deep Linking with Parameters

```dart
// Navigate to specific content with parameters
Future<AppIntentResult> _handleOpenChatIntent(Map<String, dynamic> parameters) async {
  final contactName = parameters['contactName'] as String;
  
  Navigator.of(context).pushNamed('/chat', arguments: {
    'contactName': contactName,
    'openedViaIntent': true,
  });
  
  return AppIntentResult.successful(
    value: 'Opening chat with $contactName',
    needsToContinueInApp: true,
  );
}
```

### 2. Search Navigation

```dart
// Handle search queries with navigation
Future<AppIntentResult> _handleSearchIntent(Map<String, dynamic> parameters) async {
  final query = parameters['query'] as String;
  
  Navigator.of(context).pushNamed('/search', arguments: {'query': query});
  
  return AppIntentResult.successful(
    value: 'Searching for "$query"',
    needsToContinueInApp: true,
  );
}
```

### 3. Settings/Configuration Navigation

```dart
// Navigate to specific settings pages
Future<AppIntentResult> _handleOpenSettingsIntent(Map<String, dynamic> parameters) async {
  final section = parameters['section'] as String? ?? 'general';
  
  Navigator.of(context).pushNamed('/settings/$section');
  
  return AppIntentResult.successful(
    value: 'Opening $section settings',
    needsToContinueInApp: true,
  );
}
```

## Navigation with GoRouter

If you're using GoRouter, the pattern is similar:

```dart
Future<AppIntentResult> _handleNavigationIntent(Map<String, dynamic> parameters) async {
  final route = parameters['route'] as String;
  
  // Use GoRouter for navigation
  context.go(route);
  
  return AppIntentResult.successful(
    value: 'Navigating to $route',
    needsToContinueInApp: true,
  );
}
```

## Intent vs Action Types

| Intent Type | Return Type | Use Case | Example |
|-------------|-------------|----------|---------|
| **Query** | `ReturnsValue<String>` | Get information only | "Get counter value", "Check weather" |
| **Action + App Opening** | `ReturnsValue<String> & OpensIntent` | Execute + show result | "Increment counter", "Send message" |
| **Navigation** | `ReturnsValue<String> & OpensIntent` | Navigate to pages | "Open profile", "Show chat" |

## Best Practices for Navigation Intents

### 1. Always Use Required Flags
- **Flutter**: Set `needsToContinueInApp: true` in your intent result
- **Swift**: Add `static var openAppWhenRun = true` to force app opening
- **Swift**: Use `ReturnsValue<String> & OpensIntent` return type

### 2. Handle App State Properly
- Check if context is still mounted before navigation calls
- Consider app lifecycle - navigation may happen when app is backgrounded
- Pass meaningful parameters to destination pages

### 3. Provide Fallback Navigation
- Graceful handling of invalid routes
- What happens when target pages don't exist?
- Handle app cold starts appropriately

### 4. Test Edge Cases
- Test when app is backgrounded vs foreground
- Verify parameter passing to destination screens
- Ensure routes exist in your app's navigation setup

## AppShortcuts for Navigation

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
                    LocalizedStringResource("open_profile_phrase_1", defaultValue: "Open my profile in \(.applicationName)"),
                    LocalizedStringResource("open_profile_phrase_2", defaultValue: "Show profile using \(.applicationName)"),
                    LocalizedStringResource("open_profile_phrase_3", defaultValue: "Go to profile with \(.applicationName)")
                ],
                shortTitle: LocalizedStringResource("open_profile_title", defaultValue: "Open Profile"),
                systemImageName: "person.circle"
            ),
            AppShortcut(
                intent: OpenChatIntent(),
                phrases: [
                    LocalizedStringResource("open_chat_phrase_1", defaultValue: "Chat with \(.contactName) using \(.applicationName)"),
                    LocalizedStringResource("open_chat_phrase_2", defaultValue: "Open chat with \(.contactName) in \(.applicationName)"),
                    LocalizedStringResource("open_chat_phrase_3", defaultValue: "Message \(.contactName) with \(.applicationName)")
                ],
                shortTitle: LocalizedStringResource("open_chat_title", defaultValue: "Open Chat"), 
                systemImageName: "message.circle"
            )
        ]
    }
}
```

## Troubleshooting Navigation Intents

### Navigation intents not working

1. **Verify `needsToContinueInApp: true`** in Flutter result
2. **Check `OpensIntent` return type** in Swift intent
3. **Ensure routes exist** in your app's navigation setup
4. **Test app lifecycle** - try when app is backgrounded vs foreground
5. **Check mounted context** before navigation calls
6. **Verify parameter passing** to destination screens

### Common Issues

- **App doesn't open**: Missing `openAppWhenRun = true` in Swift
- **Navigation fails**: Invalid routes or unmounted context
- **Parameters missing**: Incorrect parameter passing between Swift and Flutter
- **App crashes**: Attempting navigation on unmounted widgets