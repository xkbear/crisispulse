//
//  Conflict.swift
//  CrisisPulse
//

import Foundation
import CoreLocation

/// One tracked conflict / hotspot. Mirrors the JSON returned by /api/conflicts.
struct Conflict: Identifiable, Codable, Hashable {
    let name: String
    let lat: Double
    let lon: Double
    let intensity: Double
    let type: String
    let desc: String
    let descZh: String?
    let sources: [Source]?

    // NEW-badge fields (added in v0.2 backend)
    let firstSeen: String?
    let articleCount: Int?
    let newsSpike: Bool?
    let intensitySpike: Bool?
    let spikeAt: String?

    var id: String { name }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    var typeColor: IntensityTier {
        IntensityTier(intensity: intensity)
    }

    /// Returns true if this conflict should display a NEW badge:
    /// - first seen within last 7 days, OR
    /// - news spike or intensity spike flag is set
    var isNew: Bool {
        if newsSpike == true || intensitySpike == true { return true }
        guard let firstSeen, let date = ISO8601DateFormatter().date(from: firstSeen) else {
            return false
        }
        return Date().timeIntervalSince(date) < 7 * 86400
    }

    struct Source: Codable, Hashable {
        let title: String
        let url: String
    }
}

/// Severity tier — drives marker color across the map and detail UI.
enum IntensityTier {
    case extreme, high, medium, low

    init(intensity: Double) {
        switch intensity {
        case 8...:    self = .extreme
        case 6..<8:   self = .high
        case 4..<6:   self = .medium
        default:      self = .low
        }
    }
}

/// Top-level shape returned by /api/conflicts.
struct ConflictsResponse: Codable {
    let conflicts: [Conflict]
    let topNews: [NewsItem]
    let lastUpdated: String
}
