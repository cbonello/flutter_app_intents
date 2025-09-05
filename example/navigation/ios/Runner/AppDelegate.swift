import Flutter
import UIKit
import AppIntents

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
    static var description: LocalizedStringResource? = "Navigate to user profile page"
    static var isDiscoverable: Bool = true
    
    @Parameter(title: "User ID")
    var userId: String?
    
    func perform() async throws -> some IntentResult & OpensIntent {
        let plugin = FlutterAppIntentsPlugin.shared
        let parameters: [String: Any] = ["userId": userId ?? "current"]
        
        let result = await plugin.handleIntentInvocation(
            identifier: "open_profile",
            parameters: parameters
        )
        
        return .result(opensIntent: true)
    }
}

@available(iOS 16.0, *)
struct OpenChatIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Chat"
    static var description: LocalizedStringResource? = "Open chat with a contact"
    static var isDiscoverable: Bool = true
    
    @Parameter(title: "Contact Name")
    var contactName: String
    
    func perform() async throws -> some IntentResult & OpensIntent {
        let plugin = FlutterAppIntentsPlugin.shared
        let parameters: [String: Any] = ["contactName": contactName]
        
        let result = await plugin.handleIntentInvocation(
            identifier: "open_chat",
            parameters: parameters
        )
        
        return .result(opensIntent: true)
    }
}

@available(iOS 16.0, *)
struct SearchContentIntent: AppIntent {
    static var title: LocalizedStringResource = "Search Content"
    static var description: LocalizedStringResource? = "Search for content in the app"
    static var isDiscoverable: Bool = true
    
    @Parameter(title: "Search Query")
    var query: String
    
    func perform() async throws -> some IntentResult & OpensIntent {
        let plugin = FlutterAppIntentsPlugin.shared
        let parameters: [String: Any] = ["query": query]
        
        let result = await plugin.handleIntentInvocation(
            identifier: "search_content",
            parameters: parameters
        )
        
        return .result(opensIntent: true)
    }
}

@available(iOS 16.0, *)
struct OpenSettingsIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Settings"
    static var description: LocalizedStringResource? = "Navigate to app settings"
    static var isDiscoverable: Bool = true
    
    func perform() async throws -> some IntentResult & OpensIntent {
        let plugin = FlutterAppIntentsPlugin.shared
        let parameters: [String: Any] = [:]
        
        let result = await plugin.handleIntentInvocation(
            identifier: "open_settings",
            parameters: parameters
        )
        
        return .result(opensIntent: true)
    }
}

