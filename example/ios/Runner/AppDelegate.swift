import Flutter
import UIKit
import AppIntents
import flutter_app_intents

// Simple error for App Intents
enum AppIntentError: Error {
    case executionFailed(String)
}

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

// App Intents that bridge to Flutter plugin
@available(iOS 16.0, *)
struct CounterIntent: AppIntent {
    static var title: LocalizedStringResource = "Increment Counter"
    static var description = IntentDescription("Increment the counter by one")
    static var isDiscoverable = true
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
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

@available(iOS 16.0, *)
struct ResetIntent: AppIntent {
    static var title: LocalizedStringResource = "Reset Counter"  
    static var description = IntentDescription("Reset the counter to zero")
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "reset_counter", 
            parameters: [:]
        )
        
        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Counter reset"
            return .result(value: value)
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to reset counter"
            throw AppIntentError.executionFailed(errorMessage)
        }
    }
}

@available(iOS 16.0, *)
struct GetCounterIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Counter Value"
    static var description = IntentDescription("Get the current counter value")
    static var isDiscoverable = true
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "get_counter", 
            parameters: [:]
        )
        
        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Current counter value"
            return .result(value: value)
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to get counter value"
            throw AppIntentError.executionFailed(errorMessage)
        }
    }
}

// This is the key - AppShortcutsProvider in the main app target
@available(iOS 16.0, *)
struct AppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
            AppShortcut(
                intent: CounterIntent(),
                phrases: [
                    "Increment counter with ${applicationName}",
                    "Add one with ${applicationName}",
                    "Count up using ${applicationName}"
                ]
            ),
            AppShortcut(
                intent: ResetIntent(),
                phrases: [
                    "Reset counter with ${applicationName}",
                    "Clear counter using ${applicationName}",
                    "Zero counter in ${applicationName}"
                ]
            ),
            AppShortcut(
                intent: GetCounterIntent(),
                phrases: [
                    "Get counter from ${applicationName}",
                    "Check counter using ${applicationName}",
                    "What's my counter in ${applicationName}"
                ]
            )
        ]
    }
}
