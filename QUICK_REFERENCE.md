# Quick Reference Guide

## Key Concepts

### App Group Identifier
**Value**: `group.com.productivity.appblocker`
**Purpose**: Enables data sharing between main app and extensions
**Used in**: All 4 targets (main app + 3 extensions)
**Location**: UserDefaults, shield logic, statistics tracking

### Bundle Identifiers
- Main App: `com.yourcompany.ProductivityAppBlocker`
- Shield Configuration Extension: `com.yourcompany.ProductivityAppBlocker.ShieldConfigurationExtension`
- Shield Action Extension: `com.yourcompany.ProductivityAppBlocker.ShieldActionExtension`
- Device Activity Monitor Extension: `com.yourcompany.ProductivityAppBlocker.DeviceActivityMonitorExtension`

## Architecture Overview

```
User Selects Apps → Main App → ManagedSettingsStore → Shield Active
                                      ↓
                     BlockedAppsManager.updateShield()
                                      ↓
User Opens Blocked App → ShieldConfigurationProvider (Custom UI)
                                      ↓
                         ShieldActionProvider (Handle Buttons)
                                      ↓
                    "Yes, open it" or "No, stay focused"
                                      ↓
              DeviceActivityMonitor (Track & Manage Timing)
```

## Component Responsibilities

### 1. ProductivityAppBlockerApp.swift
- App entry point
- Requests Family Controls authorization on launch
- Injects `BlockedAppsManager` into environment

### 2. BlockedAppsManager.swift
**Core Logic Manager**
- Manages selected apps (`FamilyActivitySelection`)
- Controls `ManagedSettingsStore` shield
- Handles temporary allow logic
- Tracks usage statistics
- Coordinates midnight resets
- Uses shared UserDefaults (App Group)

### 3. ContentView.swift
**Dashboard UI**
- Displays statistics (blocked apps, interruptions, focus score)
- Navigation to settings
- Main user interface

### 4. SettingsView.swift
**Settings UI**
- FamilyActivityPicker for app selection
- Allow duration slider (5-120 minutes)
- Statistics display
- How It Works section

### 5. ShieldConfigurationProvider.swift
**Custom Shield UI**
- Defines shield appearance
- Shows usage count ("Opened X times today")
- Configures button labels
- Updates usage statistics
- Runs in system context when blocked app opens

### 6. ShieldActionProvider.swift
**Shield Button Handler**
- Handles "Yes, open it" → temporarily allows app
- Handles "No, stay focused" → keeps shield active
- Updates shared UserDefaults
- Tracks focus decisions

### 7. DeviceActivityMonitorExtension.swift
**Background Monitor**
- Monitors temporary allow expirations
- Re-enables shields after timeout
- Handles midnight resets
- Updates shield configuration dynamically

## Data Flow

### Shared Data (App Group UserDefaults)

| Key | Type | Purpose |
|-----|------|---------|
| `selectedAppsData` | Data | Serialized `FamilyActivitySelection` |
| `appOpenCounts` | Dictionary<String, Int> | Count of attempts per app |
| `focusDecisionCounts` | Dictionary<String, Int> | Count of "stay focused" choices |
| `temporarilyAllowedApps` | Dictionary<String, Date> | Apps with expiration times |
| `allowDurationMinutes` | Int | Duration for temporary allows |
| `lastResetDate` | Date | Last midnight reset timestamp |

## Common Code Patterns

### Accessing Shared UserDefaults
```swift
let appGroup = "group.com.productivity.appblocker"
let sharedDefaults = UserDefaults(suiteName: appGroup)
```

### Updating Shield
```swift
let managedSettings = ManagedSettingsStore()
managedSettings.shield.applications = selectedApps.applicationTokens
managedSettings.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(
    selectedApps.categoryTokens
)
```

### Temporary Allow Logic
```swift
// 1. Store expiration in shared defaults
let expirationTime = Date().addingTimeInterval(TimeInterval(minutes * 60))
allowedApps[appToken] = expirationTime
sharedDefaults.set(allowedApps, forKey: "temporarilyAllowedApps")

// 2. Remove from shield
var remainingApps = selectedApps.applicationTokens
remainingApps.remove(appToken)
managedSettings.shield.applications = remainingApps

// 3. Schedule re-enable
DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
    // Re-enable shield
}
```

## API Reference

### FamilyControls Framework

**AuthorizationCenter**
```swift
let center = AuthorizationCenter.shared
try await center.requestAuthorization(for: .individual)
```

**FamilyActivitySelection**
```swift
@Published var selectedApps = FamilyActivitySelection()
// Properties:
// - applicationTokens: Set<ApplicationToken>
// - categoryTokens: Set<ActivityCategoryToken>
```

**FamilyActivityPicker**
```swift
.familyActivityPicker(
    isPresented: $showingPicker,
    selection: $selectedApps
)
```

### ManagedSettings Framework

**ManagedSettingsStore**
```swift
let store = ManagedSettingsStore()
store.shield.applications = tokens
store.shield.applicationCategories = .specific(categoryTokens)
store.shield.webDomains = domainTokens
```

**ShieldSettings.ActivityCategoryPolicy**
```swift
.all(except: tokens)  // Block all except specified
.specific(tokens)     // Block only specified
```

### ManagedSettingsUI Framework

**ShieldConfiguration**
```swift
ShieldConfiguration(
    backgroundBlurStyle: .systemThickMaterial,
    backgroundColor: UIColor.systemBackground,
    icon: UIImage(systemName: "hand.raised.fill"),
    title: ShieldConfiguration.Label(text: "...", color: .label),
    subtitle: ShieldConfiguration.Label(text: "...", color: .secondaryLabel),
    primaryButtonLabel: ShieldConfiguration.Label(text: "...", color: .systemBlue),
    primaryButtonBackgroundColor: UIColor.systemBlue.withAlphaComponent(0.15),
    secondaryButtonLabel: ShieldConfiguration.Label(text: "...", color: .systemGreen),
    secondaryButtonBackgroundColor: UIColor.systemGreen.withAlphaComponent(0.15)
)
```

**ShieldActionResponse**
```swift
.close   // Dismiss shield, allow app to open
.defer   // Keep shield active, block app
.none    // No action
```

### DeviceActivity Framework

**DeviceActivityMonitor**
```swift
class MyMonitor: DeviceActivityMonitor {
    override func intervalDidStart(for activity: DeviceActivityName)
    override func intervalDidEnd(for activity: DeviceActivityName)
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName)
}
```

## Testing Checklist

- [ ] Family Controls authorization granted
- [ ] App Group configured on all 4 targets
- [ ] Can select apps using FamilyActivityPicker
- [ ] Shield appears when opening blocked app
- [ ] Usage count increments correctly
- [ ] "No, stay focused" keeps shield active
- [ ] "Yes, open it" temporarily allows app
- [ ] App re-blocks after allow duration expires
- [ ] Statistics reset at midnight
- [ ] Data persists across app launches

## Debugging Tips

### Enable Console Logs
In Xcode:
1. Run the app on device
2. Open **Window** → **Devices and Simulators**
3. Select your device → **Open Console**
4. Filter by process name: `ProductivityAppBlocker`

### Common Log Messages
- `✅ Family Controls authorization granted`
- `🛡️ Shield updated with X apps`
- `✅ App temporarily allowed until: [date]`
- `🎯 User chose to stay focused`
- `🔄 Daily counters reset`
- `⏱️ Temporary allow expired for app`

### Verify App Group
```swift
// Add to BlockedAppsManager init
if let sharedDefaults = UserDefaults(suiteName: appGroup) {
    print("✅ App Group accessible")
} else {
    print("❌ App Group NOT accessible")
}
```

### Check Extension Loading
```swift
// Add to each extension
print("🔧 Extension loaded: [ExtensionName]")
```

## Performance Considerations

### Shield Appearance Delay
- Shield appears AFTER app starts launching (iOS limitation)
- Typical delay: 0.5-1.5 seconds
- Cannot be eliminated, only minimized

### Battery Impact
- DeviceActivityMonitor runs in background
- Minimal impact when properly implemented
- Avoid excessive timer checks

### UserDefaults Sync
- Shared UserDefaults sync is not instant
- Allow 1-2 seconds for propagation between processes
- Use NotificationCenter for immediate updates (same process only)

## Customization Ideas

### UI Enhancements
- Custom color schemes (dark mode support)
- App icons for blocked apps in statistics
- Charts/graphs for usage trends
- Weekly/monthly statistics

### Feature Extensions
- Schedule blocking (only during work hours)
- Different allow durations per app
- "Focus Mode" presets (work, study, sleep)
- Widget for quick statistics
- Apple Watch app for tracking

### Advanced Monitoring
- Screen time limits per app
- Daily goals and streak tracking
- Notifications for milestones
- Export statistics to CSV/JSON

## Limitations & Workarounds

### Cannot Prevent Initial App Flash
**Limitation**: App briefly appears before shield
**Workaround**: None - this is an iOS platform constraint
**Impact**: Low - shield still appears within 1-2 seconds

### Simulator Not Supported
**Limitation**: Screen Time API doesn't work in Simulator
**Workaround**: Always test on physical device
**Impact**: Medium - requires device for all testing

### No Callback Before App Launch
**Limitation**: Cannot intercept BEFORE app opens
**Workaround**: Shield appears immediately after launch
**Impact**: Low - still effectively blocks the app

### Extension Debugging Challenges
**Limitation**: Extensions run in separate processes
**Workaround**: Use Console logs extensively
**Impact**: Medium - makes debugging more complex

## Security & Privacy

### Data Storage
- All data stored locally on device
- Uses iOS keychain for sensitive data (via App Group)
- No cloud sync (unless you add CloudKit)

### Permissions
- Family Controls: Required for Screen Time API
- App Groups: Required for data sharing
- No location, camera, or contacts access needed

### User Control
- User can disable app in Settings → Screen Time
- User can revoke Family Controls authorization
- User can delete app and all data

## App Store Guidelines

### Required Disclosures
- Clearly explain Screen Time usage in app description
- Privacy policy must describe data usage
- Screenshots must show actual app functionality

### Restricted Capabilities
- Family Controls requires Apple approval
- May require explanation of use case
- Intended for personal productivity, not parental controls

### Age Rating
- Suggested: 4+ (no objectionable content)
- Must not market to children under 13

## Resources

### Apple Documentation
- [Family Controls Framework](https://developer.apple.com/documentation/familycontrols)
- [ManagedSettings Framework](https://developer.apple.com/documentation/managedsettings)
- [DeviceActivity Framework](https://developer.apple.com/documentation/deviceactivity)
- [Screen Time API](https://developer.apple.com/documentation/screentime)

### WWDC Videos
- WWDC 2021: "Meet the Screen Time API"
- WWDC 2022: "What's new in Screen Time API"

### Sample Code
- This repository provides complete working implementation
- All code is commented with inline documentation
