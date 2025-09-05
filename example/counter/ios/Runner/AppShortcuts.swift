import AppIntents

// Simple static intents that iOS can discover
@available(iOS 16.0, *)
struct CounterIntent: AppIntent {
    static var title: LocalizedStringResource = "Increment Counter"
    static var description = IntentDescription("Increment the counter by one")
    
    func perform() async throws -> some IntentResult {
        // This will call back to Flutter
        return .result(value: "Counter incremented")
    }
}

@available(iOS 16.0, *)
struct ResetIntent: AppIntent {
    static var title: LocalizedStringResource = "Reset Counter"  
    static var description = IntentDescription("Reset the counter to zero")
    
    func perform() async throws -> some IntentResult {
        return .result(value: "Counter reset")
    }
}

