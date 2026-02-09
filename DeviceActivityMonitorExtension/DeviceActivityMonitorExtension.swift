//
//  DeviceActivityMonitorExtension.swift
//  DeviceActivityMonitorExtension
//
//  Monitors device activity and manages shield updates based on temporary allows
//

import DeviceActivity
import FamilyControls
import ManagedSettings

/// Device Activity Monitor Extension
/// Monitors app usage and manages temporary allow periods
class DeviceActivityMonitorExtension: DeviceActivityMonitor {

    let appGroup = "group.com.productivity.appblocker"
    let managedSettings = ManagedSettingsStore()

    // MARK: - Interval Events

    /// Called when a device activity interval starts
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        print("📊 Activity interval started: \(activity)")

        // Check and clean up expired temporary allows
        checkAndUpdateTemporaryAllows()
    }

    /// Called when a device activity interval ends
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        print("📊 Activity interval ended: \(activity)")

        // Reset daily counters if this is the midnight reset interval
        if activity.rawValue == "dailyReset" {
            resetDailyCounters()
        }
    }

    // MARK: - Event Monitoring

    /// Called when an event threshold is reached (e.g., app launched)
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        print("⚠️ Event threshold reached: \(event) for activity: \(activity)")

        // Handle specific events
        if event.rawValue == "appLaunched" {
            handleAppLaunch()
        }
    }

    /// Called when warning time for an event is reached
    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        print("⏰ Event warning: \(event)")
    }

    // MARK: - Shield Management

    /// Check and update temporary allows, removing expired ones
    private func checkAndUpdateTemporaryAllows() {
        guard let sharedDefaults = UserDefaults(suiteName: appGroup) else { return }

        let allowedAppsKey = "temporarilyAllowedApps"
        var allowedApps = sharedDefaults.dictionary(forKey: allowedAppsKey) as? [String: Date] ?? [:]

        let now = Date()
        var hasChanges = false

        // Remove expired allows
        for (appToken, expirationDate) in allowedApps {
            if expirationDate < now {
                allowedApps.removeValue(forKey: appToken)
                hasChanges = true
                print("⏱️ Temporary allow expired for app: \(appToken)")
            }
        }

        // Save changes if any
        if hasChanges {
            sharedDefaults.set(allowedApps, forKey: allowedAppsKey)
            updateShieldConfiguration()
        }

        // Schedule next check in 1 minute
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) { [weak self] in
            self?.checkAndUpdateTemporaryAllows()
        }
    }

    /// Update the shield configuration based on current state
    private func updateShieldConfiguration() {
        guard let sharedDefaults = UserDefaults(suiteName: appGroup) else { return }

        // Get selected apps from UserDefaults
        let selectionKey = "selectedAppsData"
        guard let data = sharedDefaults.data(forKey: selectionKey),
              let selection = try? NSKeyedUnarchiver.unarchivedObject(
                  ofClass: FamilyActivitySelection.self,
                  from: data
              ) else {
            print("❌ Failed to load app selection")
            return
        }

        // Get temporarily allowed apps
        let allowedAppsKey = "temporarilyAllowedApps"
        let allowedApps = sharedDefaults.dictionary(forKey: allowedAppsKey) as? [String: Date] ?? [:]
        let now = Date()

        // Filter out currently allowed apps
        var appsToBlock = selection.applicationTokens
        for (appToken, expirationDate) in allowedApps {
            if expirationDate > now {
                // Find and remove the corresponding token
                // Note: This is a simplified approach; in production you'd need better token matching
                appsToBlock = appsToBlock.filter { $0.debugDescription != appToken }
            }
        }

        // Update shield
        managedSettings.shield.applications = appsToBlock.isEmpty ? nil : appsToBlock
        managedSettings.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil
            : ShieldSettings.ActivityCategoryPolicy.specific(selection.categoryTokens)

        print("🛡️ Shield updated: blocking \(appsToBlock.count) apps")
    }

    // MARK: - Usage Tracking

    /// Handle app launch event
    private func handleAppLaunch() {
        // This would be called when a monitored app is launched
        // Update statistics in shared UserDefaults
        print("📱 App launch detected")
    }

    /// Reset daily counters at midnight
    private func resetDailyCounters() {
        guard let sharedDefaults = UserDefaults(suiteName: appGroup) else { return }

        // Reset open counts
        sharedDefaults.set([String: Int](), forKey: "appOpenCounts")

        // Reset focus decision counts
        sharedDefaults.set([String: Int](), forKey: "focusDecisionCounts")

        // Update last reset date
        sharedDefaults.set(Date(), forKey: "lastResetDate")

        print("🔄 Daily counters reset at midnight")
    }
}
