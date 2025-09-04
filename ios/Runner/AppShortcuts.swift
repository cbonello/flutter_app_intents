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
        // Create appropriate shortcut based on intent parameters
        if intent.parameters.isEmpty {
            return AppShortcut(
                intent: NoParameterIntent(intentIdentifier: intent.identifier, intentConfig: intent.asConfigDict()),
                phrases: [
                    intent.intentTitle
                ]
            )
        } else if intent.parameters.count == 1 {
            let param = intent.parameters[0]
            switch param.type {
            case .string:
                return AppShortcut(
                    intent: OneStringParameterIntent(intentIdentifier: intent.identifier, intentConfig: intent.asConfigDict()),
                    phrases: [
                        intent.intentTitle,
                        "\\(intent.intentTitle) \\(param.name)"
                    ]
                )
            case .integer:
                return AppShortcut(
                    intent: OneIntegerParameterIntent(intentIdentifier: intent.identifier, intentConfig: intent.asConfigDict()),
                    phrases: [
                        intent.intentTitle,
                        "\\(intent.intentTitle) \\(param.name)"
                    ]
                )
            case .boolean:
                return AppShortcut(
                    intent: OneBooleanParameterIntent(intentIdentifier: intent.identifier, intentConfig: intent.asConfigDict()),
                    phrases: [
                        intent.intentTitle,
                        "\\(intent.intentTitle) \\(param.name)"
                    ]
                )
            case .double:
                return AppShortcut(
                    intent: OneDoubleParameterIntent(intentIdentifier: intent.identifier, intentConfig: intent.asConfigDict()),
                    phrases: [
                        intent.intentTitle,
                        "\\(intent.intentTitle) \\(param.name)"
                    ]
                )
            default:
                return nil
            }
        }
        return nil
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