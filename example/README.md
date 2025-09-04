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

## Architecture

This example demonstrates the **hybrid approach** required for Flutter App Intents:

1. **Static Swift App Intents** (`ios/Runner/AppDelegate.swift`) - Required for iOS discovery
2. **Flutter handlers** (`lib/main.dart`) - Your app's business logic
3. **Bridge communication** - Static intents call Flutter handlers via the plugin

## How to Run the Example

### Prerequisites
1. Flutter environment with iOS development setup
2. **iOS 16.0 or later** device or simulator
3. Xcode 14.0 or later

### Setup Steps

1. **Install dependencies**:
   ```bash
   cd example
   flutter pub get
   ```

2. **Verify iOS configuration**:
   - The example already includes the required static App Intents in `ios/Runner/AppDelegate.swift`
   - Info.plist is configured with necessary permissions
   - iOS deployment target is set to 16.0

3. **Run the app**:
   ```bash
   flutter run
   ```

### Testing the App Intents

Once the app is running:

1. **Manual Testing**:
   - Use the on-screen button to increment the counter manually

2. **Siri Commands** (try these specific phrases):
   - "Increment counter with flutter app intents example"
   - "Reset counter with flutter app intents example"  
   - "Get counter from flutter app intents example"

3. **Shortcuts App**:
   - Open the iOS Shortcuts app
   - Look for your app's shortcuts under "App Shortcuts"
   - You should see: Increment Counter, Reset Counter, Get Counter Value

4. **Settings Integration**:
   - Go to Settings > Siri & Search > App Shortcuts
   - Your app should appear with available shortcuts

### Troubleshooting

**Shortcuts not appearing?**
1. Ensure the app ran successfully and intents were registered (check console logs)
2. Wait a few seconds for iOS to register the static intents
3. Try restarting the Shortcuts app
4. Check that iOS is 16.0 or later

**Siri not recognizing commands?**
1. Use the exact phrases shown above
2. Try adding custom phrases in Settings > Siri & Search > App Shortcuts
3. Use the shortcuts manually first to help Siri learn

For more detailed troubleshooting, see the main [README](../README.md).