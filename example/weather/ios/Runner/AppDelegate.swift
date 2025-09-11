/// Weather App Intents Example - iOS Static Intent Declarations
///
/// This file contains the static Swift App Intent declarations required for the
/// weather query example. These intents focus on query-based operations that can
/// provide information without opening the app interface.
///
/// Architecture:
/// - Static Swift intents (this file) - Required for iOS discovery at compile time
/// - Flutter handlers (lib/main.dart) - Handle business logic and data fetching
/// - Bridge communication - Static intents call Flutter handlers via the plugin
///
/// Query Intent Pattern:
/// Weather intents use `ProvidesDialog` to provide voice responses and work without
/// opening the app. They demonstrate background data processing and voice output.

import Flutter
import UIKit
import AppIntents
import flutter_app_intents

/// Custom error type for App Intent execution failures
enum AppIntentError: Error {
    case executionFailed(String)
}

/// Main application delegate - standard Flutter app delegate setup
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

// MARK: - Weather Query App Intents
//
// These static intent declarations are required for iOS to discover the intents
// at compile time. Each intent bridges to a corresponding Flutter handler and
// provides voice responses without opening the app.

/// Gets current weather conditions for a location
/// 
/// This intent demonstrates comprehensive weather data queries with voice output.
/// Uses ProvidesDialog to ensure Siri speaks the weather information aloud.
@available(iOS 16.0, *)
struct GetCurrentWeatherIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Current Weather"
    static var description = IntentDescription("Get current weather conditions for a location")
    static var isDiscoverable = true
    // Note: No openAppWhenRun - this works in background
    
    @Parameter(title: "Location")
    var location: String?
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "get_current_weather",
            parameters: ["location": location ?? "current location"]
        )
        
        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Weather information retrieved"
            return .result(
                value: value,
                dialog: IntentDialog(stringLiteral: value)  // Ensures Siri speaks result
            )
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to get weather"
            throw AppIntentError.executionFailed(errorMessage)
        }
    }
}

/// Gets current temperature for a specific location
/// 
/// This intent focuses on temperature-specific queries with concise voice output.
@available(iOS 16.0, *)
struct GetTemperatureIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Temperature"
    static var description = IntentDescription("Get current temperature for a location")
    static var isDiscoverable = true
    
    @Parameter(title: "Location")
    var location: String?
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "get_temperature",
            parameters: ["location": location ?? "current location"]
        )
        
        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Temperature retrieved"
            return .result(
                value: value,
                dialog: IntentDialog(stringLiteral: value)
            )
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to get temperature"
            throw AppIntentError.executionFailed(errorMessage)
        }
    }
}

/// Gets weather forecast for upcoming days
/// 
/// This intent demonstrates multi-parameter queries with formatted voice output.
@available(iOS 16.0, *)
struct GetWeatherForecastIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Weather Forecast"
    static var description = IntentDescription("Get weather forecast for upcoming days")
    static var isDiscoverable = true
    
    @Parameter(title: "Location")
    var location: String?
    
    @Parameter(title: "Number of Days")
    var days: Int?
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "get_weather_forecast",
            parameters: [
                "location": location ?? "current location",
                "days": days ?? 3
            ]
        )
        
        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Forecast retrieved"
            return .result(
                value: value,
                dialog: IntentDialog(stringLiteral: value)
            )
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to get forecast"
            throw AppIntentError.executionFailed(errorMessage)
        }
    }
}

/// Checks if it is currently raining at a location
/// 
/// This intent demonstrates boolean queries with simple yes/no voice responses.
@available(iOS 16.0, *)
struct CheckRainIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Rain"
    static var description = IntentDescription("Check if it is currently raining")
    static var isDiscoverable = true
    
    @Parameter(title: "Location")
    var location: String?
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "check_rain",
            parameters: ["location": location ?? "current location"]
        )
        
        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Rain status checked"
            return .result(
                value: value,
                dialog: IntentDialog(stringLiteral: value)
            )
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to check rain"
            throw AppIntentError.executionFailed(errorMessage)
        }
    }
}

// MARK: - App Shortcuts Provider
//
// This provider tells iOS about the available shortcuts for Siri and the Shortcuts app.
// Weather queries are designed to work without opening the app, providing quick voice access.

/// Defines the weather query shortcuts that appear in Siri and the iOS Shortcuts app
/// 
/// Each shortcut includes multiple phrase variations optimized for natural speech.
/// These queries demonstrate background operation patterns for data retrieval.
@available(iOS 16.0, *)
struct WeatherAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        // Current weather shortcut - comprehensive weather information
        AppShortcut(
            intent: GetCurrentWeatherIntent(),
            phrases: [
                "Get weather from \(.applicationName)",
                "Check weather using \(.applicationName)",
                "What's the weather in \(.applicationName)",
                "Current weather with \(.applicationName)"
            ],
            shortTitle: "Weather",
            systemImageName: "cloud.sun"
        )
        
        // Temperature shortcut - specific temperature queries
        AppShortcut(
            intent: GetTemperatureIntent(),
            phrases: [
                "Get temperature from \(.applicationName)",
                "Check temperature using \(.applicationName)", 
                "What's the temperature in \(.applicationName)",
                "How hot is it with \(.applicationName)"
            ],
            shortTitle: "Temperature",
            systemImageName: "thermometer"
        )
        
        // Forecast shortcut - multi-day weather planning
        AppShortcut(
            intent: GetWeatherForecastIntent(),
            phrases: [
                "Get forecast from \(.applicationName)",
                "Check forecast using \(.applicationName)",
                "What's the forecast in \(.applicationName)",
                "Weather forecast with \(.applicationName)"
            ],
            shortTitle: "Forecast",
            systemImageName: "calendar"
        )
        
        // Rain check shortcut - quick boolean queries
        AppShortcut(
            intent: CheckRainIntent(),
            phrases: [
                "Check rain using \(.applicationName)",
                "Is it raining with \(.applicationName)",
                "Rain check from \(.applicationName)",
                "Will it rain in \(.applicationName)"
            ],
            shortTitle: "Rain Check",
            systemImageName: "cloud.rain"
        )
    }
}
