//
//  ProductivityAppBlockerApp.swift
//  ProductivityAppBlocker
//
//  Main app entry point with FamilyControls authorization
//

import SwiftUI
import FamilyControls

@main
struct ProductivityAppBlockerApp: App {
    // Shared instance of blocked apps manager
    @StateObject private var blockedAppsManager = BlockedAppsManager.shared

    // Authorization center for Family Controls
    let center = AuthorizationCenter.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(blockedAppsManager)
                .onAppear {
                    // Request Family Controls authorization on first launch
                    Task {
                        do {
                            try await center.requestAuthorization(for: .individual)
                            print("✅ Family Controls authorization granted")
                        } catch {
                            print("❌ Failed to authorize Family Controls: \(error.localizedDescription)")
                        }
                    }
                }
        }
    }
}
