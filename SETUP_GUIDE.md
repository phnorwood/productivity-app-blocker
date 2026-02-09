# Detailed Setup Guide

This guide provides step-by-step instructions for setting up the Productivity App Blocker in Xcode.

## Prerequisites

- Mac with Xcode 14.0 or later installed
- Apple Developer Account (free or paid)
- Physical iOS device running iOS 16.0 or later
- USB cable to connect device to Mac

## Part 1: Create the Xcode Project

### 1.1 Create New Project

1. Open **Xcode**
2. Select **File** → **New** → **Project** (or press ⌘⇧N)
3. Choose **iOS** → **App** → **Next**
4. Fill in project details:
   - **Product Name**: `ProductivityAppBlocker`
   - **Team**: Select your Apple Developer team
   - **Organization Identifier**: `com.yourcompany` (use your actual domain/identifier)
   - **Bundle Identifier**: (auto-filled: `com.yourcompany.ProductivityAppBlocker`)
   - **Interface**: `SwiftUI`
   - **Language**: `Swift`
   - **Storage**: `None`
   - **Include Tests**: ✓ (optional)
5. Click **Next**, choose a location, and click **Create**

### 1.2 Configure Deployment Target

1. Select the project in the navigator
2. Select the **ProductivityAppBlocker** target
3. In **General** tab, set:
   - **Minimum Deployments**: iOS 16.0 or later

## Part 2: Add App Extensions

You need to add 3 app extensions to your project.

### 2.1 Add Shield Configuration Extension

1. **File** → **New** → **Target**
2. Choose **iOS** → Scroll to find **Shield Configuration Extension**
3. Click **Next**
4. Fill in:
   - **Product Name**: `ShieldConfigurationExtension`
   - **Team**: (same as main app)
   - **Bundle Identifier**: `com.yourcompany.ProductivityAppBlocker.ShieldConfigurationExtension`
5. Click **Finish**
6. When prompted "Activate ShieldConfigurationExtension scheme?", click **Activate**

### 2.2 Add Shield Action Extension

1. **File** → **New** → **Target**
2. Choose **iOS** → **Shield Action Extension**
3. Click **Next**
4. Fill in:
   - **Product Name**: `ShieldActionExtension`
   - **Team**: (same as main app)
   - **Bundle Identifier**: `com.yourcompany.ProductivityAppBlocker.ShieldActionExtension`
5. Click **Finish**

### 2.3 Add Device Activity Monitor Extension

1. **File** → **New** → **Target**
2. Choose **iOS** → **Device Activity Monitor Extension**
3. Click **Next**
4. Fill in:
   - **Product Name**: `DeviceActivityMonitorExtension`
   - **Team**: (same as main app)
   - **Bundle Identifier**: `com.yourcompany.ProductivityAppBlocker.DeviceActivityMonitorExtension`
5. Click **Finish**

## Part 3: Copy Source Files

### 3.1 Main App Files

Delete the default files and add the custom ones:

1. In Xcode navigator, delete:
   - `ContentView.swift` (we'll replace it)
   - `ProductivityAppBlockerApp.swift` (we'll replace it)

2. Add new files from this repository:
   - Right-click **ProductivityAppBlocker** folder → **Add Files to "ProductivityAppBlocker"**
   - Select:
     - `ProductivityAppBlockerApp.swift`
     - `ContentView.swift`
     - `SettingsView.swift`
     - `BlockedAppsManager.swift`
   - Ensure **Target Membership**: Only `ProductivityAppBlocker` is checked

### 3.2 Shield Configuration Extension Files

1. In the **ShieldConfigurationExtension** folder, delete the default:
   - `ShieldConfigurationProvider.swift`

2. Add the custom file:
   - Right-click **ShieldConfigurationExtension** folder → **Add Files**
   - Select `ShieldConfigurationProvider.swift`
   - Ensure **Target Membership**: Only `ShieldConfigurationExtension` is checked

### 3.3 Shield Action Extension Files

1. In the **ShieldActionExtension** folder, delete the default:
   - `ShieldActionProvider.swift`

2. Add the custom file:
   - Right-click **ShieldActionExtension** folder → **Add Files**
   - Select `ShieldActionProvider.swift`
   - Ensure **Target Membership**: Only `ShieldActionExtension` is checked

### 3.4 Device Activity Monitor Extension Files

1. In the **DeviceActivityMonitorExtension** folder, delete the default:
   - `DeviceActivityMonitorExtension.swift`

2. Add the custom file:
   - Right-click **DeviceActivityMonitorExtension** folder → **Add Files**
   - Select `DeviceActivityMonitorExtension.swift`
   - Ensure **Target Membership**: Only `DeviceActivityMonitorExtension` is checked

## Part 4: Configure Capabilities

You must configure capabilities for ALL 4 targets.

### 4.1 Main App Capabilities

1. Select **ProductivityAppBlocker** target
2. Select **Signing & Capabilities** tab
3. Click **+ Capability** button
4. Add **Family Controls** (search for it)
5. Click **+ Capability** again
6. Add **App Groups**
7. In App Groups section, click **+**
8. Enter: `group.com.productivity.appblocker` (or customize with your identifier)
9. Click **OK**

### 4.2 ShieldConfigurationExtension Capabilities

1. Select **ShieldConfigurationExtension** target
2. Select **Signing & Capabilities** tab
3. Add **Family Controls** capability
4. Add **App Groups** capability
5. Enable the SAME app group: `group.com.productivity.appblocker`

### 4.3 ShieldActionExtension Capabilities

1. Select **ShieldActionExtension** target
2. Select **Signing & Capabilities** tab
3. Add **Family Controls** capability
4. Add **App Groups** capability
5. Enable the SAME app group: `group.com.productivity.appblocker`

### 4.4 DeviceActivityMonitorExtension Capabilities

1. Select **DeviceActivityMonitorExtension** target
2. Select **Signing & Capabilities** tab
3. Add **Family Controls** capability
4. Add **App Groups** capability
5. Enable the SAME app group: `group.com.productivity.appblocker`

⚠️ **CRITICAL**: All 4 targets MUST use the exact same App Group identifier!

## Part 5: Update Info.plist Files

### 5.1 Main App Info.plist

1. Select **ProductivityAppBlocker** → **Info.plist**
2. Add new entry:
   - **Key**: `NSFamilyControlsUsageDescription`
   - **Type**: String
   - **Value**: `This app needs access to Screen Time to help you block distracting apps and stay focused on your productivity goals.`

Or replace the entire file with the provided `ProductivityAppBlocker/Info.plist`

### 5.2 Extension Info.plist Files

The extension Info.plist files should already be correctly configured if you used Xcode's templates. Verify these keys:

**ShieldConfigurationExtension/Info.plist:**
- `NSExtension` → `NSExtensionPointIdentifier`: `com.apple.ManagedSettingsUI.ShieldConfiguration`
- `NSExtension` → `NSExtensionPrincipalClass`: `$(PRODUCT_MODULE_NAME).ShieldConfigurationProvider`

**ShieldActionExtension/Info.plist:**
- `NSExtension` → `NSExtensionPointIdentifier`: `com.apple.ManagedSettingsUI.ShieldAction`
- `NSExtension` → `NSExtensionPrincipalClass`: `$(PRODUCT_MODULE_NAME).ShieldActionProvider`

**DeviceActivityMonitorExtension/Info.plist:**
- `NSExtension` → `NSExtensionPointIdentifier`: `com.apple.device-activity.monitor`
- `NSExtension` → `NSExtensionPrincipalClass`: `$(PRODUCT_MODULE_NAME).DeviceActivityMonitorExtension`

## Part 6: Update App Group Identifier (If Needed)

If you used a different App Group identifier than `group.com.productivity.appblocker`, you need to update it in the source code:

1. Open **Find & Replace** (⌘⌥F)
2. Find: `group.com.productivity.appblocker`
3. Replace with: Your actual App Group identifier
4. Click **Replace All**
5. Verify changes in:
   - `BlockedAppsManager.swift`
   - `ShieldConfigurationProvider.swift`
   - `ShieldActionProvider.swift`
   - `DeviceActivityMonitorExtension.swift`

## Part 7: Build and Run

### 7.1 Connect Physical Device

1. Connect your iPhone/iPad via USB cable
2. Trust the computer on your device if prompted
3. In Xcode, select your device from the device dropdown (top toolbar)

### 7.2 Build the Project

1. Select the **ProductivityAppBlocker** scheme (not an extension scheme)
2. Click the **Build** button (⌘B)
3. Fix any build errors if they appear

### 7.3 Run on Device

1. Click the **Run** button (⌘R) or Product → Run
2. Xcode will install the app on your device
3. If you see "Untrusted Developer" on device:
   - Go to Settings → General → VPN & Device Management
   - Tap your developer account
   - Tap "Trust [Your Name]"
4. Launch the app again

### 7.4 Grant Permissions

When the app launches:
1. You'll see a Family Controls authorization prompt
2. Tap **Continue**
3. Authenticate with Face ID/Touch ID/Passcode
4. Grant permission

## Part 8: Test the App

### 8.1 Select Apps to Block

1. Tap **"Manage Blocked Apps"** button
2. Tap **"Select Apps to Block"**
3. In the Family Activity Picker, select a few apps (e.g., Instagram, Twitter)
4. Tap **Done**

### 8.2 Test the Shield

1. Exit the Productivity App Blocker
2. Try to open one of the blocked apps
3. You should see:
   - Brief flash of the app (expected)
   - Custom shield screen appears
   - Shows "You've tried to open this app X time(s) today"
   - Two buttons: "Yes, open it" and "No, stay focused"

### 8.3 Test "No, stay focused"

1. Tap **"No, stay focused"**
2. You should return to the home screen
3. The app remains blocked

### 8.4 Test "Yes, open it"

1. Try to open the blocked app again
2. Tap **"Yes, open it"**
3. The shield should close and app should be accessible
4. The app will be unblocked for the configured duration (default: 15 minutes)

## Troubleshooting

### Build Errors

**Error: "Family Controls capability requires a paid Apple Developer account"**
- Solution: Enroll in the Apple Developer Program ($99/year)

**Error: "No such module 'FamilyControls'"**
- Solution: Ensure deployment target is iOS 16.0 or later

**Error: "App Group not found"**
- Solution: Make sure you've added the App Group capability to ALL 4 targets

### Runtime Issues

**Shield doesn't appear:**
1. Check Console logs in Xcode for errors
2. Verify Family Controls authorization was granted
3. Rebuild all targets (Product → Clean Build Folder, then rebuild)
4. Restart the device

**Statistics not updating:**
1. Verify App Group identifier is consistent across all files
2. Check that extensions are embedded in the app bundle
3. Review Console logs for UserDefaults errors

**Temporary allow not working:**
1. Check Console logs in DeviceActivityMonitor extension
2. Verify ShieldActionExtension is properly configured
3. Test with longer allow duration (e.g., 60 minutes)

## Next Steps

- Customize the UI to match your brand
- Add more detailed statistics
- Implement custom scheduling (e.g., only block during work hours)
- Add iCloud sync for settings (requires CloudKit capability)
- Prepare for App Store submission

## Support

If you encounter issues:
1. Check the main README.md for known limitations
2. Review Apple's Screen Time API documentation
3. Check Console logs in Xcode for error messages
4. Verify all setup steps were completed correctly
