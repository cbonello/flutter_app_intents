/// Counter App Intents Example - iOS Static Intent Declarations
///
/// This file contains the static Swift App Intent declarations required for the
/// counter example. These intents focus on action-based operations that can be
/// performed through Siri voice commands and iOS shortcuts.
///
/// Architecture:
/// - Static Swift intents (this file) - Required for iOS discovery at compile time
/// - Flutter handlers (lib/main.dart) - Handle business logic and state management
/// - Bridge communication - Static intents call Flutter handlers via the plugin
///
/// Action Intent Pattern:
/// Counter intents use `ReturnsValue<String>` and `OpensIntent` to provide feedback
/// and optionally open the app to show updated state.

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

// MARK: - Counter App Intents
//
// These static intent declarations are required for iOS to discover the intents
// at compile time. Each intent bridges to a corresponding Flutter handler.

/// Increments the counter by one
/// 
/// This intent demonstrates action-based functionality with optional parameters.
/// The increment amount could be parameterized in future versions.
@available(iOS 16.0, *)
struct CounterIntent: AppIntent {
    static var title: LocalizedStringResource = "Increment Counter"
    static var description = IntentDescription("Increment the counter by one")
    static var isDiscoverable = true
    static var openAppWhenRun: Bool = true  // Opens app to show updated counter
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & OpensIntent {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "increment_counter",  // Matches Flutter handler identifier
            parameters: [:]  // No parameters for basic increment
        )
        
        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Counter incremented"
            return .result(value: value)  // Returns feedback to Siri/Shortcuts
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to increment counter"
            throw AppIntentError.executionFailed(errorMessage)
        }
    }
}

/// Resets the counter to zero
/// 
/// This intent provides a quick way to reset the counter state without
/// opening the app interface.
@available(iOS 16.0, *)
struct ResetIntent: AppIntent {
    static var title: LocalizedStringResource = "Reset Counter"  
    static var description = IntentDescription("Reset the counter to zero")
    static var openAppWhenRun: Bool = true  // Opens app to show reset counter
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & OpensIntent {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "reset_counter",  // Matches Flutter handler identifier
            parameters: [:]  // No parameters needed for reset
        )
        
        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Counter reset"
            return .result(value: value)  // Returns confirmation to user
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to reset counter"
            throw AppIntentError.executionFailed(errorMessage)
        }
    }
}

/// Gets the current counter value without opening the app
/// 
/// This is a query intent that provides quick access to the counter state.
/// Uses ProvidesDialog to ensure Siri speaks the result aloud.
@available(iOS 16.0, *)
struct GetCounterIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Counter Value"
    static var description = IntentDescription("Get the current counter value")
    static var isDiscoverable = true
    // Note: No openAppWhenRun - this is a query that works in background
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        print("🔍 GetCounterIntent.perform() called")  // Debug logging
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "get_counter",  // Matches Flutter handler identifier
            parameters: [:]  // No parameters for query
        )
        print("🔍 GetCounterIntent result: \(result)")
        
        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Current counter value"
            print("🔍 GetCounterIntent returning value: \(value)")
            return .result(
                value: value,
                dialog: IntentDialog(stringLiteral: value)  // Ensures Siri speaks result
            )
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to get counter value"
            print("🔍 GetCounterIntent error: \(errorMessage)")
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
struct CounterAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        // Increment counter shortcut - most commonly used action
        AppShortcut(
            intent: CounterIntent(),
            phrases: [
                "Increment counter with \(.applicationName)",
                "Add one with \(.applicationName)",
                "Count up using \(.applicationName)"
            ],
            shortTitle: "Increment",
            systemImageName: "plus.circle"
        )
        
        // Reset counter shortcut - clears the current count
        AppShortcut(
            intent: ResetIntent(),
            phrases: [
                "Reset counter with \(.applicationName)",
                "Clear counter using \(.applicationName)", 
                "Zero counter in \(.applicationName)"
            ],
            shortTitle: "Reset",
            systemImageName: "arrow.counterclockwise.circle"
        )
        
        // Get counter shortcut - queries current value without opening app
        AppShortcut(
            intent: GetCounterIntent(),
            phrases: [
                "Get counter from \(.applicationName)",
                "Check counter using \(.applicationName)",
                "What's my counter in \(.applicationName)"
            ],
            shortTitle: "Get Counter",
            systemImageName: "number.circle"
        )
    }
}

