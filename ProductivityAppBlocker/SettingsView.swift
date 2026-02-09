//
//  SettingsView.swift
//  ProductivityAppBlocker
//
//  Settings screen for selecting apps to block and configuring behavior
//

import SwiftUI
import FamilyControls

struct SettingsView: View {
    @EnvironmentObject var blockedAppsManager: BlockedAppsManager
    @Environment(\.dismiss) var dismiss

    @State private var showingAppPicker = false
    @State private var allowDuration: Double

    init() {
        // Initialize with current value from manager
        _allowDuration = State(initialValue: Double(BlockedAppsManager.shared.allowDurationMinutes))
    }

    var body: some View {
        NavigationView {
            Form {
                // App Selection Section
                Section {
                    Button(action: {
                        showingAppPicker = true
                    }) {
                        HStack {
                            Image(systemName: "app.badge.checkmark")
                                .foregroundColor(.blue)

                            VStack(alignment: .leading, spacing: 5) {
                                Text("Select Apps to Block")
                                    .foregroundColor(.primary)

                                Text("\(blockedAppsManager.selectedApps.applicationTokens.count) apps selected")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Blocked Apps")
                } footer: {
                    Text("Choose which apps you want to block. When you try to open them, you'll see a prompt asking if you really want to proceed.")
                }

                // Allow Duration Section
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Allow Duration")
                            Spacer()
                            Text("\(Int(allowDuration)) min")
                                .foregroundColor(.secondary)
                        }

                        Slider(value: $allowDuration, in: 5...120, step: 5)
                            .onChange(of: allowDuration) { newValue in
                                blockedAppsManager.updateAllowDuration(Int(newValue))
                            }

                        HStack {
                            Text("5 min")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("120 min")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Temporary Access")
                } footer: {
                    Text("When you choose \"Yes, open it\", the app will be unblocked for this duration before being blocked again.")
                }

                // Usage Statistics Section
                Section {
                    if blockedAppsManager.appOpenCounts.isEmpty {
                        Text("No data yet")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(Array(blockedAppsManager.appOpenCounts.keys.sorted()), id: \.self) { appKey in
                            HStack {
                                Image(systemName: "app")
                                    .foregroundColor(.blue)

                                Text("App")
                                    .lineLimit(1)

                                Spacer()

                                Text("\(blockedAppsManager.appOpenCounts[appKey] ?? 0) times")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Today's Interruptions")
                } footer: {
                    Text("These counters reset at midnight. Shows how many times you attempted to open each blocked app today.")
                }

                // Info Section
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        InfoRow(icon: "info.circle", text: "The shield appears briefly after the app starts launching")
                        InfoRow(icon: "bell.badge", text: "You'll be asked if you really want to open the app")
                        InfoRow(icon: "arrow.clockwise", text: "Statistics reset every day at midnight")
                        InfoRow(icon: "hand.raised", text: "You can always choose to stay focused")
                    }
                } header: {
                    Text("How It Works")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .familyActivityPicker(
                isPresented: $showingAppPicker,
                selection: $blockedAppsManager.selectedApps
            )
        }
    }
}

/// Info row component for the "How It Works" section
struct InfoRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(BlockedAppsManager.shared)
}
