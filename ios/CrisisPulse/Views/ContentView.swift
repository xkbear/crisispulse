//
//  ContentView.swift
//  CrisisPulse
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var app: AppState
    @State private var selection: Int = 0

    var body: some View {
        TabView(selection: $selection) {
            MapTabView()
                .tabItem {
                    Label(T("tab.map", app.language), systemImage: "globe.asia.australia.fill")
                }
                .tag(0)

            CalculatorView()
                .tabItem {
                    Label(T("tab.prep", app.language), systemImage: "list.clipboard.fill")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label(T("tab.settings", app.language), systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .tint(.cpAccent)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
