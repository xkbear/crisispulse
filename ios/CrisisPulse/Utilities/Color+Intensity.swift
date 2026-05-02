//
//  Color+Intensity.swift
//  CrisisPulse
//

import SwiftUI

extension Color {
    /// Map a 0–10 intensity score to a diverging palette identical to the web.
    static func intensity(_ score: Double) -> Color {
        switch score {
        case 8...:    return Color(red: 0.94, green: 0.27, blue: 0.27)   // #ef4444
        case 6..<8:   return Color(red: 0.92, green: 0.49, blue: 0.13)   // #ea580c
        case 4..<6:   return Color(red: 0.96, green: 0.62, blue: 0.04)   // #f59e0b
        case 2..<4:   return Color(red: 0.98, green: 0.75, blue: 0.14)   // #fbbf24
        default:      return Color(red: 0.13, green: 0.77, blue: 0.37)   // #22c55e
        }
    }

    /// Background gradient stops used on the launch / map page.
    static let cpBackgroundTop    = Color(red: 0.04, green: 0.04, blue: 0.06)  // #0a0a0f
    static let cpBackgroundMiddle = Color(red: 0.05, green: 0.07, blue: 0.09)  // #0d1117
    static let cpAccent           = Color(red: 0.23, green: 0.51, blue: 0.96)  // #3b82f6
    static let cpAmber            = Color(red: 0.98, green: 0.75, blue: 0.14)  // #fbbf24
    static let cpDanger           = Color(red: 0.94, green: 0.27, blue: 0.27)  // #ef4444
    static let cpTextPrimary      = Color(red: 0.90, green: 0.90, blue: 0.90)  // #e6e6e6
    static let cpTextSecondary    = Color(red: 0.53, green: 0.53, blue: 0.53)  // #888
}
