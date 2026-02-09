//
//  BlockedAppsManager.swift
//  ProductivityAppBlocker
//
//  Manages blocked apps state and Screen Time shielding
//

import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity

class BlockedAppsManager: ObservableObject {
    static let shared = BlockedAppsManager()

    // Selected apps to block
    @Published var selectedApps = FamilyActivitySelection() {
        didSet {
            // Save selection to UserDefaults for persistence
            saveSelection()
            // Update shield configuration
            updateShield()
        }
    }

    // Temporarily allowed apps (unblocked for X minutes)
    @Published var temporarilyAllowedApps: Set<String> = []

    // Usage statistics
    @Published var appOpenCounts: [String: Int] = [:]

    // Settings
    @Published var allowDurationMinutes: Int = 15 // Default: 15 minutes

    private let managedSettings = ManagedSettingsStore()

    // Use App Group for sharing data with extensions
    private let appGroup = "group.com.productivity.appblocker"
    private var userDefaults: UserDefaults {
        UserDefaults(suiteName: appGroup) ?? UserDefaults.standard
    }

    private let selectionKey = "selectedAppsData"
    private let openCountsKey = "appOpenCounts"
    private let allowDurationKey = "allowDurationMinutes"
    private let lastResetDateKey = "lastResetDate"
    private let allowedAppsKey = "temporarilyAllowedApps"
    private let focusCountKey = "focusDecisionCounts"

    private init() {
        loadSelection()
        loadSettings()
        checkAndResetDailyCounters()
    }

    // MARK: - Selection Management

    /// Save selected apps to UserDefaults
    private func saveSelection() {
        do {
            let data = try NSKeyedArchiver.archivedData(
                withRootObject: selectedApps,
                requiringSecureCoding: true
            )
            userDefaults.set(data, forKey: selectionKey)
        } catch {
            print("❌ Failed to save selection: \(error)")
        }
    }

    /// Load selected apps from UserDefaults
    private func loadSelection() {
        guard let data = userDefaults.data(forKey: selectionKey) else { return }

        do {
            if let selection = try NSKeyedUnarchiver.unarchivedObject(
                ofClass: FamilyActivitySelection.self,
                from: data
            ) {
                selectedApps = selection
                updateShield()
            }
        } catch {
            print("❌ Failed to load selection: \(error)")
        }
    }

    /// Load settings from UserDefaults
    private func loadSettings() {
        if let counts = userDefaults.dictionary(forKey: openCountsKey) as? [String: Int] {
            appOpenCounts = counts
        }

        let duration = userDefaults.integer(forKey: allowDurationKey)
        if duration > 0 {
            allowDurationMinutes = duration
        }
    }

    // MARK: - Shield Management

    /// Update the shield configuration to block selected apps
    func updateShield() {
        // Clear any existing shield
        managedSettings.shield.applications = nil
        managedSettings.shield.applicationCategories = nil
        managedSettings.shield.webDomains = nil

        // Apply new shield to selected apps (excluding temporarily allowed)
        if !selectedApps.applicationTokens.isEmpty || !selectedApps.categoryTokens.isEmpty {
            managedSettings.shield.applications = selectedApps.applicationTokens
            managedSettings.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(
                selectedApps.categoryTokens
            )
        }

        print("🛡️ Shield updated with \(selectedApps.applicationTokens.count) apps")
    }

    /// Temporarily allow an app (remove from shield for X minutes)
    func temporarilyAllowApp(appToken: ApplicationToken) {
        let tokenString = appToken.debugDescription
        temporarilyAllowedApps.insert(tokenString)

        // Remove from shield temporarily
        var remainingApps = selectedApps.applicationTokens
        remainingApps.remove(appToken)
        managedSettings.shield.applications = remainingApps

        print("✅ Temporarily allowed app for \(allowDurationMinutes) minutes")

        // Re-enable shield after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(allowDurationMinutes * 60)) { [weak self] in
            self?.reEnableShield(for: appToken, tokenString: tokenString)
        }
    }

    /// Re-enable shield for a previously allowed app
    private func reEnableShield(for appToken: ApplicationToken, tokenString: String) {
        temporarilyAllowedApps.remove(tokenString)
        updateShield()
        print("🛡️ Shield re-enabled for app")
    }

    // MARK: - Usage Tracking

    /// Increment open count for an app
    func incrementOpenCount(for appToken: ApplicationToken) {
        let tokenString = appToken.debugDescription
        appOpenCounts[tokenString, default: 0] += 1
        userDefaults.set(appOpenCounts, forKey: openCountsKey)
    }

    /// Get open count for an app
    func getOpenCount(for appToken: ApplicationToken) -> Int {
        let tokenString = appToken.debugDescription
        return appOpenCounts[tokenString, default: 0]
    }

    /// Reset daily counters at midnight
    private func checkAndResetDailyCounters() {
        let calendar = Calendar.current
        let now = Date()

        if let lastReset = userDefaults.object(forKey: lastResetDateKey) as? Date {
            // Check if we've crossed midnight
            if !calendar.isDate(lastReset, inSameDayAs: now) {
                resetDailyCounters()
            }
        } else {
            // First launch
            userDefaults.set(now, forKey: lastResetDateKey)
        }

        // Schedule next reset check at midnight
        scheduleNextReset()
    }

    /// Reset all daily counters
    private func resetDailyCounters() {
        appOpenCounts.removeAll()
        userDefaults.set(appOpenCounts, forKey: openCountsKey)
        userDefaults.set(Date(), forKey: lastResetDateKey)
        print("🔄 Daily counters reset")
    }

    /// Schedule next reset check at midnight
    private func scheduleNextReset() {
        let calendar = Calendar.current
        let now = Date()

        // Calculate next midnight
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
           let nextMidnight = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrow) {
            let timeUntilMidnight = nextMidnight.timeIntervalSince(now)

            DispatchQueue.main.asyncAfter(deadline: .now() + timeUntilMidnight) { [weak self] in
                self?.resetDailyCounters()
                self?.scheduleNextReset()
            }
        }
    }

    /// Update allow duration setting
    func updateAllowDuration(_ minutes: Int) {
        allowDurationMinutes = minutes
        userDefaults.set(minutes, forKey: allowDurationKey)
    }
}
