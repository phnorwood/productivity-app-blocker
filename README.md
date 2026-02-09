# Productivity App Blocker

An iOS app that uses Apple's Screen Time API to help you stay focused by blocking user-specified apps with customizable interruption prompts.

## Features

- 🛡️ **App Blocking**: Select which apps to block using the native FamilyActivityPicker
- 📊 **Usage Statistics**: Track how many times you've attempted to open blocked apps
- ⏱️ **Temporary Access**: Choose to temporarily allow blocked apps (5-120 minutes)
- 🎯 **Smart Prompts**: Custom shield screens ask "Are you sure?" when you try to open blocked apps
- 🌙 **Daily Reset**: Statistics automatically reset at midnight
- 💪 **Focus Tracking**: See how often you choose to stay focused

## Requirements

- iOS 16.0 or later
- Xcode 14.0 or later
- Apple Developer Account (for Family Controls capability)
- Physical iOS device (Screen Time API doesn't work in Simulator)

## Architecture

The app consists of 4 components:

### 1. Main App (`ProductivityAppBlocker`)
- SwiftUI interface for app selection and statistics
- Manages blocked app list and settings
- Requests Family Controls authorization

### 2. Shield Configuration Extension
- Provides custom UI for the shield screen
- Shows app usage statistics when shield appears
- Displays "Yes, open it" / "No, stay focused" buttons

### 3. Shield Action Extension
- Handles user interactions with shield buttons
- Implements temporary allow logic
- Tracks focus decisions for statistics

### 4. Device Activity Monitor Extension
- Tracks app launches and usage patterns
- Manages temporary allow expirations
- Resets daily counters at midnight

## Setup Instructions

### Step 1: Create Xcode Project

1. Open Xcode and create a new **App** project
2. Set these values:
   - **Product Name**: ProductivityAppBlocker
   - **Interface**: SwiftUI
   - **Lifecycle**: SwiftUI App
   - **Language**: Swift
   - **Minimum Deployment**: iOS 16.0

### Step 2: Add App Extensions

Add three App Extensions to your project:

#### Shield Configuration Extension
1. File → New → Target → Shield Configuration Extension
2. **Product Name**: ShieldConfigurationExtension
3. **Bundle Identifier**: `com.yourcompany.ProductivityAppBlocker.ShieldConfigurationExtension`

#### Shield Action Extension
1. File → New → Target → Shield Action Extension
2. **Product Name**: ShieldActionExtension
3. **Bundle Identifier**: `com.yourcompany.ProductivityAppBlocker.ShieldActionExtension`

#### Device Activity Monitor Extension
1. File → New → Target → Device Activity Monitor Extension
2. **Product Name**: DeviceActivityMonitorExtension
3. **Bundle Identifier**: `com.yourcompany.ProductivityAppBlocker.DeviceActivityMonitorExtension`

### Step 3: Copy Source Files

Copy the source files from this repository into your Xcode project:

**Main App:**
- `ProductivityAppBlocker/ProductivityAppBlockerApp.swift`
- `ProductivityAppBlocker/ContentView.swift`
- `ProductivityAppBlocker/SettingsView.swift`
- `ProductivityAppBlocker/BlockedAppsManager.swift`

**Extensions:**
- `ShieldConfigurationExtension/ShieldConfigurationProvider.swift`
- `ShieldActionExtension/ShieldActionProvider.swift`
- `DeviceActivityMonitorExtension/DeviceActivityMonitorExtension.swift`

### Step 4: Configure Capabilities

For **each target** (Main App + 3 Extensions):

1. Select target → **Signing & Capabilities**
2. Add **Family Controls** capability
3. Add **App Groups** capability
   - Enable the group: `group.com.productivity.appblocker`
   - (You may need to customize this based on your team ID)

### Step 5: Configure Info.plist Files

Make sure each target has the correct Info.plist configuration:

**Main App Info.plist:**
- Add `NSFamilyControlsUsageDescription` with a description

**Extension Info.plist files:**
- Ensure `NSExtensionPointIdentifier` matches:
  - ShieldConfiguration: `com.apple.ManagedSettingsUI.ShieldConfiguration`
  - ShieldAction: `com.apple.ManagedSettingsUI.ShieldAction`
  - DeviceActivityMonitor: `com.apple.device-activity.monitor`

### Step 6: Update Bundle Identifiers

Update the App Group name if needed:
- Search for `group.com.productivity.appblocker` in all files
- Replace with your App Group identifier (must start with `group.`)
- Make sure it's consistent across all files and entitlements

### Step 7: Build and Run

1. Connect a **physical iOS device** (Screen Time API doesn't work in Simulator)
2. Select your device as the build target
3. Build and run the main app target
4. Grant Screen Time permission when prompted
5. Select apps to block in Settings
6. Try opening a blocked app to see the shield

## How It Works

### 1. Authorization
On first launch, the app requests Family Controls authorization. This is required to use the Screen Time API.

### 2. App Selection
Users select which apps to block using Apple's native `FamilyActivityPicker`. Selected apps are saved to shared UserDefaults (App Group).

### 3. Shield Activation
When a user tries to open a blocked app:
1. The app briefly flashes (unavoidable limitation of Screen Time API)
2. The custom shield screen appears immediately
3. Usage count increments ("Opened X times today")
4. User sees two options: "Yes, open it" or "No, stay focused"

### 4. User Decision
- **"Yes, open it"**: App is temporarily removed from shield for configured duration (default: 15 minutes)
- **"No, stay focused"**: Shield remains active, user returns to home screen

### 5. Statistics Tracking
- All attempts to open blocked apps are counted
- Focus decisions are tracked separately
- Counters reset at midnight automatically

## Configuration

### Allow Duration
In Settings, adjust how long apps remain unblocked after choosing "Yes, open it":
- Minimum: 5 minutes
- Maximum: 120 minutes (2 hours)
- Default: 15 minutes

## Known Limitations

### 1. App Flash Before Shield
Due to Screen Time API constraints, blocked apps will briefly flash before the shield appears. This is expected behavior and cannot be prevented.

### 2. Physical Device Required
Screen Time API does not work in the iOS Simulator. You must test on a real device.

### 3. Authorization Required
Users must grant Screen Time permission. If denied, the app cannot function.

### 4. Shield Timing
The shield appears after the app starts launching, not before. This is a platform limitation.

## Troubleshooting

### Shield Not Appearing
1. Verify Family Controls authorization was granted
2. Check that all entitlements are properly configured
3. Ensure App Group is enabled and matching across all targets
4. Rebuild all targets (Main App + Extensions)

### Statistics Not Updating
1. Verify App Group name is consistent across all files
2. Check that extensions are included in the app bundle
3. Review Console logs for errors

### Temporary Allow Not Working
1. Ensure ShieldActionExtension is properly configured
2. Verify App Group UserDefaults are accessible
3. Check that timer logic in DeviceActivityMonitor is running

## App Store Submission

Before submitting to App Store:

1. **Update Bundle IDs**: Change from `com.productivity.appblocker` to your unique identifier
2. **Update App Group**: Change `group.com.productivity.appblocker` to match your team
3. **Review Privacy**: Ensure `NSFamilyControlsUsageDescription` clearly explains usage
4. **Test Thoroughly**: Verify on multiple iOS devices
5. **Screenshots**: Prepare App Store screenshots showing shield in action

### Required Capabilities
- Family Controls (requires approval from Apple)
- App Groups (automatically approved)

## Privacy

This app:
- ✅ Only accesses apps that the user explicitly selects
- ✅ All data stays on-device (no cloud sync)
- ✅ No analytics or tracking
- ✅ No network requests
- ✅ Follows Apple's privacy guidelines

## File Structure

```
ProductivityAppBlocker/
├── ProductivityAppBlocker/
│   ├── ProductivityAppBlockerApp.swift      # Main app entry point
│   ├── ContentView.swift                     # Dashboard view
│   ├── SettingsView.swift                    # App selection & settings
│   ├── BlockedAppsManager.swift              # Core blocking logic
│   ├── Info.plist                            # App configuration
│   └── ProductivityAppBlocker.entitlements   # App capabilities
├── ShieldConfigurationExtension/
│   ├── ShieldConfigurationProvider.swift     # Custom shield UI
│   ├── Info.plist                            # Extension configuration
│   └── ShieldConfigurationExtension.entitlements
├── ShieldActionExtension/
│   ├── ShieldActionProvider.swift            # Shield button handlers
│   ├── Info.plist                            # Extension configuration
│   └── ShieldActionExtension.entitlements
└── DeviceActivityMonitorExtension/
    ├── DeviceActivityMonitorExtension.swift  # Usage monitoring
    ├── Info.plist                            # Extension configuration
    └── DeviceActivityMonitorExtension.entitlements
```

## License

This code is provided as-is for educational and development purposes.

## Credits

Built with:
- FamilyControls framework
- ManagedSettings framework
- DeviceActivity framework
- SwiftUI
