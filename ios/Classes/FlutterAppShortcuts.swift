import AppIntents
import Foundation

@available(iOS 16.0, *)
struct FlutterAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        let plugin = FlutterAppIntentsPlugin.shared
        return plugin.activeIntents.values.compactMap { intent in
            createAppShortcut(for: intent)
        }
    }
    
    private static func createAppShortcut(for intent: DynamicAppIntent) -> AppShortcut? {
        // Create appropriate shortcut based on intent parameters
        if intent.parameters.isEmpty {
            return AppShortcut(
                intent: NoParameterIntent(intentIdentifier: intent.identifier, intentConfig: intent.asConfigDict()),
                phrases: [
                    .init(intent.intentTitle)
                ]
            )
        } else if intent.parameters.count == 1 {
            let param = intent.parameters[0]
            switch param.type {
            case .string:
                return AppShortcut(
                    intent: OneStringParameterIntent(intentIdentifier: intent.identifier, intentConfig: intent.asConfigDict()),
                    phrases: [
                        .init(intent.intentTitle),
                        .init("\\(intent.intentTitle) \\(param.name)")
                    ]
                )
            case .integer:
                return AppShortcut(
                    intent: OneIntegerParameterIntent(intentIdentifier: intent.identifier, intentConfig: intent.asConfigDict()),
                    phrases: [
                        .init(intent.intentTitle),
                        .init("\\(intent.intentTitle) \\(param.name)")
                    ]
                )
            case .boolean:
                return AppShortcut(
                    intent: OneBooleanParameterIntent(intentIdentifier: intent.identifier, intentConfig: intent.asConfigDict()),
                    phrases: [
                        .init(intent.intentTitle),
                        .init("\\(intent.intentTitle) \\(param.name)")
                    ]
                )
            case .double:
                return AppShortcut(
                    intent: OneDoubleParameterIntent(intentIdentifier: intent.identifier, intentConfig: intent.asConfigDict()),
                    phrases: [
                        .init(intent.intentTitle),
                        .init("\\(intent.intentTitle) \\(param.name)")
                    ]
                )
            default:
                return nil
            }
        }
        return nil
    }
}