//
//  Visitor.swift
//  CrisisPulse
//

import Foundation

/// Visitor count payload returned by /api/visitor.
struct VisitorResponse: Codable {
    let total: Int
    let countries: [CountryCount]
    let detectedCountry: String?

    struct CountryCount: Codable, Identifiable, Hashable {
        let name: String
        let code: String
        let count: Int

        var id: String { code }

        /// Render the country flag emoji from the ISO 3166-1 alpha-2 code.
        var flag: String {
            String(code.uppercased().unicodeScalars.compactMap {
                UnicodeScalar(127397 + Int($0.value))
            }.map(Character.init))
        }
    }
}

/// Calculator state mirrors the web preparedness form.
struct CalculatorInput {
    var country: String = ""
    var housing: Housing = .apartment
    var adults: Int = 2
    var children: Int = 0
    var hasInfants: Bool = false
    var hasPets: Bool = false
    var hasMedicalNeeds: Bool = false
    var months: Int = 3

    enum Housing: String, CaseIterable, Identifiable {
        case apartment, house, rural, mobile
        var id: String { rawValue }

        var labelEN: String {
            switch self {
            case .apartment: return "Apartment"
            case .house:     return "House"
            case .rural:     return "Rural / Farm"
            case .mobile:    return "RV / Mobile"
            }
        }

        var labelZH: String {
            switch self {
            case .apartment: return "公寓"
            case .house:     return "独栋"
            case .rural:     return "乡村 / 农场"
            case .mobile:    return "房车 / 移动"
            }
        }
    }
}

/// Calculator output — a category of supplies with itemized rows.
struct SupplyCategory: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let titleZh: String
    let icon: String          // SF Symbol
    let tier: Tier
    let items: [SupplyItem]

    enum Tier: String {
        case red, amber, blue
    }
}

struct SupplyItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let nameZh: String
    let quantity: String
    let rationale: String
    let rationaleZh: String
}
