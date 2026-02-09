//
//  ShieldConfigurationProvider.swift
//  ShieldConfigurationExtension
//
//  Custom shield UI shown when user attempts to open a blocked app
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

/// Custom shield configuration provider
/// This extension provides the custom UI shown when a blocked app is launched
class ShieldConfigurationProvider: ShieldConfigurationDataSource {

    /// Configuration for application shield
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        // Get usage count from shared UserDefaults (using app group)
        let appGroup = "group.com.productivity.appblocker"
        let sharedDefaults = UserDefaults(suiteName: appGroup)
        let openCountsKey = "appOpenCounts"

        // Get count for this app
        let counts = sharedDefaults?.dictionary(forKey: openCountsKey) as? [String: Int] ?? [:]
        let appToken = application.token.debugDescription
        let openCount = counts[appToken, default: 0]

        // Increment count (user attempted to open the app)
        var updatedCounts = counts
        updatedCounts[appToken, default: 0] += 1
        sharedDefaults?.set(updatedCounts, forKey: openCountsKey)

        // Create shield configuration with custom UI
        return ShieldConfiguration(
            backgroundBlurStyle: .systemThickMaterial,
            backgroundColor: UIColor.systemBackground,
            icon: UIImage(systemName: "hand.raised.fill"),
            title: ShieldConfiguration.Label(
                text: "App Blocked",
                color: UIColor.label
            ),
            subtitle: ShieldConfiguration.Label(
                text: "You've tried to open this app \(openCount) time\(openCount == 1 ? "" : "s") today",
                color: UIColor.secondaryLabel
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Yes, open it",
                color: UIColor.systemBlue
            ),
            primaryButtonBackgroundColor: UIColor.systemBlue.withAlphaComponent(0.15),
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "No, stay focused",
                color: UIColor.systemGreen
            ),
            secondaryButtonBackgroundColor: UIColor.systemGreen.withAlphaComponent(0.15)
        )
    }

    /// Configuration for application category shield
    override func configuration(shielding applicationCategory: ApplicationCategory) -> ShieldConfiguration {
        // Similar configuration for category-based shields
        return ShieldConfiguration(
            backgroundBlurStyle: .systemThickMaterial,
            backgroundColor: UIColor.systemBackground,
            icon: UIImage(systemName: "hand.raised.fill"),
            title: ShieldConfiguration.Label(
                text: "Category Blocked",
                color: UIColor.label
            ),
            subtitle: ShieldConfiguration.Label(
                text: "This app category is currently blocked",
                color: UIColor.secondaryLabel
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Yes, open it",
                color: UIColor.systemBlue
            ),
            primaryButtonBackgroundColor: UIColor.systemBlue.withAlphaComponent(0.15),
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "No, stay focused",
                color: UIColor.systemGreen
            ),
            secondaryButtonBackgroundColor: UIColor.systemGreen.withAlphaComponent(0.15)
        )
    }

    /// Configuration for website shield
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        // Shield configuration for blocked websites
        return ShieldConfiguration(
            backgroundBlurStyle: .systemThickMaterial,
            backgroundColor: UIColor.systemBackground,
            icon: UIImage(systemName: "globe.badge.chevron.backward"),
            title: ShieldConfiguration.Label(
                text: "Website Blocked",
                color: UIColor.label
            ),
            subtitle: ShieldConfiguration.Label(
                text: "This website is currently blocked",
                color: UIColor.secondaryLabel
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Continue anyway",
                color: UIColor.systemBlue
            ),
            primaryButtonBackgroundColor: UIColor.systemBlue.withAlphaComponent(0.15),
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Go back",
                color: UIColor.systemGreen
            ),
            secondaryButtonBackgroundColor: UIColor.systemGreen.withAlphaComponent(0.15)
        )
    }
}
