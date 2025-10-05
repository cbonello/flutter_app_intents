---
sidebar_position: 12
---

# Migration Guide

This guide provides instructions for migrating between major versions of the `flutter_app_intents` package.

## Upgrading to v0.8.0

Version 0.8.0 introduces automatic code generation for both **iOS** and **Android** platforms, significantly simplifying setup and maintenance. This is an **optional, non-breaking change** - your existing manual implementation will continue to work.

### What's New

- ✨ **iOS Code Generation**: Automatically generate Swift `AppShortcuts.swift` from Dart
- ✨ **Android Support**: Automatically generate `shortcuts.xml` for Google Assistant integration
- ✨ **Unified CLI**: Single `app_intents_cli` command for both platforms
- ✨ **Global Installation**: Optional `dart pub global activate flutter_app_intents`
- ✨ **Watch Mode**: Auto-regenerate on file changes with `--watch`

### Breaking Changes

**None!** v0.8.0 is fully backward compatible. Continue using manual Swift/XML or migrate to code generation.

---

## Migration Options

### Option 1: Keep Manual Setup (No Changes Required)

Your existing code works as-is:

```dart
final myIntent = AppIntentBuilder()
    .identifier('my_intent')
    .title('My Intent')
    .description('Does something')
    .build();

await client.registerIntent(myIntent, handleMyIntent);
```

Your hand-written Swift intents and Android shortcuts continue working perfectly.

### Option 2: Migrate to Code Generation (Recommended)

**Benefits:**
- Single source of truth (Dart definitions)
- Faster iteration with watch mode
- Reduced boilerplate
- Cross-platform consistency

---

## Step-by-Step Migration

### Step 1: Add Categories to Intents

The code generator requires a `category` for each intent to:
- Map to appropriate SF Symbols on iOS
- Map to Built-in Intents (BII) on Android

```dart
// Before (v0.7.0)
final myIntent = AppIntentBuilder()
    .identifier('start_workout')
    .title('Start Workout')
    .description('Begin a fitness session')
    .build();

// After (v0.8.0) - Add category
final myIntent = AppIntentBuilder()
    .identifier('start_workout')
    .title('Start Workout')
    .description('Begin a fitness session')
    .category(IntentCategory.fitness)  // 👈 Add this
    .build();
```

**Available Categories:**

| Category | iOS SF Symbol | Android BII | Example Use |
|----------|--------------|-------------|-------------|
| `general` | `app.fill` | `OPEN_APP_FEATURE` | General actions |
| `fitness` | `figure.run` | `START_EXERCISE` | Workouts |
| `messaging` | `message.fill` | `SEND_MESSAGE` | Send messages |
| `navigation` | `map.fill` | `GET_DIRECTIONS` | Maps/directions |
| `music` | `music.note` | `PLAY_MUSIC` | Play music |
| `calling` | `phone.fill` | `CALL_CONTACT` | Make calls |

See [IntentCategory API](./api-reference#intentcategory) for all 20+ categories.

### Step 2: Install the CLI (Optional but Convenient)

```bash
# Option A: Run from your project (recommended for most users)
dart run flutter_app_intents:app_intents_cli

# Option B: Install globally (convenient for frequent use)
dart pub global activate flutter_app_intents
app_intents_cli
```

### Step 3: Generate Platform Code

```bash
# Generate for all available platforms (auto-detects ios/ and android/ directories)
dart run flutter_app_intents:app_intents_cli

# Or target specific platforms
dart run flutter_app_intents:app_intents_cli --platform=ios
dart run flutter_app_intents:app_intents_cli --platform=android
dart run flutter_app_intents:app_intents_cli --platform=android,ios

# Enable watch mode for automatic regeneration
dart run flutter_app_intents:app_intents_cli --watch
```

**Generated Files:**
- **iOS**: `ios/Runner/AppShortcuts.swift`
- **Android**: `android/app/src/main/res/xml/shortcuts.xml`

### Step 4: iOS - Replace Manual Swift Code

If you previously wrote Swift intents manually:

1. **Remove old manual Swift code** from `AppDelegate.swift`:
   ```swift
   // Remove these manual structs
   struct MyIntent: AppIntent { ... }
   struct MyAppShortcuts: AppShortcutsProvider { ... }
   ```

2. **Add generated file to Xcode**:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Right-click on "Runner" → "Add Files to Runner"
   - Select `ios/Runner/AppShortcuts.swift`
   - Check "Copy items if needed" and "Runner" target

3. **Hot restart** your app (press `R` in Flutter terminal)

### Step 5: Android - Use Generated shortcuts.xml

The generator creates `android/app/src/main/res/xml/shortcuts.xml` automatically.

1. **Verify AndroidManifest.xml** has the meta-data reference:

```xml
<activity android:name=".MainActivity">
    <meta-data
        android:name="android.app.shortcuts"
        android:resource="@xml/shortcuts" />

    <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
</activity>
```

2. **Hot restart** your app (press `R` in Flutter terminal)

### Step 6: Test

**iOS (Siri):**
```
1. Open Shortcuts app
2. Find your app's shortcuts
3. Enable Siri toggle (OFF by default)
4. Say "Hey Siri, [action] with [Your App Name]"
```

**Android (Google Assistant):**
```
1. Say "Hey Google, talk to [Your App Name]"
2. Say "Hey Google, [action] with [Your App Name]"
```

---

## Common Migration Questions

### Q: Do I need to migrate immediately?

**A:** No! v0.8.0 is fully backward compatible. Continue with manual setup as long as you want.

### Q: Can I use code generation for iOS but manual for Android?

**A:** Yes! Target specific platforms:

```bash
dart run flutter_app_intents:app_intents_cli --platform=ios
```

### Q: What if I have custom Swift code in my intents?

**A:** If you have complex custom logic:
1. **Recommended**: Move business logic to Dart handlers
2. Keep manual Swift intents for full control
3. Extend generated code (will be overwritten on regeneration)

Generated files have this header:
```swift
// AUTO-GENERATED by flutter_app_intents:generate
// DO NOT EDIT MANUALLY
```

### Q: Will the generator overwrite my changes?

**A:** Yes, generated files are overwritten each time. Keep customization in Dart handlers.

### Q: How do I customize Siri phrases?

**A:** The generator creates default phrases from your intent title. For custom phrases:
1. Edit generated `AppShortcuts.swift` (overwritten on regeneration)
2. Continue using manual Swift intents for full phrase control

### Q: What about intent parameters?

**A:**
- **iOS**: Parameters are supported - define them with `.parameter()` in Dart
- **Android**: Parameters passed via deep links (works now)
- Both platforms: Process parameters in your Dart handler

Example with parameters:
```dart
final intent = AppIntentBuilder()
    .identifier('send_message')
    .title('Send Message')
    .category(IntentCategory.messaging)
    .parameter(AppIntentParameter(
      name: 'recipient',
      title: 'Recipient',
      type: AppIntentParameterType.string,
    ))
    .build();
```

### Q: Does watch mode work with hot reload?

**A:** Watch mode regenerates files, but you need **hot restart** (not hot reload):
- Hot reload (`r`) - Only updates Dart code
- Hot restart (`R`) - Reloads native platform resources

Press `R` (capital R) after regeneration to load new native code.

---

## Feature Comparison

| Feature | v0.7.0 | v0.8.0 |
|---------|--------|--------|
| iOS Siri Integration | ✅ Manual Swift | ✅ Manual or Generated |
| Android Google Assistant | ❌ Not supported | ✅ Generated XML |
| Code Generation | ❌ Manual only | ✅ Automatic for both platforms |
| Global CLI | ❌ Not available | ✅ Optional install |
| Watch Mode | ❌ Not available | ✅ Auto-regenerate |
| Intent Parameters | ✅ Manual only | ✅ Supported in generator |
| Cross-platform | iOS only | iOS + Android |

---

## Troubleshooting Migration

### Generated files not found

```bash
# Ensure you're in the project root
cd your_flutter_project/

# Check for platform directories
ls ios/        # Should exist for iOS
ls android/    # Should exist for Android

# Run generator with explicit platform
dart run flutter_app_intents:app_intents_cli --platform=ios,android
```

### Siri/Google Assistant not recognizing new intents

```bash
# After regeneration, use HOT RESTART (not hot reload)
flutter run
# Then press R (capital R) in terminal

# Or rebuild from scratch
flutter clean
flutter run
```

### "AppShortcuts.swift file not found" in Xcode

1. Verify file was generated: `ls ios/Runner/AppShortcuts.swift`
2. Add to Xcode: Right-click Runner → Add Files → Select `AppShortcuts.swift`
3. Check "Runner" target is selected

### Android shortcuts.xml validation errors

```bash
# Regenerate with fresh output
dart run flutter_app_intents:app_intents_cli --platform=android

# Verify package name matches build.gradle
grep "applicationId" android/app/build.gradle
grep "targetPackage" android/app/src/main/res/xml/shortcuts.xml
```

---

## Getting Help

- Check the [Troubleshooting Guide](./troubleshooting)
- Review [Examples](./examples) showing code generation
- See [iOS Configuration](./ios-configuration) and [Android Configuration](./android-configuration)
- Open an [issue on GitHub](https://github.com/christophebonello/flutter_app_intents/issues)

---

## Migrating from Earlier Versions

### From v0.6.x or Earlier

If upgrading from v0.6.x:
1. Follow the v0.7.0 migration (intent donation API changes)
2. Then follow the v0.8.0 migration above

See [CHANGELOG.md](https://github.com/christophebonello/flutter_app_intents/blob/main/CHANGELOG.md) for complete version history.