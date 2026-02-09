//
//  ShieldActionProvider.swift
//  ShieldActionExtension
//
//  Handles user actions on the shield screen (button taps)
//

import ManagedSettings
import ManagedSettingsUI

/// Handles what happens when user interacts with shield buttons
class ShieldActionProvider: ShieldActionDelegate {

    /// Called when user taps the primary button ("Yes, open it")
    override func handle(action: ShieldAction, for application: Application, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            // User wants to open the app - temporarily allow it
            handleAllowApp(application: application, completionHandler: completionHandler)

        case .secondaryButtonPressed:
            // User wants to stay focused - keep shield active
            handleStayFocused(application: application, completionHandler: completionHandler)

        @unknown default:
            completionHandler(.close)
        }
    }

    /// Called when user taps primary/secondary button for a category shield
    override func handle(action: ShieldAction, for category: ApplicationCategory, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            // Allow the category temporarily
            completionHandler(.close)

        case .secondaryButtonPressed:
            // Keep category blocked
            completionHandler(.defer)

        @unknown default:
            completionHandler(.close)
        }
    }

    /// Called when user taps primary/secondary button for a web domain shield
    override func handle(action: ShieldAction, for webDomain: WebDomain, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            // Allow the website
            completionHandler(.close)

        case .secondaryButtonPressed:
            // Keep website blocked
            completionHandler(.defer)

        @unknown default:
            completionHandler(.close)
        }
    }

    // MARK: - Private Helpers

    /// Handle allowing the app temporarily
    private func handleAllowApp(application: Application, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Get shared UserDefaults via app group
        let appGroup = "group.com.productivity.appblocker"
        guard let sharedDefaults = UserDefaults(suiteName: appGroup) else {
            completionHandler(.close)
            return
        }

        // Store the allowed app token and timestamp
        let appToken = application.token.debugDescription
        let allowedAppsKey = "temporarilyAllowedApps"
        let allowDurationKey = "allowDurationMinutes"

        // Get current allowed apps
        var allowedApps = sharedDefaults.dictionary(forKey: allowedAppsKey) as? [String: Date] ?? [:]

        // Get allow duration (default 15 minutes)
        let allowDuration = sharedDefaults.integer(forKey: allowDurationKey)
        let duration = allowDuration > 0 ? allowDuration : 15

        // Calculate expiration time
        let expirationTime = Date().addingTimeInterval(TimeInterval(duration * 60))
        allowedApps[appToken] = expirationTime

        // Save to shared defaults
        sharedDefaults.set(allowedApps, forKey: allowedAppsKey)

        // Notify main app to update shield (via notification or polling)
        NotificationCenter.default.post(name: NSNotification.Name("UpdateShieldConfiguration"), object: nil)

        // Close the shield and allow the app to open
        completionHandler(.close)

        print("✅ App temporarily allowed until: \(expirationTime)")
    }

    /// Handle user choosing to stay focused
    private func handleStayFocused(application: Application, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Get shared UserDefaults via app group
        let appGroup = "group.com.productivity.appblocker"
        guard let sharedDefaults = UserDefaults(suiteName: appGroup) else {
            completionHandler(.defer)
            return
        }

        // Track the "stayed focused" decision for statistics
        let appToken = application.token.debugDescription
        let focusCountKey = "focusDecisionCounts"

        var focusCounts = sharedDefaults.dictionary(forKey: focusCountKey) as? [String: Int] ?? [:]
        focusCounts[appToken, default: 0] += 1
        sharedDefaults.set(focusCounts, forKey: focusCountKey)

        print("🎯 User chose to stay focused")

        // Keep the shield active (defer means don't dismiss)
        completionHandler(.defer)
    }
}
