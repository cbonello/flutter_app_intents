import Flutter
import UIKit
import Intents
import AppIntents
import CoreLocation

/// Flutter plugin for iOS App Intents integration
/// 
/// This plugin provides a bridge between Flutter apps and iOS 16+ App Intents framework,
/// enabling Siri voice commands, Shortcuts app integration, and Spotlight search.
/// 
/// Key features:
/// - Dynamic intent registration from Flutter
/// - Parameter support for complex intents
/// - Enhanced intent donation for better Siri learning
/// - Batch donation capabilities
/// - Legacy intent support for backward compatibility
@available(iOS 16.0, *)
public class FlutterAppIntentsPlugin: NSObject, FlutterPlugin {
    /// Flutter method channel for communication with Dart side
    private var channel: FlutterMethodChannel?
    /// Storage for registered intent configurations
    private var registeredIntents: [String: Any] = [:]
    /// Active dynamic intent instances ready for execution
    internal var activeIntents: [String: DynamicAppIntent] = [:]
    /// Serial queue for thread-safe access to shared dictionaries
    private let intentQueue = DispatchQueue(label: "com.flutter_app_intents.queue", attributes: .concurrent)

    /// Singleton instance to handle intent registry across the app
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
    
    /// Registers a single App Intent from Flutter
    ///
    /// Creates a dynamic AppIntent instance and stores it in a thread-safe manner.
    /// The intent becomes available for Siri voice commands and Shortcuts app integration.
    ///
    /// - Parameters:
    ///   - call: Flutter method call containing intent configuration (identifier, title, description)
    ///   - result: Callback to return registration success (true) or error
    ///
    /// - Note: Thread-safe - Uses barrier write to intentQueue for concurrent access protection
    /// - Throws: INVALID_ARGUMENTS if required fields missing, REGISTRATION_FAILED if creation fails
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
            // Create and register the dynamic App Intent
            let intent = try createDynamicIntent(
                identifier: identifier,
                title: title,
                description: description,
                arguments: arguments
            )

            // Thread-safe storage of intent configuration and instance
            intentQueue.async(flags: .barrier) {
                self.registeredIntents[identifier] = arguments
                self.activeIntents[identifier] = intent
            }

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
    
    /// Registers multiple App Intents in a single batch operation
    ///
    /// Creates multiple dynamic AppIntent instances and stores them atomically.
    /// More efficient than calling registerIntent multiple times.
    ///
    /// - Parameters:
    ///   - call: Flutter method call containing array of intent configurations
    ///   - result: Callback returning success (true) or partial failure with error details
    ///
    /// - Note: Thread-safe - Uses single barrier write for all intents
    /// - Throws: INVALID_ARGUMENTS if structure invalid, PARTIAL_REGISTRATION_FAILED if some intents fail
    private func registerIntents(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let intentsArray = arguments["intents"] as? [[String: Any]] else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                              message: "Invalid arguments for registerIntents",
                              details: nil))
            return
        }
        
        var registrationErrors: [String] = []
        var intentsToRegister: [(String, Any, DynamicAppIntent)] = []

        for intentDict in intentsArray {
            guard let identifier = intentDict["identifier"] as? String,
                  let title = intentDict["title"] as? String,
                  let description = intentDict["description"] as? String else {
                continue
            }

            do {
                let intent = try createDynamicIntent(
                    identifier: identifier,
                    title: title,
                    description: description,
                    arguments: intentDict
                )
                intentsToRegister.append((identifier, intentDict, intent))
            } catch {
                registrationErrors.append("Failed to register \(identifier): \(error.localizedDescription)")
            }
        }

        // Thread-safe batch storage
        intentQueue.async(flags: .barrier) {
            for (identifier, intentDict, intent) in intentsToRegister {
                self.registeredIntents[identifier] = intentDict
                self.activeIntents[identifier] = intent
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
    
    /// Unregisters a previously registered App Intent
    ///
    /// Removes the intent from active registry and updates the Shortcuts app.
    ///
    /// - Parameters:
    ///   - call: Flutter method call containing intent identifier to remove
    ///   - result: Callback returning success (true) or error
    ///
    /// - Note: Thread-safe - Uses barrier write to intentQueue
    /// - Throws: INVALID_ARGUMENTS if identifier missing
    private func unregisterIntent(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let identifier = arguments["identifier"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                              message: "Invalid arguments for unregisterIntent",
                              details: nil))
            return
        }

        // Thread-safe removal
        intentQueue.async(flags: .barrier) {
            self.registeredIntents.removeValue(forKey: identifier)
            self.activeIntents.removeValue(forKey: identifier)
        }

        // Update App Shortcuts to remove this intent
        Task {
            await updateAppShortcuts()
        }

        result(true)
    }
    
    /// Retrieves all currently registered App Intents
    ///
    /// Returns the configuration data for all intents registered from Flutter.
    ///
    /// - Parameter result: Callback returning array of intent configurations
    ///
    /// - Note: Thread-safe - Uses synchronous read from intentQueue
    private func getRegisteredIntents(result: @escaping FlutterResult) {
        // Thread-safe read
        intentQueue.sync {
            let intents = Array(registeredIntents.values)
            result(intents)
        }
    }
    
    /// Manually triggers an update of the App Shortcuts registry
    ///
    /// Forces iOS to refresh the shortcuts displayed in the Shortcuts app.
    /// Normally called automatically after registration/unregistration.
    ///
    /// - Parameter result: Callback returning success (true)
    private func updateShortcuts(result: @escaping FlutterResult) {
        Task {
            await updateAppShortcuts()
            result(true)
        }
    }

    /// Donates an intent execution to iOS for Siri learning
    ///
    /// Records that this intent was used, helping Siri predict and suggest it in the future.
    /// Uses default relevance scoring.
    ///
    /// - Parameters:
    ///   - call: Flutter method call with intent identifier and parameters used
    ///   - result: Callback returning success or error
    ///
    /// - Note: Thread-safe - Reads intent from intentQueue
    /// - Throws: INVALID_ARGUMENTS if data missing, INTENT_NOT_FOUND if intent not registered
    private func donateIntent(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let identifier = arguments["identifier"] as? String,
              let parameters = arguments["parameters"] as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                              message: "Invalid arguments for donateIntent",
                              details: nil))
            return
        }

        // Thread-safe read
        let intent = intentQueue.sync { activeIntents[identifier] }

        guard let intent = intent else {
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
    
    /// Donates an intent with enhanced metadata for improved Siri learning
    ///
    /// Records intent usage with custom relevance score and context data.
    /// Provides richer information to iOS for better prediction accuracy.
    ///
    /// - Parameters:
    ///   - call: Flutter method call with identifier, parameters, and metadata (relevance, context, timestamp)
    ///   - result: Callback returning success or error
    ///
    /// - Note: Thread-safe - Reads intent from intentQueue
    /// - Throws: INVALID_ARGUMENTS if data missing, INTENT_NOT_FOUND if intent not registered
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

        // Thread-safe read
        let intent = intentQueue.sync { activeIntents[identifier] }

        guard let intent = intent else {
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
    
    /// Donates multiple intent executions in a single batch operation
    ///
    /// Efficiently records multiple intent uses at once. Each donation includes
    /// full metadata (relevance, context, timestamp).
    ///
    /// - Parameters:
    ///   - call: Flutter method call with array of donation data
    ///   - result: Callback returning success or partial failure with error details
    ///
    /// - Note: Thread-safe - Reads each intent from intentQueue individually
    /// - Throws: INVALID_ARGUMENTS if structure invalid, PARTIAL_DONATION_FAILED if some donations fail
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
                      let metadata = donationData["metadata"] as? [String: Any] else {
                    donationErrors.append("Invalid donation data for \(donationData["identifier"] ?? "unknown")")
                    continue
                }

                // Thread-safe read
                let intent = intentQueue.sync { activeIntents[identifier] }

                guard let intent = intent else {
                    donationErrors.append("Intent not found: \(identifier)")
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
    
    /// Donates an intent with enhanced metadata for better Siri learning
    /// - Parameters:
    ///   - intent: The dynamic app intent to donate
    ///   - parameters: Parameters used in the intent execution
    ///   - relevanceScore: Relevance score between 0.0 and 1.0 for prediction
    ///   - context: Additional context information for learning
    ///   - timestamp: When the intent was executed
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
    
    /// Creates a dynamic AppIntent instance from Flutter configuration
    ///
    /// Constructs the appropriate intent type based on parameter configuration.
    ///
    /// - Parameters:
    ///   - identifier: Unique identifier for the intent
    ///   - title: Human-readable title displayed in Shortcuts app
    ///   - description: Longer description of intent's purpose
    ///   - arguments: Full configuration including parameters and authentication policy
    ///
    /// - Returns: Configured DynamicAppIntent ready for execution
    /// - Throws: Intent creation errors if configuration is invalid
    private func createDynamicIntent(identifier: String, title: String, description: String, arguments: [String: Any]) throws -> DynamicAppIntent {
        let intent = DynamicAppIntent(
            identifier: identifier,
            title: title,
            description: description,
            arguments: arguments
        )
        return intent
    }

    /// Updates the App Shortcuts registry with current intents
    ///
    /// Notifies iOS that shortcuts have changed. The system automatically refreshes
    /// the Shortcuts app to reflect registered intents.
    ///
    /// - Note: Thread-safe - Reads intent count from intentQueue
    private func updateAppShortcuts() async {
        // App shortcuts are automatically managed by iOS when AppShortcutsProvider.appShortcuts changes
        // The system will refresh shortcuts when it detects changes to the provider
        let count = intentQueue.sync { activeIntents.count }
        print("App shortcuts updated with \(count) intents")
    }

    /// Returns list of currently active intent identifiers
    ///
    /// Used for logging and debugging. Actual shortcut management is handled
    /// automatically by iOS 16+ AppIntent framework.
    ///
    /// - Returns: Array of registered intent identifiers
    /// - Note: Thread-safe - Reads from intentQueue
    private func createAppShortcuts() -> [String] {
        // Return intent identifiers for logging purposes
        // Actual shortcuts are managed automatically by iOS 16+ AppIntent framework
        return intentQueue.sync { Array(activeIntents.keys) }
    }

    /// Donates an intent to iOS system for Siri predictions
    ///
    /// Primary donation method that attempts modern AppIntents donation first,
    /// then falls back to legacy INIntent donation if needed.
    ///
    /// - Parameters:
    ///   - intent: The dynamic intent that was executed
    ///   - parameters: Parameters used during execution
    ///
    /// - Note: Automatically creates relevance metadata from intent and parameters
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
    
    /// Creates the appropriate intent instance for donation
    ///
    /// Constructs an intent with parameters populated from execution data.
    /// Handles different parameter types (string, int, bool, double).
    ///
    /// - Parameters:
    ///   - intent: The dynamic intent definition
    ///   - parameters: Runtime parameter values from execution
    ///
    /// - Returns: Intent instance ready for donation (AppIntent or legacy INIntent)
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
    
    /// Creates rich donation metadata for Siri learning
    ///
    /// Assembles comprehensive context including relevance score, parameters,
    /// and usage patterns to improve Siri's prediction accuracy.
    ///
    /// - Parameters:
    ///   - intent: The intent being donated
    ///   - parameters: Execution parameters
    ///
    /// - Returns: DonationMetadata with calculated relevance and context
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

    /// Calculates relevance score for intent donation
    ///
    /// Determines how likely this intent should be predicted by Siri.
    /// Scores range from 0.5 to 1.0, with higher scores increasing prediction likelihood.
    ///
    /// Scoring factors:
    /// - Base score: 0.5
    /// - Has parameters: +0.2 (more specific intents are more relevant)
    /// - Frequently used patterns: +0.3 (common intents get priority)
    ///
    /// - Parameters:
    ///   - intent: The intent to score
    ///   - parameters: Parameters used in execution
    ///
    /// - Returns: Relevance score clamped to [0.0, 1.0]
    private func calculateRelevanceScore(intent: DynamicAppIntent, parameters: [String: Any]) -> Double {
        // Calculate relevance based on various factors
        // Start at base score and adjust up or down
        var score = 0.5

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
    
    /// Builds context dictionary for intent donation
    ///
    /// Assembles metadata about the intent execution for Siri learning.
    /// Includes intent identity, parameters, and usage patterns.
    ///
    /// - Parameters:
    ///   - intent: The executed intent
    ///   - parameters: Runtime parameters
    ///
    /// - Returns: Context dictionary for donation metadata
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

    /// Fallback donation using legacy INIntent API
    ///
    /// Used when modern AppIntent donation fails. Provides backward compatibility
    /// with older iOS shortcut donation mechanisms.
    ///
    /// - Parameters:
    ///   - intent: The dynamic intent to donate
    ///   - parameters: Execution parameters
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
    
    /// Creates a legacy INIntent for backward-compatible donation
    ///
    /// Maps dynamic intents to appropriate legacy INIntent types based on identifier patterns.
    /// Used as fallback when modern AppIntent donation is unavailable.
    ///
    /// - Parameters:
    ///   - intent: The dynamic intent to convert
    ///   - parameters: Runtime parameters (currently unused but available for future enhancement)
    ///
    /// - Returns: Legacy INIntent with suggested invocation phrase
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
    
    /// Handles intent invocation from the iOS system and bridges to Flutter
    /// - Parameters:
    ///   - identifier: The unique identifier of the intent to execute
    ///   - parameters: Parameters passed from the iOS intent system
    /// - Returns: A dictionary containing success status and result value from Flutter
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
        if let appIntent = intent as? any AppIntent {
            // For iOS 16+ AppIntents, manually donate with proper context
            // Note: While AppIntents can be auto-donated during execution,
            // manual donation allows us to provide rich metadata for better Siri learning
            do {
                // Create a legacy INIntent representation for donation
                // This is necessary because AppIntent protocol doesn't have a direct donation API
                let legacyIntent = createLegacyIntentFromAppIntent(appIntent, metadata: metadata)

                return try await withCheckedThrowingContinuation { continuation in
                    let interaction = INInteraction(intent: legacyIntent, response: nil)
                    interaction.direction = .outgoing
                    interaction.dateInterval = DateInterval(start: metadata.timestamp, duration: 1.0)

                    interaction.donate { error in
                        if let error = error {
                            print("AppIntent donation failed: \(error.localizedDescription)")
                            continuation.resume(throwing: IntentDonationError.donationFailed(error.localizedDescription))
                        } else {
                            print("Successfully donated AppIntent with metadata (relevance: \(metadata.relevanceScore))")
                            continuation.resume()
                        }
                    }
                }
            } catch {
                print("Failed to create legacy intent for AppIntent donation: \(error.localizedDescription)")
                throw error
            }
        } else if let legacyIntent = intent as? INIntent {
            // For legacy INIntents, use traditional donation
            return try await withCheckedThrowingContinuation { continuation in
                let interaction = INInteraction(intent: legacyIntent, response: nil)
                interaction.direction = .outgoing
                interaction.dateInterval = DateInterval(start: metadata.timestamp, duration: 1.0)

                interaction.donate { error in
                    if let error = error {
                        print("Legacy intent donation failed: \(error.localizedDescription)")
                        continuation.resume(throwing: IntentDonationError.donationFailed(error.localizedDescription))
                    } else {
                        print("Successfully donated legacy intent")
                        continuation.resume()
                    }
                }
            }
        } else {
            throw IntentDonationError.unsupportedIntentType
        }
    }

    /// Creates a legacy INIntent from an AppIntent for donation purposes
    private static func createLegacyIntentFromAppIntent(_ appIntent: any AppIntent, metadata: DonationMetadata) -> INIntent {
        // Extract title from AppIntent for invocation phrase
        let title = String(localized: type(of: appIntent).title)

        // Determine appropriate legacy intent type based on context
        if let contextType = metadata.context["intentType"] as? String {
            if contextType.contains("search") || contextType.contains("find") || contextType.contains("query") {
                let searchIntent = INSearchCallHistoryIntent()
                searchIntent.suggestedInvocationPhrase = title
                return searchIntent
            } else if contextType.contains("start") || contextType.contains("run") || contextType.contains("workout") {
                let startIntent = INStartWorkoutIntent()
                startIntent.suggestedInvocationPhrase = title
                return startIntent
            }
        }

        // Default to generic intent
        let genericIntent = INSearchCallHistoryIntent()
        genericIntent.suggestedInvocationPhrase = title
        return genericIntent
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

// Note: AppShortcutsProvider implementations are handled by individual apps
// Each app should implement their own AppShortcutsProvider in their AppDelegate.swift
// This allows for custom phrases and better control over shortcuts presentation
