import Flutter
import UIKit
import XCTest
import AppIntents
@testable import flutter_app_intents

@available(iOS 16.0, *)
class FlutterAppIntentsPluginTests: XCTestCase {

    // MARK: - NoParameterIntent Tests
    
    func testNoParameterIntentConformsToAppIntent() {
        let intent = NoParameterIntent(
            intentIdentifier: "test_intent", 
            intentConfig: [:]
        )
        
        XCTAssert(intent is AppIntent)
        XCTAssertEqual(intent.intentIdentifier, "test_intent")
        XCTAssertEqual(intent.intentConfig.isEmpty, true)
    }
    
    func testNoParameterIntentDefaultInitializer() {
        let intent = NoParameterIntent()
        
        XCTAssert(intent is AppIntent)
        XCTAssertEqual(intent.intentIdentifier, "")
        XCTAssertEqual(intent.intentConfig.isEmpty, true)
    }
    
    func testNoParameterIntentStaticProperties() {
        XCTAssertEqual(NoParameterIntent.title.key, "App Intent")
        XCTAssertEqual(NoParameterIntent.description.stringValue, "Performs an app action")
    }
    
    func testNoParameterIntentPerformMethod() async throws {
        let intent = NoParameterIntent(
            intentIdentifier: "test_no_param", 
            intentConfig: [:]
        )
        
        // Since perform() calls executeWithParameters which requires FlutterAppIntentsPlugin.shared
        // and a Flutter method channel, we can't fully test execution in unit tests
        // But we can verify the method exists and is callable
        do {
            let _ = try await intent.perform()
            // If we get here without crashing, the method signature is correct
        } catch {
            // Expected to fail in test environment due to missing Flutter channel
            XCTAssert(error is IntentExecutionError || error.localizedDescription.contains("channel"))
        }
    }
    
    // MARK: - OneStringParameterIntent Tests
    
    func testOneStringParameterIntentConformsToAppIntent() {
        let intent = OneStringParameterIntent(
            intentIdentifier: "test_string_intent",
            intentConfig: ["parameters": [["name": "text", "type": "string"]]]
        )
        
        XCTAssert(intent is AppIntent)
        XCTAssertEqual(intent.intentIdentifier, "test_string_intent")
        XCTAssertNil(intent.stringParam)
    }
    
    func testOneStringParameterIntentWithParameter() {
        var intent = OneStringParameterIntent(
            intentIdentifier: "test_string_intent",
            intentConfig: ["parameters": [["name": "text", "type": "string"]]]
        )
        intent.stringParam = "test_value"
        
        XCTAssertEqual(intent.stringParam, "test_value")
    }
    
    func testOneStringParameterIntentDefaultInitializer() {
        var intent = OneStringParameterIntent()
        intent.stringParam = "test_value"
        
        XCTAssert(intent is AppIntent)
        XCTAssertEqual(intent.intentIdentifier, "")
        XCTAssertEqual(intent.stringParam, "test_value")
    }
    
    func testOneStringParameterIntentStaticProperties() {
        XCTAssertEqual(OneStringParameterIntent.title.key, "App Intent")
        XCTAssertEqual(OneStringParameterIntent.description.stringValue, "Performs an app action with one parameter")
    }
    
    // MARK: - OneIntegerParameterIntent Tests
    
    func testOneIntegerParameterIntentConformsToAppIntent() {
        let intent = OneIntegerParameterIntent(
            intentIdentifier: "test_int_intent",
            intentConfig: ["parameters": [["name": "amount", "type": "integer"]]]
        )
        
        XCTAssert(intent is AppIntent)
        XCTAssertEqual(intent.intentIdentifier, "test_int_intent")
        XCTAssertNil(intent.intParam)
    }
    
    func testOneIntegerParameterIntentWithParameter() {
        var intent = OneIntegerParameterIntent(
            intentIdentifier: "test_int_intent",
            intentConfig: ["parameters": [["name": "amount", "type": "integer"]]]
        )
        intent.intParam = 42
        
        XCTAssertEqual(intent.intParam, 42)
    }
    
    func testOneIntegerParameterIntentStaticProperties() {
        XCTAssertEqual(OneIntegerParameterIntent.title.key, "App Intent")
        XCTAssertEqual(OneIntegerParameterIntent.description.stringValue, "Performs an app action with one integer parameter")
    }
    
    // MARK: - OneBooleanParameterIntent Tests
    
    func testOneBooleanParameterIntentConformsToAppIntent() {
        let intent = OneBooleanParameterIntent(
            intentIdentifier: "test_bool_intent",
            intentConfig: ["parameters": [["name": "enable", "type": "boolean"]]]
        )
        
        XCTAssert(intent is AppIntent)
        XCTAssertEqual(intent.intentIdentifier, "test_bool_intent")
        XCTAssertNil(intent.boolParam)
    }
    
    func testOneBooleanParameterIntentWithParameter() {
        var intent = OneBooleanParameterIntent(
            intentIdentifier: "test_bool_intent",
            intentConfig: ["parameters": [["name": "enable", "type": "boolean"]]]
        )
        intent.boolParam = true
        
        XCTAssertEqual(intent.boolParam, true)
    }
    
    func testOneBooleanParameterIntentStaticProperties() {
        XCTAssertEqual(OneBooleanParameterIntent.title.key, "App Intent")
        XCTAssertEqual(OneBooleanParameterIntent.description.stringValue, "Performs an app action with one boolean parameter")
    }
    
    // MARK: - OneDoubleParameterIntent Tests
    
    func testOneDoubleParameterIntentConformsToAppIntent() {
        let intent = OneDoubleParameterIntent(
            intentIdentifier: "test_double_intent",
            intentConfig: ["parameters": [["name": "value", "type": "double"]]]
        )
        
        XCTAssert(intent is AppIntent)
        XCTAssertEqual(intent.intentIdentifier, "test_double_intent")
        XCTAssertNil(intent.doubleParam)
    }
    
    func testOneDoubleParameterIntentWithParameter() {
        var intent = OneDoubleParameterIntent(
            intentIdentifier: "test_double_intent",
            intentConfig: ["parameters": [["name": "value", "type": "double"]]]
        )
        intent.doubleParam = 3.14
        
        XCTAssertEqual(intent.doubleParam, 3.14, accuracy: 0.001)
    }
    
    func testOneDoubleParameterIntentStaticProperties() {
        XCTAssertEqual(OneDoubleParameterIntent.title.key, "App Intent")
        XCTAssertEqual(OneDoubleParameterIntent.description.stringValue, "Performs an app action with one double parameter")
    }
    
    // MARK: - DynamicAppIntentFactory Tests
    
    func testDynamicAppIntentFactoryCreatesNoParameterIntent() {
        let intent = DynamicAppIntentFactory.createIntent(
            identifier: "test_no_param",
            title: "Test Intent",
            description: "Test Description",
            arguments: [:]
        )
        
        XCTAssert(intent is NoParameterIntent)
        
        if let noParamIntent = intent as? NoParameterIntent {
            XCTAssertEqual(noParamIntent.intentIdentifier, "test_no_param")
        }
    }
    
    func testDynamicAppIntentFactoryCreatesStringParameterIntent() {
        let arguments = [
            "parameters": [
                ["name": "text", "type": "string"]
            ]
        ]
        
        let intent = DynamicAppIntentFactory.createIntent(
            identifier: "test_string",
            title: "Test String Intent",
            description: "Test Description",
            arguments: arguments
        )
        
        XCTAssert(intent is OneStringParameterIntent)
        
        if let stringIntent = intent as? OneStringParameterIntent {
            XCTAssertEqual(stringIntent.intentIdentifier, "test_string")
        }
    }
    
    func testDynamicAppIntentFactoryCreatesIntegerParameterIntent() {
        let arguments = [
            "parameters": [
                ["name": "amount", "type": "integer"]
            ]
        ]
        
        let intent = DynamicAppIntentFactory.createIntent(
            identifier: "test_int",
            title: "Test Integer Intent",
            description: "Test Description",
            arguments: arguments
        )
        
        XCTAssert(intent is OneIntegerParameterIntent)
        
        if let intIntent = intent as? OneIntegerParameterIntent {
            XCTAssertEqual(intIntent.intentIdentifier, "test_int")
        }
    }
    
    func testDynamicAppIntentFactoryCreatesBooleanParameterIntent() {
        let arguments = [
            "parameters": [
                ["name": "enable", "type": "boolean"]
            ]
        ]
        
        let intent = DynamicAppIntentFactory.createIntent(
            identifier: "test_bool",
            title: "Test Boolean Intent",
            description: "Test Description",
            arguments: arguments
        )
        
        XCTAssert(intent is OneBooleanParameterIntent)
        
        if let boolIntent = intent as? OneBooleanParameterIntent {
            XCTAssertEqual(boolIntent.intentIdentifier, "test_bool")
        }
    }
    
    func testDynamicAppIntentFactoryCreatesDoubleParameterIntent() {
        let arguments = [
            "parameters": [
                ["name": "value", "type": "double"]
            ]
        ]
        
        let intent = DynamicAppIntentFactory.createIntent(
            identifier: "test_double",
            title: "Test Double Intent",
            description: "Test Description",
            arguments: arguments
        )
        
        XCTAssert(intent is OneDoubleParameterIntent)
        
        if let doubleIntent = intent as? OneDoubleParameterIntent {
            XCTAssertEqual(doubleIntent.intentIdentifier, "test_double")
        }
    }
    
    func testDynamicAppIntentFactoryDefaultsToStringForUnknownType() {
        let arguments = [
            "parameters": [
                ["name": "unknown", "type": "unknown_type"]
            ]
        ]
        
        let intent = DynamicAppIntentFactory.createIntent(
            identifier: "test_unknown",
            title: "Test Unknown Intent",
            description: "Test Description",
            arguments: arguments
        )
        
        XCTAssert(intent is OneStringParameterIntent)
    }
    
    func testDynamicAppIntentFactoryDefaultsToNoParameterForMultipleParameters() {
        let arguments = [
            "parameters": [
                ["name": "param1", "type": "string"],
                ["name": "param2", "type": "integer"]
            ]
        ]
        
        let intent = DynamicAppIntentFactory.createIntent(
            identifier: "test_multi",
            title: "Test Multi Intent",
            description: "Test Description",
            arguments: arguments
        )
        
        XCTAssert(intent is NoParameterIntent)
    }
    
    // MARK: - AppIntentParameterInfo Tests
    
    func testAppIntentParameterInfoFromValidDict() {
        let dict: [String: Any] = [
            "name": "test_param",
            "title": "Test Parameter",
            "type": "string",
            "description": "A test parameter",
            "isOptional": true,
            "defaultValue": "default"
        ]
        
        let paramInfo = AppIntentParameterInfo.fromDict(dict)
        
        XCTAssertNotNil(paramInfo)
        XCTAssertEqual(paramInfo?.name, "test_param")
        XCTAssertEqual(paramInfo?.title, "Test Parameter")
        XCTAssertEqual(paramInfo?.type, .string)
        XCTAssertEqual(paramInfo?.description, "A test parameter")
        XCTAssertEqual(paramInfo?.isOptional, true)
        XCTAssertEqual(paramInfo?.defaultValue as? String, "default")
    }
    
    func testAppIntentParameterInfoFromInvalidDict() {
        let dict: [String: Any] = [
            "title": "Test Parameter"
            // Missing required "name" and "type"
        ]
        
        let paramInfo = AppIntentParameterInfo.fromDict(dict)
        
        XCTAssertNil(paramInfo)
    }
    
    // MARK: - AppIntentParameterType Tests
    
    func testAppIntentParameterTypeFromString() {
        XCTAssertEqual(AppIntentParameterType.fromString("string"), .string)
        XCTAssertEqual(AppIntentParameterType.fromString("integer"), .integer)
        XCTAssertEqual(AppIntentParameterType.fromString("boolean"), .boolean)
        XCTAssertEqual(AppIntentParameterType.fromString("double"), .double)
        XCTAssertEqual(AppIntentParameterType.fromString("date"), .date)
        XCTAssertEqual(AppIntentParameterType.fromString("url"), .url)
        XCTAssertEqual(AppIntentParameterType.fromString("file"), .file)
        XCTAssertEqual(AppIntentParameterType.fromString("entity"), .entity)
        XCTAssertEqual(AppIntentParameterType.fromString("unknown"), .string) // defaults to string
    }
    
    func testAppIntentParameterTypeSwiftType() {
        XCTAssert(AppIntentParameterType.string.swiftType() == String.self)
        XCTAssert(AppIntentParameterType.integer.swiftType() == Int.self)
        XCTAssert(AppIntentParameterType.boolean.swiftType() == Bool.self)
        XCTAssert(AppIntentParameterType.double.swiftType() == Double.self)
    }
    
    // MARK: - DonationMetadata Tests
    
    func testDonationMetadataInitialization() {
        let metadata = DonationMetadata(
            relevanceScore: 0.8,
            context: ["key": "value"],
            timestamp: Date()
        )
        
        XCTAssertEqual(metadata.relevanceScore, 0.8, accuracy: 0.001)
        XCTAssertEqual(metadata.context["key"] as? String, "value")
        XCTAssertNotNil(metadata.timestamp)
    }
    
    func testDonationMetadataRelevanceScoreClamping() {
        let highMetadata = DonationMetadata(
            relevanceScore: 1.5, // Should be clamped to 1.0
            context: [:],
            timestamp: Date()
        )
        XCTAssertEqual(highMetadata.relevanceScore, 1.0)
        
        let lowMetadata = DonationMetadata(
            relevanceScore: -0.5, // Should be clamped to 0.0
            context: [:],
            timestamp: Date()
        )
        XCTAssertEqual(lowMetadata.relevanceScore, 0.0)
    }
    
    // MARK: - IntentExecutionError Tests
    
    func testIntentExecutionErrorTypes() {
        let customError = IntentExecutionError.custom("Custom error message")
        XCTAssertEqual(customError.errorDescription, "Custom error message")
        
        let invalidParamsError = IntentExecutionError.invalidParameters
        XCTAssertEqual(invalidParamsError.errorDescription, "Invalid parameters provided")
        
        let executionFailedError = IntentExecutionError.executionFailed
        XCTAssertEqual(executionFailedError.errorDescription, "Intent execution failed")
        
        let paramResolutionError = IntentExecutionError.parameterResolutionFailed("testParam")
        XCTAssertEqual(paramResolutionError.errorDescription, "Failed to resolve parameter: testParam")
    }
    
    // MARK: - Plugin Integration Tests
    
    func testPluginSharedInstanceExists() {
        let plugin = FlutterAppIntentsPlugin.shared
        XCTAssertNotNil(plugin)
    }
    
    func testDefaultInitializersWorkWithAppIntentFramework() {
        // Test that default initializers work with iOS 16+ AppIntent requirements
        let noParamIntent = NoParameterIntent()
        let stringIntent = OneStringParameterIntent()
        let intIntent = OneIntegerParameterIntent()
        let boolIntent = OneBooleanParameterIntent()
        let doubleIntent = OneDoubleParameterIntent()
        
        // All should conform to AppIntent
        XCTAssert(noParamIntent is AppIntent)
        XCTAssert(stringIntent is AppIntent)
        XCTAssert(intIntent is AppIntent)
        XCTAssert(boolIntent is AppIntent)
        XCTAssert(doubleIntent is AppIntent)
        
        // All should have empty identifiers when using default init
        XCTAssertEqual(noParamIntent.intentIdentifier, "")
        XCTAssertEqual(stringIntent.intentIdentifier, "")
        XCTAssertEqual(intIntent.intentIdentifier, "")
        XCTAssertEqual(boolIntent.intentIdentifier, "")
        XCTAssertEqual(doubleIntent.intentIdentifier, "")
    }

}