---
sidebar_position: 12
---

# Migration Guide

This guide provides instructions for migrating between major versions of the `flutter_app_intents` package.

## Upgrading to v0.8.0

Version `0.8.0` introduces an optional code generation feature to automate the creation of native platform code (Swift for iOS and XML for Android). While this is not a breaking change and manual implementation is still supported, migrating to the new workflow is recommended for a more streamlined development experience.

### Migrating to Code Generation

Follow these steps to adopt the new code generation workflow for existing projects:

1.  **Add Categories to Intents**: In your Dart code, add the `.category(IntentCategory.xxx)` property to your existing `AppIntentBuilder` definitions. This helps the generator assign appropriate SF Symbols on iOS.

    ```dart
    // Before
    AppIntentBuilder(
      intentName: 'my_intent',
      // ...
    );

    // After
    AppIntentBuilder(
      intentName: 'my_intent',
      // ...
    ).category(IntentCategory.fitness);
    ```

2.  **Run the Code Generator**: Execute the CLI tool to generate the platform-specific files.

    ```bash
    dart run flutter_app_intents:app_intents_cli
    ```
    You can also target a specific platform, for example:
    ```bash
    dart run flutter_app_intents:app_intents_cli --platform=ios
    ```

3.  **Replace Manual Swift Code (iOS)**: If you previously had a manual App Intents implementation in your `AppDelegate.swift`, you can now replace it. The generator creates a new file at `ios/Runner/AppShortcuts.swift`.

4.  **Add Generated File to Xcode (iOS)**: Drag and drop the newly generated `ios/Runner/AppShortcuts.swift` file into your Xcode project under the `Runner/Runner` group.

5.  **Clean Up**: You can now safely remove your old manual `AppIntent` definitions from your Swift code.

### Breaking Changes

There are no breaking changes in this version. The code generation feature is optional, and existing manual workflows will continue to function as before.