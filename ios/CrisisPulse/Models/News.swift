//
//  News.swift
//  CrisisPulse
//

import Foundation

/// A news headline associated with a tracked conflict.
struct NewsItem: Identifiable, Codable, Hashable {
    let conflict: String
    let headline: String
    let headlineZh: String?
    let articles: Int
    let url: String?

    var id: String { conflict + "|" + headline }
}

/// Visual badge tier for the hero news card.
enum NewsBadge: String {
    case escalating  // intensitySpike or newsSpike
    case breaking    // articles >= 40
    case highAttention  // default top story

    var labelEN: String {
        switch self {
        case .escalating:    return "ESCALATING"
        case .breaking:      return "BREAKING"
        case .highAttention: return "HIGH ATTENTION"
        }
    }

    var labelZH: String {
        switch self {
        case .escalating:    return "局势升级"
        case .breaking:      return "突发"
        case .highAttention: return "高度关注"
        }
    }

    static func of(top: NewsItem, conflict: Conflict?) -> NewsBadge {
        if conflict?.intensitySpike == true || conflict?.newsSpike == true {
            return .escalating
        }
        if top.articles >= 40 {
            return .breaking
        }
        return .highAttention
    }
}
