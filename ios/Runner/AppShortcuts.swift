import AppIntents
import flutter_app_intents

@available(iOS 16.0, *)
struct AppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        let plugin = FlutterAppIntentsPlugin.shared
        let intents = plugin.activeIntents.values.compactMap { intent in
            createAppShortcut(for: intent)
        }
        
        // If no dynamic intents are registered, return some default examples
        if intents.isEmpty {
            return [
                AppShortcut(
                    intent: SampleIntent(),
                    phrases: [
                        "Sample action",
                        "Do sample"
                    ]
                )
            ]
        }
        
        return intents
    }
    
    private static func createAppShortcut(for intent: DynamicAppIntent) -> AppShortcut? {
        // Get custom phrases from Flutter, fallback to title
        let phrases = extractPhrasesFromConfig(intent.asConfigDict(), defaultTitle: intent.intentTitle)
        
        // Create appropriate shortcut based on intent parameters
        if intent.parameters.isEmpty {
            return AppShortcut(
                intent: NoParameterIntent(intentIdentifier: intent.identifier, intentConfig: intent.asConfigDict()),
                phrases: phrases
            )
        } else if intent.parameters.count == 1 {
            let param = intent.parameters[0]
            let phrasesWithParam = createParameterizedPhrases(phrases, parameter: param.name)
            
            switch param.type {
            case .string:
                return AppShortcut(
                    intent: OneStringParameterIntent(intentIdentifier: intent.identifier, intentConfig: intent.asConfigDict()),
                    phrases: phrasesWithParam
                )
            case .integer:
                return AppShortcut(
                    intent: OneIntegerParameterIntent(intentIdentifier: intent.identifier, intentConfig: intent.asConfigDict()),
                    phrases: phrasesWithParam
                )
            case .boolean:
                return AppShortcut(
                    intent: OneBooleanParameterIntent(intentIdentifier: intent.identifier, intentConfig: intent.asConfigDict()),
                    phrases: phrasesWithParam
                )
            case .double:
                return AppShortcut(
                    intent: OneDoubleParameterIntent(intentIdentifier: intent.identifier, intentConfig: intent.asConfigDict()),
                    phrases: phrasesWithParam
                )
            default:
                return nil
            }
        }
        return nil
    }
    
    // MARK: - Phrase Extraction Helpers
    
    /// Extracts custom phrases from Flutter intent configuration
    private static func extractPhrasesFromConfig(_ config: [String: Any], defaultTitle: String) -> [String] {
        if let phrases = config["phrases"] as? [String], !phrases.isEmpty {
            return phrases
        }
        return [defaultTitle]
    }
    
    /// Creates parameterized phrases for intents with parameters
    private static func createParameterizedPhrases(_ basePhrases: [String], parameter: String) -> [String] {
        var allPhrases: [String] = []
        
        // Add base phrases without parameters
        allPhrases.append(contentsOf: basePhrases)
        
        // Add phrases with parameters
        for phrase in basePhrases {
            allPhrases.append("\(phrase) \(parameter)")
        }
        
        return allPhrases
    }
}

// Sample intent for testing
@available(iOS 16.0, *)
struct SampleIntent: AppIntent {
    static var title: LocalizedStringResource = "Sample Intent"
    static var description = IntentDescription("A sample intent for testing")
    
    func perform() async throws -> some IntentResult {
        return .result(value: "Sample completed")
    }
}