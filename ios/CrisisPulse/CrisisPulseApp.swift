//
//  CrisisPulseApp.swift
//  CrisisPulse
//
//  Free global conflict monitor + emergency supply calculator.
//  https://crisispulse.org
//

import SwiftUI

@main
struct CrisisPulseApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
                .task {
                    await appState.bootstrap()
                }
        }
    }
}

/// Global app-level state shared via @EnvironmentObject.
/// Holds the currently fetched conflicts, top news, and user preferences.
@MainActor
final class AppState: ObservableObject {
    @Published var conflicts: [Conflict] = []
    @Published var topNews: [NewsItem] = []
    @Published var lastUpdated: Date?
    @Published var loadError: String?
    @Published var isLoading: Bool = false

    /// Persisted across launches — see SettingsView for the UI toggle.
    @AppStorage("language") var language: String = Locale.current.language.languageCode?.identifier == "zh" ? "zh" : "en"
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = false

    let api = APIClient()

    func bootstrap() async {
        await refreshConflicts()
    }

    func refreshConflicts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let response = try await api.fetchConflicts()
            self.conflicts = response.conflicts
            self.topNews = response.topNews
            self.lastUpdated = ISO8601DateFormatter().date(from: response.lastUpdated)
            self.loadError = nil
        } catch {
            self.loadError = error.localizedDescription
        }
    }
}
