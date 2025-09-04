import AppIntents
import flutter_app_intents

// MARK: - Navigation-focused App Intents

@available(iOS 16.0, *)
struct OpenProfileIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Profile"
    static var description = IntentDescription("Open user profile page")
    static var isDiscoverable = true
    
    @Parameter(title: "User ID")
    var userId: String?
    
    func perform() async throws -> some IntentResult & OpensIntent {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "open_profile",
            parameters: ["userId": userId ?? "current"]
        )
        
        if let success = result["success"] as? Bool, success {
            return .result()
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
    
    @Parameter(title: "Contact Name")
    var contactName: String
    
    func perform() async throws -> some IntentResult & OpensIntent {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "open_chat",
            parameters: ["contactName": contactName]
        )
        
        if let success = result["success"] as? Bool, success {
            return .result()
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
    
    @Parameter(title: "Search Query")
    var query: String
    
    func perform() async throws -> some IntentResult & OpensIntent {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "search_content",
            parameters: ["query": query]
        )
        
        if let success = result["success"] as? Bool, success {
            return .result()
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to search content"
            throw AppIntentError.executionFailed(errorMessage)
        }
    }
}

// MARK: - Navigation Shortcuts Provider

@available(iOS 16.0, *)
struct NavigationShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
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
                    "Open chat in ${applicationName}",
                    "Chat with \\(.contactName) using ${applicationName}",
                    "Message \\(.contactName) with ${applicationName}"
                ]
            ),
            AppShortcut(
                intent: SearchContentIntent(),
                phrases: [
                    "Search in ${applicationName}",
                    "Find \\(.query) in ${applicationName}",
                    "Look for \\(.query) using ${applicationName}"
                ]
            )
        ]
    }
}