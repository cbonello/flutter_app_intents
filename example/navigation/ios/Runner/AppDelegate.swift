/// Navigation App Intents Example - iOS Static Intent Declarations
///
/// This file contains the static Swift App Intent declarations required for the
/// navigation example. These intents focus on deep linking and app navigation
/// through Siri voice commands and iOS shortcuts.
///
/// Architecture:
/// - Static Swift intents (this file) - Required for iOS discovery at compile time
/// - Flutter handlers (lib/main.dart) - Handle navigation and business logic
/// - Bridge communication - Static intents call Flutter handlers via the plugin
///
/// Navigation Intent Pattern:
/// All navigation intents use `OpensIntent` return type and `openAppWhenRun = true`
/// to ensure the app opens and navigates to the correct page.

import Flutter
import UIKit
import AppIntents
import flutter_app_intents

/// Custom error type for App Intent execution failures
enum AppIntentError: Error {
    case executionFailed(String)
}

/// Main application delegate - standard Flutter app delegate setup
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

// MARK: - Navigation App Intents
//
// These static intent declarations are required for iOS to discover the intents
// at compile time. Each intent bridges to a corresponding Flutter handler.

/// Opens the user profile page
/// 
/// This intent demonstrates navigation with optional parameters. The userId parameter
/// defaults to "current" if not specified by the user.
@available(iOS 16.0, *)
struct OpenProfileIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Profile"
    static var description = IntentDescription("Navigate to user profile page")
    static var isDiscoverable = true
    static var openAppWhenRun = true  // Ensures app opens for navigation
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & OpensIntent {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "open_profile",
            parameters: ["userId": "current"]  // Default user ID
        )
        
        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Profile opened"
            return .result(value: value)
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to open profile"
            throw AppIntentError.executionFailed(errorMessage)
        }
    }
}

/// Opens chat with a specific contact
/// 
/// This intent demonstrates navigation with required parameters. The contactName
/// parameter is used to determine which chat conversation to open.
@available(iOS 16.0, *)
struct OpenChatIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Chat"
    static var description = IntentDescription("Open chat with a contact")
    static var isDiscoverable = true
    static var openAppWhenRun = true  // Ensures app opens for navigation
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & OpensIntent {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "open_chat",
            parameters: ["contactName": "Demo User"]  // Default contact for demo
        )
        
        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Chat opened"
            return .result(value: value)
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to open chat"
            throw AppIntentError.executionFailed(errorMessage)
        }
    }
}

/// Searches for content within the app
/// 
/// This intent demonstrates search functionality with navigation. The query parameter
/// is passed to the search page to display relevant results.
@available(iOS 16.0, *)
struct SearchContentIntent: AppIntent {
    static var title: LocalizedStringResource = "Search Content"
    static var description = IntentDescription("Search for content in the app")
    static var isDiscoverable = true
    static var openAppWhenRun = true  // Ensures app opens for navigation
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & OpensIntent {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "search_content",
            parameters: ["query": "photos"]  // Default search query for demo
        )
        
        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Search completed"
            return .result(value: value)
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to search content"
            throw AppIntentError.executionFailed(errorMessage)
        }
    }
}

/// Opens the app settings page
/// 
/// This intent demonstrates simple navigation without parameters. It provides
/// quick access to the app's settings interface.
@available(iOS 16.0, *)
struct OpenSettingsIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Settings"
    static var description = IntentDescription("Navigate to app settings")
    static var isDiscoverable = true
    static var openAppWhenRun = true  // Ensures app opens for navigation
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & OpensIntent {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "open_settings",
            parameters: [:]  // No parameters needed for settings
        )
        
        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Settings opened"
            return .result(value: value)
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to open settings"
            throw AppIntentError.executionFailed(errorMessage)
        }
    }
}

// MARK: - App Shortcuts Provider
//
// This provider tells iOS about the available shortcuts for Siri and the Shortcuts app.
// Each shortcut includes multiple phrase variations that users can speak to invoke them.

/// Defines the app shortcuts that appear in Siri and the iOS Shortcuts app
/// 
/// The phrases use `\(.applicationName)` to automatically include the app's display name,
/// making voice commands more natural and discoverable for users.
@available(iOS 16.0, *)
struct NavigationAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        // Profile navigation shortcut
        AppShortcut(
            intent: OpenProfileIntent(),
            phrases: [
                "Open Profile in \(.applicationName)",
                "Open my profile in \(.applicationName)",
                "Show my profile in \(.applicationName)"
            ],
            shortTitle: "Open Profile",
            systemImageName: "person.circle"
        )
        
        // Chat navigation shortcut
        AppShortcut(
            intent: OpenChatIntent(),
            phrases: [
                "Open Chat in \(.applicationName)",
                "Start chat in \(.applicationName)",
                "Chat with someone in \(.applicationName)"
            ],
            shortTitle: "Open Chat",
            systemImageName: "message.circle"
        )
        
        // Search navigation shortcut
        AppShortcut(
            intent: SearchContentIntent(),
            phrases: [
                "Search in \(.applicationName)",
                "Search for content in \(.applicationName)",
                "Find content in \(.applicationName)"
            ],
            shortTitle: "Search Content",
            systemImageName: "magnifyingglass.circle"
        )
        
        // Settings navigation shortcut
        AppShortcut(
            intent: OpenSettingsIntent(),
            phrases: [
                "Open Settings in \(.applicationName)",
                "Show settings in \(.applicationName)",
                "Open app settings in \(.applicationName)"
            ],
            shortTitle: "Open Settings",
            systemImageName: "gearshape.circle"
        )
    }
}

