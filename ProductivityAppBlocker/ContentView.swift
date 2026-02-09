//
//  ContentView.swift
//  ProductivityAppBlocker
//
//  Main view with dashboard and navigation
//

import SwiftUI
import FamilyControls

struct ContentView: View {
    @EnvironmentObject var blockedAppsManager: BlockedAppsManager
    @State private var showingSettings = false

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("Productivity App Blocker")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Stay focused, block distractions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)

                // Statistics
                VStack(spacing: 20) {
                    StatCard(
                        title: "Blocked Apps",
                        value: "\(blockedAppsManager.selectedApps.applicationTokens.count)",
                        icon: "app.badge",
                        color: .blue
                    )

                    StatCard(
                        title: "Total Interruptions Today",
                        value: "\(totalInterruptionsToday())",
                        icon: "exclamationmark.shield",
                        color: .orange
                    )

                    StatCard(
                        title: "Times Stayed Focused",
                        value: "\(calculateFocusScore())",
                        icon: "checkmark.shield",
                        color: .green
                    )
                }
                .padding(.horizontal)

                Spacer()

                // Settings Button
                Button(action: {
                    showingSettings = true
                }) {
                    HStack {
                        Image(systemName: "gear")
                        Text("Manage Blocked Apps")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(blockedAppsManager)
            }
        }
    }

    /// Calculate total interruptions (times user was prompted)
    private func totalInterruptionsToday() -> Int {
        blockedAppsManager.appOpenCounts.values.reduce(0, +)
    }

    /// Calculate focus score (this is simplified - in production you'd track actual "No" selections)
    private func calculateFocusScore() -> Int {
        // For demo purposes, returning half of total interruptions
        // In production, you'd track actual "stayed focused" selections
        return totalInterruptionsToday() / 2
    }
}

/// Reusable stat card component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
                .frame(width: 50)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    ContentView()
        .environmentObject(BlockedAppsManager.shared)
}
