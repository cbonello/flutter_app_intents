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

@available(iOS 16.0, *)
struct OpenProfileIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Profile"
    static var description = IntentDescription("Navigate to user profile page")
    static var isDiscoverable = true
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "open_profile",
            parameters: ["userId": "current"]
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

@available(iOS 16.0, *)
struct OpenChatIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Chat"
    static var description = IntentDescription("Open chat with a contact")
    static var isDiscoverable = true
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "open_chat",
            parameters: ["contactName": "Demo User"]
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

@available(iOS 16.0, *)
struct SearchContentIntent: AppIntent {
    static var title: LocalizedStringResource = "Search Content"
    static var description = IntentDescription("Search for content in the app")
    static var isDiscoverable = true
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "search_content",
            parameters: ["query": "photos"]
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

@available(iOS 16.0, *)
struct OpenSettingsIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Settings"
    static var description = IntentDescription("Navigate to app settings")
    static var isDiscoverable = true
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "open_settings",
            parameters: [:]
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

@available(iOS 16.0, *)
struct NavigationAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
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

