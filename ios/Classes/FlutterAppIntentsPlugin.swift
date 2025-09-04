import Flutter
import UIKit
import Intents
import IntentsUI
import AppIntents
import CoreLocation

@available(iOS 16.0, *)
public class FlutterAppIntentsPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel?
    private var registeredIntents: [String: Any] = [:]
    internal var activeIntents: [String: DynamicAppIntent] = [:]
    
    // Singleton to handle intent registry
    public static let shared = FlutterAppIntentsPlugin()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_app_intents", binaryMessenger: registrar.messenger())
        let instance = shared
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard #available(iOS 16.0, *) else {
            result(FlutterError(code: "UNSUPPORTED_VERSION",
                              message: "App Intents require iOS 16.0 or later",
                              details: nil))
            return
        }
        
        switch call.method {
        case "registerIntent":
            registerIntent(call: call, result: result)
        case "registerIntents":
            registerIntents(call: call, result: result)
        case "unregisterIntent":
            unregisterIntent(call: call, result: result)
        case "getRegisteredIntents":
            getRegisteredIntents(result: result)
        case "updateShortcuts":
            updateShortcuts(result: result)
        case "donateIntent":
            donateIntent(call: call, result: result)
        case "donateIntentWithMetadata":
            donateIntentWithMetadata(call: call, result: result)
        case "donateIntentBatch":
            donateIntentBatch(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func registerIntent(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let identifier = arguments["identifier"] as? String,
              let title = arguments["title"] as? String,
              let description = arguments["description"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                              message: "Invalid arguments for registerIntent",
                              details: nil))
            return
        }
        
        do {
            // Store the intent configuration
            registeredIntents[identifier] = arguments
            
            // Create and register the dynamic App Intent
            let intent = try createDynamicIntent(
                identifier: identifier,
                title: title,
                description: description,
                arguments: arguments
            )
            
            activeIntents[identifier] = intent
            
            // Update App Shortcuts to include this intent
            Task {
                await updateAppShortcuts()
            }
            
            result(true)
        } catch {
            result(FlutterError(code: "REGISTRATION_FAILED",
                              message: "Failed to register intent: \(error.localizedDescription)",
                              details: nil))
        }
    }
    
    private func registerIntents(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let intentsArray = arguments["intents"] as? [[String: Any]] else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                              message: "Invalid arguments for registerIntents",
                              details: nil))
            return
        }
        
        var registrationErrors: [String] = []
        
        for intentDict in intentsArray {
            guard let identifier = intentDict["identifier"] as? String,
                  let title = intentDict["title"] as? String,
                  let description = intentDict["description"] as? String else {
                continue
            }
            
            do {
                registeredIntents[identifier] = intentDict
                
                let intent = try createDynamicIntent(
                    identifier: identifier,
                    title: title,
                    description: description,
                    arguments: intentDict
                )
                
                activeIntents[identifier] = intent
            } catch {
                registrationErrors.append("Failed to register \(identifier): \(error.localizedDescription)")
            }
        }
        
        // Update App Shortcuts
        Task {
            await updateAppShortcuts()
        }
        
        if registrationErrors.isEmpty {
            result(true)
        } else {
            result(FlutterError(code: "PARTIAL_REGISTRATION_FAILED",
                              message: "Some intents failed to register",
                              details: registrationErrors.joined(separator: "; ")))
        }
    }
    
    private func unregisterIntent(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let identifier = arguments["identifier"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                              message: "Invalid arguments for unregisterIntent",
                              details: nil))
            return
        }
        
        registeredIntents.removeValue(forKey: identifier)
        activeIntents.removeValue(forKey: identifier)
        
        // Update App Shortcuts to remove this intent
        Task {
            await updateAppShortcuts()
        }
        
        result(true)
    }
    
    private func getRegisteredIntents(result: @escaping FlutterResult) {
        let intents = Array(registeredIntents.values)
        result(intents)
    }
    
    private func updateShortcuts(result: @escaping FlutterResult) {
        Task {
            await updateAppShortcuts()
            result(true)
        }
    }
    
    private func donateIntent(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let identifier = arguments["identifier"] as? String,
              let parameters = arguments["parameters"] as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                              message: "Invalid arguments for donateIntent",
                              details: nil))
            return
        }
        
        guard let intent = activeIntents[identifier] else {
            result(FlutterError(code: "INTENT_NOT_FOUND",
                              message: "Intent \(identifier) not registered",
                              details: nil))
            return
        }
        
        // Donate the intent to the system for prediction
        Task {
            await donateIntentToSystem(intent: intent, parameters: parameters)
            result(true)
        }
    }
    
    private func donateIntentWithMetadata(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let identifier = arguments["identifier"] as? String,
              let parameters = arguments["parameters"] as? [String: Any],
              let metadata = arguments["metadata"] as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                              message: "Invalid arguments for donateIntentWithMetadata",
                              details: nil))
            return
        }
        
        guard let intent = activeIntents[identifier] else {
            result(FlutterError(code: "INTENT_NOT_FOUND",
                              message: "Intent \(identifier) not registered",
                              details: nil))
            return
        }
        
        // Extract metadata
        let relevanceScore = metadata["relevanceScore"] as? Double ?? 1.0
        let context = metadata["context"] as? [String: Any] ?? [:]
        let timestamp = metadata["timestamp"] as? Double ?? Date().timeIntervalSince1970
        
        // Enhanced donation with metadata
        Task {
            await donateIntentWithEnhancedMetadata(
                intent: intent,
                parameters: parameters,
                relevanceScore: relevanceScore,
                context: context,
                timestamp: Date(timeIntervalSince1970: timestamp / 1000.0)
            )
            result(true)
        }
    }
    
    private func donateIntentBatch(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let donations = arguments["donations"] as? [[String: Any]] else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                              message: "Invalid arguments for donateIntentBatch",
                              details: nil))
            return
        }
        
        var donationErrors: [String] = []
        
        Task {
            for donationData in donations {
                guard let identifier = donationData["identifier"] as? String,
                      let parameters = donationData["parameters"] as? [String: Any],
                      let metadata = donationData["metadata"] as? [String: Any],
                      let intent = activeIntents[identifier] else {
                    donationErrors.append("Invalid donation data for \(donationData["identifier"] ?? "unknown")")
                    continue
                }
                
                let relevanceScore = metadata["relevanceScore"] as? Double ?? 1.0
                let context = metadata["context"] as? [String: Any] ?? [:]
                let timestamp = metadata["timestamp"] as? Double ?? Date().timeIntervalSince1970
                
                await donateIntentWithEnhancedMetadata(
                    intent: intent,
                    parameters: parameters,
                    relevanceScore: relevanceScore,
                    context: context,
                    timestamp: Date(timeIntervalSince1970: timestamp / 1000.0)
                )
            }
            
            if donationErrors.isEmpty {
                result(true)
            } else {
                result(FlutterError(code: "PARTIAL_DONATION_FAILED",
                                  message: "Some donations failed",
                                  details: donationErrors.joined(separator: "; ")))
            }
        }
    }
    
    private func donateIntentWithEnhancedMetadata(
        intent: DynamicAppIntent,
        parameters: [String: Any],
        relevanceScore: Double,
        context: [String: Any],
        timestamp: Date
    ) async {
        do {
            // Create enhanced donation with rich metadata
            let donationIntent = createIntentForDonation(intent: intent, parameters: parameters)
            let metadata = DonationMetadata(
                relevanceScore: relevanceScore,
                context: context,
                timestamp: timestamp
            )
            
            try await DonationManager.donate(donationIntent, with: metadata)
            print("Successfully donated intent with metadata: \(intent.identifier)")
        } catch {
            print("Failed to donate intent with metadata \(intent.identifier): \(error.localizedDescription)")
            await donateLegacyIntent(intent: intent, parameters: parameters)
        }
    }
    
    // MARK: - Helper Methods
    
    private func createDynamicIntent(identifier: String, title: String, description: String, arguments: [String: Any]) throws -> DynamicAppIntent {
        let intent = DynamicAppIntent(
            identifier: identifier,
            title: title,
            description: description,
            arguments: arguments
        )
        return intent
    }
    
    private func updateAppShortcuts() async {
        // App shortcuts are automatically managed by iOS when AppShortcutsProvider.appShortcuts changes
        // The system will refresh shortcuts when it detects changes to the provider
        print("App shortcuts updated with \(activeIntents.count) intents")
    }
    
    private func createAppShortcuts() -> [String] {
        // Return intent identifiers for logging purposes
        // Actual shortcuts are managed automatically by iOS 16+ AppIntent framework
        return Array(activeIntents.keys)
    }
    
    private func donateIntentToSystem(intent: DynamicAppIntent, parameters: [String: Any]) async {
        // Use modern iOS 16+ App Intents donation system
        do {
            // Create the appropriate intent instance with parameters
            let donationIntent = createIntentForDonation(intent: intent, parameters: parameters)
            
            // Donate using modern App Intents framework
            let metadata = createDonationMetadata(intent: intent, parameters: parameters)
            try await DonationManager.donate(donationIntent, with: metadata)
            
            print("Successfully donated intent: \(intent.identifier)")
        } catch {
            print("Failed to donate intent \(intent.identifier): \(error.localizedDescription)")
            
            // Fallback to legacy donation if modern fails
            await donateLegacyIntent(intent: intent, parameters: parameters)
        }
    }
    
    private func createIntentForDonation(intent: DynamicAppIntent, parameters: [String: Any]) -> Any {
        guard let intentProtocol = intent.actualIntent as? DynamicAppIntentProtocol else {
            return NoParameterIntent(intentIdentifier: intent.identifier, intentConfig: intent.asConfigDict())
        }
        
        var donationIntent = intentProtocol
        
        if let firstParam = intent.parameters.first {
            let paramName = firstParam.name
            let paramValue = parameters[paramName]
            
            switch (donationIntent, paramValue) {
            case (var stringIntent as OneStringParameterIntent, let value as String):
                stringIntent.stringParam = value
                donationIntent = stringIntent
            case (var intIntent as OneIntegerParameterIntent, let value as Int):
                intIntent.intParam = value
                donationIntent = intIntent
            case (var boolIntent as OneBooleanParameterIntent, let value as Bool):
                boolIntent.boolParam = value
                donationIntent = boolIntent
            case (var doubleIntent as OneDoubleParameterIntent, let value as Double):
                doubleIntent.doubleParam = value
                donationIntent = doubleIntent
            default:
                break
            }
        }
        
        return donationIntent
    }
    
    private func createDonationMetadata(intent: DynamicAppIntent, parameters: [String: Any]) -> DonationMetadata {
        // Create rich metadata for better Siri learning
        let relevanceScore = calculateRelevanceScore(intent: intent, parameters: parameters)
        let context = buildDonationContext(intent: intent, parameters: parameters)
        
        return DonationMetadata(
            relevanceScore: relevanceScore,
            context: context,
            timestamp: Date(),
            location: nil // Could be enhanced with location data
        )
    }
    
    private func calculateRelevanceScore(intent: DynamicAppIntent, parameters: [String: Any]) -> Double {
        // Calculate relevance based on various factors
        var score = 1.0
        
        // Boost score for intents with parameters (more specific)
        if !parameters.isEmpty {
            score += 0.2
        }
        
        // Boost score for frequently used intents (could be enhanced with usage tracking)
        // For now, use a simple heuristic based on intent type
        if intent.identifier.contains("increment") || intent.identifier.contains("counter") {
            score += 0.3
        }
        
        // Ensure score is within valid range [0.0, 1.0]
        return min(max(score, 0.0), 1.0)
    }
    
    private func buildDonationContext(intent: DynamicAppIntent, parameters: [String: Any]) -> [String: Any] {
        var context: [String: Any] = [:]
        
        // Add intent metadata
        context["intentType"] = intent.identifier
        context["intentTitle"] = intent.intentTitle
        context["timestamp"] = Date().timeIntervalSince1970
        
        // Add parameter information
        if !parameters.isEmpty {
            context["parameters"] = parameters
            context["parameterCount"] = parameters.count
        }
        
        // Add usage context (could be enhanced with user context)
        context["usagePattern"] = "manual_invocation"
        
        return context
    }
    
    private func donateLegacyIntent(intent: DynamicAppIntent, parameters: [String: Any]) async {
        // Fallback to legacy INIntent donation for compatibility
        let legacyIntent = createLegacyIntent(intent: intent, parameters: parameters)
        let interaction = INInteraction(intent: legacyIntent, response: nil)
        
        // Add metadata to legacy donation
        // Note: intentHandlingStatus and relevanceScore are read-only in modern iOS versions
        interaction.direction = .outgoing
        interaction.dateInterval = DateInterval(start: Date(), duration: 1.0)
        
        interaction.donate { error in
            if let error = error {
                print("Legacy intent donation failed: \(error.localizedDescription)")
            } else {
                print("Legacy intent donation succeeded for: \(intent.identifier)")
            }
        }
    }
    
    private func createLegacyIntent(intent: DynamicAppIntent, parameters: [String: Any]) -> INIntent {
        // Create a more appropriate legacy intent based on the action type
        if intent.identifier.contains("search") || intent.identifier.contains("find") {
            let searchIntent = INSearchCallHistoryIntent()
            searchIntent.suggestedInvocationPhrase = intent.intentTitle
            return searchIntent
        } else if intent.identifier.contains("start") || intent.identifier.contains("run") {
            let startIntent = INStartWorkoutIntent()
            startIntent.suggestedInvocationPhrase = intent.intentTitle
            return startIntent
        } else {
            // Generic intent for other cases
            let genericIntent = INSearchCallHistoryIntent()
            genericIntent.suggestedInvocationPhrase = intent.intentTitle
            return genericIntent
        }
    }
    
    // Handle intent invocation from the system
    public func handleIntentInvocation(identifier: String, parameters: [String: Any]) async -> [String: Any] {
        print("🚀 iOS calling Flutter intent: \(identifier) with parameters: \(parameters)")
        
        let arguments: [String: Any] = [
            "identifier": identifier,
            "parameters": parameters
        ]
        
        // Create a continuation to wait for Flutter response
        return await withCheckedContinuation { continuation in
            // Ensure we're on the main thread for Flutter platform channel calls
            DispatchQueue.main.async {
                self.channel?.invokeMethod("handleIntent", arguments: arguments) { result in
                    print("📱 Flutter response for \(identifier): \(String(describing: result))")
                    
                    if let resultDict = result as? [String: Any] {
                        continuation.resume(returning: resultDict)
                    } else {
                        let errorResult: [String: Any] = [
                            "success": false,
                            "error": "Failed to execute intent on Flutter side"
                        ]
                        continuation.resume(returning: errorResult)
                    }
                }
            }
        }
    }
}

// MARK: - Dynamic App Intent Implementation

@available(iOS 16.0, *)
protocol DynamicAppIntentProtocol: AppIntent {
    var intentIdentifier: String { get }
    var intentConfig: [String: Any] { get }
}

@available(iOS 16.0, *)
extension DynamicAppIntentProtocol {
    func perform() async throws -> some IntentResult {
        var parameters: [String: Any] = [:]
        
        if let paramsArray = intentConfig["parameters"] as? [[String: Any]],
           let firstParam = paramsArray.first,
           let paramName = firstParam["name"] as? String {
            
            switch self {
            case let intent as OneStringParameterIntent:
                if let value = intent.stringParam { parameters[paramName] = value }
            case let intent as OneIntegerParameterIntent:
                if let value = intent.intParam { parameters[paramName] = value }
            case let intent as OneBooleanParameterIntent:
                if let value = intent.boolParam { parameters[paramName] = value }
            case let intent as OneDoubleParameterIntent:
                if let value = intent.doubleParam { parameters[paramName] = value }
            default:
                break
            }
        }
        
        return try await executeWithParameters(parameters)
    }
    
    func executeWithParameters(_ parameters: [String: Any]) async throws -> some IntentResult {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(identifier: intentIdentifier, parameters: parameters)
        
        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Success"
            return .result(value: value)
        } else {
            let errorMessage = result["error"] as? String ?? "Unknown error"
            throw IntentExecutionError.custom(errorMessage)
        }
    }
}

// Base implementation for intents without parameters
@available(iOS 16.0, *)
struct NoParameterIntent: DynamicAppIntentProtocol {
    let intentIdentifier: String
    let intentConfig: [String: Any]
    
    static var title: LocalizedStringResource {
        LocalizedStringResource("App Intent")
    }
    
    static var description: IntentDescription {
        IntentDescription("Performs an app action")
    }
    
    init(intentIdentifier: String, intentConfig: [String: Any]) {
        self.intentIdentifier = intentIdentifier
        self.intentConfig = intentConfig
    }

    init() {
        self.intentIdentifier = ""
        self.intentConfig = [:]
    }
    
    func perform() async throws -> some IntentResult {
        return try await executeWithParameters([:])
    }
}

// Intent with one string parameter
@available(iOS 16.0, *)
struct OneStringParameterIntent: DynamicAppIntentProtocol {
    let intentIdentifier: String
    let intentConfig: [String: Any]
    
    @Parameter(title: "Value")
    var stringParam: String?
    
    static var title: LocalizedStringResource {
        LocalizedStringResource("App Intent")
    }
    
    static var description: IntentDescription {
        IntentDescription("Performs an app action with one parameter")
    }
    
    init(intentIdentifier: String, intentConfig: [String: Any]) {
        self.intentIdentifier = intentIdentifier
        self.intentConfig = intentConfig
    }

    init() {
        self.intentIdentifier = ""
        self.intentConfig = [:]
    }
    
    func perform() async throws -> some IntentResult {
        var parameters: [String: Any] = [:]
        
        if let paramsArray = intentConfig["parameters"] as? [[String: Any]],
           let firstParam = paramsArray.first,
           let paramName = firstParam["name"] as? String,
           let value = stringParam {
            parameters[paramName] = value
        }
        
        return try await executeWithParameters(parameters)
    }
}

// Intent with one integer parameter
@available(iOS 16.0, *)
struct OneIntegerParameterIntent: DynamicAppIntentProtocol {
    let intentIdentifier: String
    let intentConfig: [String: Any]
    
    @Parameter(title: "Amount")
    var intParam: Int?
    
    static var title: LocalizedStringResource {
        LocalizedStringResource("App Intent")
    }
    
    static var description: IntentDescription {
        IntentDescription("Performs an app action with one integer parameter")
    }
    
    init(intentIdentifier: String, intentConfig: [String: Any]) {
        self.intentIdentifier = intentIdentifier
        self.intentConfig = intentConfig
    }

    init() {
        self.intentIdentifier = ""
        self.intentConfig = [:]
    }
    
    func perform() async throws -> some IntentResult {
        var parameters: [String: Any] = [:]
        
        if let paramsArray = intentConfig["parameters"] as? [[String: Any]],
           let firstParam = paramsArray.first,
           let paramName = firstParam["name"] as? String,
           let value = intParam {
            parameters[paramName] = value
        }
        
        return try await executeWithParameters(parameters)
    }
}

// Intent with one boolean parameter
@available(iOS 16.0, *)
struct OneBooleanParameterIntent: DynamicAppIntentProtocol {
    let intentIdentifier: String
    let intentConfig: [String: Any]
    
    @Parameter(title: "Enable")
    var boolParam: Bool?
    
    static var title: LocalizedStringResource {
        LocalizedStringResource("App Intent")
    }
    
    static var description: IntentDescription {
        IntentDescription("Performs an app action with one boolean parameter")
    }
    
    init(intentIdentifier: String, intentConfig: [String: Any]) {
        self.intentIdentifier = intentIdentifier
        self.intentConfig = intentConfig
    }

    init() {
        self.intentIdentifier = ""
        self.intentConfig = [:]
    }
    
    func perform() async throws -> some IntentResult {
        var parameters: [String: Any] = [:]
        
        if let paramsArray = intentConfig["parameters"] as? [[String: Any]],
           let firstParam = paramsArray.first,
           let paramName = firstParam["name"] as? String,
           let value = boolParam {
            parameters[paramName] = value
        }
        
        return try await executeWithParameters(parameters)
    }
}

// Intent with one double parameter
@available(iOS 16.0, *)
struct OneDoubleParameterIntent: DynamicAppIntentProtocol {
    let intentIdentifier: String
    let intentConfig: [String: Any]
    
    @Parameter(title: "Value")
    var doubleParam: Double?
    
    static var title: LocalizedStringResource {
        LocalizedStringResource("App Intent")
    }
    
    static var description: IntentDescription {
        IntentDescription("Performs an app action with one double parameter")
    }
    
    init(intentIdentifier: String, intentConfig: [String: Any]) {
        self.intentIdentifier = intentIdentifier
        self.intentConfig = intentConfig
    }

    init() {
        self.intentIdentifier = ""
        self.intentConfig = [:]
    }
    
    func perform() async throws -> some IntentResult {
        var parameters: [String: Any] = [:]
        
        if let paramsArray = intentConfig["parameters"] as? [[String: Any]],
           let firstParam = paramsArray.first,
           let paramName = firstParam["name"] as? String,
           let value = doubleParam {
            parameters[paramName] = value
        }
        
        return try await executeWithParameters(parameters)
    }
}

// Intent factory to create the appropriate intent type
@available(iOS 16.0, *)
class DynamicAppIntentFactory {
    static func createIntent(identifier: String, title: String, description: String, arguments: [String: Any]) -> Any {
        let parametersArray = arguments["parameters"] as? [[String: Any]] ?? []
        
        // Determine intent type based on parameters
        if parametersArray.isEmpty {
            return NoParameterIntent(intentIdentifier: identifier, intentConfig: arguments)
        } else if parametersArray.count == 1 {
            let firstParam = parametersArray[0]
            let paramType = firstParam["type"] as? String ?? "string"
            
            switch paramType.lowercased() {
            case "string":
                return OneStringParameterIntent(intentIdentifier: identifier, intentConfig: arguments)
            case "integer":
                return OneIntegerParameterIntent(intentIdentifier: identifier, intentConfig: arguments)
            case "boolean":
                return OneBooleanParameterIntent(intentIdentifier: identifier, intentConfig: arguments)
            case "double":
                return OneDoubleParameterIntent(intentIdentifier: identifier, intentConfig: arguments)
            default:
                return OneStringParameterIntent(intentIdentifier: identifier, intentConfig: arguments)
            }
        }
        
        // Default to no parameters for complex cases (multi-parameter support can be added later)
        return NoParameterIntent(intentIdentifier: identifier, intentConfig: arguments)
    }
}

// Legacy DynamicAppIntent for backward compatibility
@available(iOS 16.0, *)
class DynamicAppIntent: NSObject {
    let identifier: String
    let intentTitle: String
    let intentDescription: String
    let parameters: [AppIntentParameterInfo]
    let actualIntent: Any
    
    init(identifier: String, title: String, description: String, arguments: [String: Any]) {
        self.identifier = identifier
        self.intentTitle = title
        self.intentDescription = description
        
        // Extract parameters
        var extractedParams: [AppIntentParameterInfo] = []
        if let parametersArray = arguments["parameters"] as? [[String: Any]] {
            for paramDict in parametersArray {
                if let paramInfo = AppIntentParameterInfo.fromDict(paramDict) {
                    extractedParams.append(paramInfo)
                }
            }
        }
        self.parameters = extractedParams
        
        // Create the actual intent implementation
        self.actualIntent = DynamicAppIntentFactory.createIntent(
            identifier: identifier,
            title: title,
            description: description,
            arguments: arguments
        )
        
        super.init()
    }
    
    func asINIntent() -> INIntent {
        // Create legacy intent with better context
        let intent = INSearchCallHistoryIntent()
        intent.suggestedInvocationPhrase = intentTitle
        return intent
    }
    
    func asConfigDict() -> [String: Any] {
        // Convert to configuration dictionary for donation
        var config: [String: Any] = [
            "identifier": identifier,
            "title": intentTitle,
            "description": intentDescription
        ]
        
        if !parameters.isEmpty {
            config["parameters"] = parameters.map { param in
                [
                    "name": param.name,
                    "title": param.title,
                    "type": param.type.rawValue,
                    "description": param.description ?? "",
                    "isOptional": param.isOptional,
                    "defaultValue": param.defaultValue ?? NSNull()
                ] as [String: Any]
            }
        }
        
        return config
    }
}

// MARK: - Parameter Support

@available(iOS 16.0, *)
struct AppIntentParameterInfo {
    let name: String
    let title: String
    let type: AppIntentParameterType
    let description: String?
    let isOptional: Bool
    let defaultValue: Any?
    
    static func fromDict(_ dict: [String: Any]) -> AppIntentParameterInfo? {
        guard let name = dict["name"] as? String,
              let title = dict["title"] as? String,
              let typeString = dict["type"] as? String else {
            return nil
        }
        
        let type = AppIntentParameterType.fromString(typeString)
        let description = dict["description"] as? String
        let isOptional = dict["isOptional"] as? Bool ?? false
        let defaultValue = dict["defaultValue"]
        
        return AppIntentParameterInfo(
            name: name,
            title: title,
            type: type,
            description: description,
            isOptional: isOptional,
            defaultValue: defaultValue
        )
    }
}

enum AppIntentParameterType: String, CaseIterable {
    case string = "string"
    case integer = "integer"
    case boolean = "boolean"
    case double = "double"
    case date = "date"
    case url = "url"
    case file = "file"
    case entity = "entity"
    
    var rawValue: String {
        switch self {
        case .string: return "string"
        case .integer: return "integer"
        case .boolean: return "boolean"
        case .double: return "double"
        case .date: return "date"
        case .url: return "url"
        case .file: return "file"
        case .entity: return "entity"
        }
    }
    
    static func fromString(_ string: String) -> AppIntentParameterType {
        switch string.lowercased() {
        case "string": return .string
        case "integer": return .integer
        case "boolean": return .boolean
        case "double": return .double
        case "date": return .date
        case "url": return .url
        case "file": return .file
        case "entity": return .entity
        default: return .string
        }
    }
    
    func swiftType() -> Any.Type {
        switch self {
        case .string: return String.self
        case .integer: return Int.self
        case .boolean: return Bool.self
        case .double: return Double.self
        case .date: return Date.self
        case .url: return URL.self
        case .file: return Data.self
        case .entity: return [String: Any].self
        }
    }
}

// MARK: - Intent Donation Support

@available(iOS 16.0, *)
struct DonationMetadata {
    let relevanceScore: Double
    let context: [String: Any]
    let timestamp: Date
    let location: CLLocation?
    
    init(relevanceScore: Double, context: [String: Any], timestamp: Date, location: CLLocation? = nil) {
        self.relevanceScore = max(0.0, min(1.0, relevanceScore)) // Ensure valid range
        self.context = context
        self.timestamp = timestamp
        self.location = location
    }
}

@available(iOS 16.0, *)
class DonationManager {
    static func donate(_ intent: Any, with metadata: DonationMetadata) async throws {
        if let appIntent = intent as? AppIntent {
            // For iOS 16+ AppIntents, use modern donation system
            // AppIntents are automatically donated when executed
            print("AppIntent donation handled automatically by iOS 16+ system")
        } else if let legacyIntent = intent as? INIntent {
            // For legacy INIntents, use traditional donation
            let interaction = INInteraction(intent: legacyIntent, response: nil)
            interaction.donate { error in
                if let error = error {
                    print("Legacy intent donation failed: \(error.localizedDescription)")
                } else {
                    print("Successfully donated legacy intent")
                }
            }
        } else {
            throw IntentDonationError.unsupportedIntentType
        }
    }
}


extension LocalizedStringResource {
    func toString() -> String {
        return String(localized: self)
    }
}

enum IntentDonationError: Error, LocalizedError {
    case unsupportedIntentType
    case donationFailed(String)
    case invalidRelevanceScore
    case missingContext
    
    var errorDescription: String? {
        switch self {
        case .unsupportedIntentType:
            return "Intent type not supported for donation"
        case .donationFailed(let message):
            return "Intent donation failed: \(message)"
        case .invalidRelevanceScore:
            return "Relevance score must be between 0.0 and 1.0"
        case .missingContext:
            return "Required donation context is missing"
        }
    }
}

// MARK: - Intent Execution Errors

enum IntentExecutionError: Error, LocalizedError {
    case custom(String)
    case invalidParameters
    case executionFailed
    case parameterResolutionFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .custom(let message):
            return message
        case .invalidParameters:
            return "Invalid parameters provided"
        case .executionFailed:
            return "Intent execution failed"
        case .parameterResolutionFailed(let paramName):
            return "Failed to resolve parameter: \(paramName)"
        }
    }
}

// MARK: - App Shortcuts Provider

@available(iOS 16.0, *)
struct FlutterAppShortcutsProvider: AppShortcutsProvider {
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
                        .init("\(intent.intentTitle) \(param.name)")
                    ]
                )
            case .integer:
                return AppShortcut(
                    intent: OneIntegerParameterIntent(intentIdentifier: intent.identifier, intentConfig: intent.asConfigDict()),
                    phrases: [
                        .init(intent.intentTitle),
                        .init("\(intent.intentTitle) \(param.name)")
                    ]
                )
            case .boolean:
                return AppShortcut(
                    intent: OneBooleanParameterIntent(intentIdentifier: intent.identifier, intentConfig: intent.asConfigDict()),
                    phrases: [
                        .init(intent.intentTitle),
                        .init("\(intent.intentTitle) \(param.name)")
                    ]
                )
            case .double:
                return AppShortcut(
                    intent: OneDoubleParameterIntent(intentIdentifier: intent.identifier, intentConfig: intent.asConfigDict()),
                    phrases: [
                        .init(intent.intentTitle),
                        .init("\(intent.intentTitle) \(param.name)")
                    ]
                )
            default:
                return nil
            }
        }
        return nil
    }
}
