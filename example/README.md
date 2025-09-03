# Flutter App Intents Example

This example application demonstrates how to use the `flutter_app_intents` package to integrate your Flutter app with Apple App Intents, enabling features like Siri voice commands, Shortcuts, and Spotlight search.

## Features Demonstrated

This example showcases the following features of the `flutter_app_intents` package:

-   **Intent Creation**: How to create multiple app intents with and without parameters using a fluent builder API.
-   **Intent Registration**: Registering intents with the system and associating them with handler functions.
-   **Parameter Handling**: Handling optional parameters passed to an intent.
-   **State Management**: Updating the application state and UI in response to intent invocations.
-   **Intent Donation**: Donating intents to the system to improve Siri's predictive capabilities.
-   **UI Feedback**: Displaying the status of intent registration and providing user guidance.
-   **Debugging**: Listing the registered intents for verification.

## Intents Implemented

The example app implements the following three intents for controlling a simple counter:

1.  **Increment Counter (`increment_counter`)**:
    -   Increments the counter.
    -   Accepts an optional `amount` parameter to specify how much to increment by.
    -   **Siri command**: "Hey Siri, increment counter" or "Hey Siri, increment counter by 5".

2.  **Reset Counter (`reset_counter`)**:
    -   Resets the counter to zero.
    -   **Siri command**: "Hey Siri, reset counter".

3.  **Get Counter Value (`get_counter`)**:
    -   Reads and returns the current value of the counter.
    -   This intent is eligible for Spotlight search.
    -   **Siri command**: "Hey Siri, get counter value".

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

-   [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
-   [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## How to Run the Example

1.  Make sure you have a working Flutter environment.
2.  This plugin requires **iOS 16.0 or later**. You will need a physical device or a simulator running a compatible iOS version.
3.  Open the `example` directory in your terminal.
4.  Run `flutter pub get` to fetch the dependencies.
5.  Run `flutter run` to build and launch the app on your connected device or simulator.

Once the app is running, you can:
-   Use the on-screen button to increment the counter manually.
-   Try the Siri commands listed above.
-   Open the Shortcuts app on your device to see the new actions available from this app.
-   Search for "Get Counter Value" in Spotlight.