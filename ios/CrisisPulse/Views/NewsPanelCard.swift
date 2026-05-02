//
//  NewsPanelCard.swift
//  CrisisPulse
//
//  Inline bottom card that shows today's top story. Tappable header toggles
//  between collapsed (hero only) and expanded (hero + secondary list).
//  Replaces the previous .sheet-based NewsPanelView so the TabView's tab
//  bar remains visible and tappable.
//

import SwiftUI

struct NewsPanelCard: View {
    @EnvironmentObject var app: AppState
    @Binding var expanded: Bool
    @Environment(\.openURL) private var openURL

    private var isZH: Bool { app.language.hasPrefix("zh") }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            content
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial.opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.cpBackgroundTop.opacity(0.7))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08))
        )
        .shadow(color: .black.opacity(0.4), radius: 16, y: 4)
    }

    private var header: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                expanded.toggle()
            }
        } label: {
            HStack(spacing: 8) {
                PulseDot(color: .cpDanger, size: 6)
                Text(T("news.title", app.language))
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(1.2)
                    .foregroundStyle(Color.cpTextPrimary.opacity(0.75))
                    .textCase(.uppercase)
                Spacer()
                Image(systemName: expanded ? "chevron.down" : "chevron.up")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.cpTextSecondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var content: some View {
        if app.topNews.isEmpty {
            Text(T("news.empty", app.language))
                .font(.system(size: 12))
                .foregroundStyle(Color.cpTextSecondary)
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
        } else if let top = app.topNews.first {
            VStack(alignment: .leading, spacing: 0) {
                heroBlock(for: top)

                if expanded && app.topNews.count > 1 {
                    Divider().background(Color.white.opacity(0.08))
                    Text(T("news.alsoTracking", app.language))
                        .font(.system(size: 9, weight: .semibold))
                        .tracking(1.2)
                        .textCase(.uppercase)
                        .foregroundStyle(Color.cpTextSecondary)
                        .padding(.horizontal, 14)
                        .padding(.top, 12)
                        .padding(.bottom, 4)
                    ForEach(Array(app.topNews.dropFirst().prefix(4))) { item in
                        secondaryRow(for: item)
                            .padding(.horizontal, 14)
                    }
                    Spacer().frame(height: 12)
                }
            }
        }
    }

    private func heroBlock(for top: NewsItem) -> some View {
        let conflictData = app.conflicts.first { $0.name == top.conflict }
        let badge = NewsBadge.of(top: top, conflict: conflictData)
        let badgeColor = self.badgeColor(badge)

        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(isZH ? badge.labelZH : badge.labelEN)
                    .font(.system(size: 9, weight: .heavy))
                    .tracking(1)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(badgeColor, in: RoundedRectangle(cornerRadius: 4))
                Spacer()
                Text(T("news.topStory", app.language))
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(1.4)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.cpTextSecondary)
            }
            Text(top.conflict)
                .font(.system(size: 11, weight: .bold))
                .tracking(0.6)
                .textCase(.uppercase)
                .foregroundStyle(Color.cpAmber)
                .padding(.top, 2)
            Group {
                if let urlString = top.url, let url = URL(string: urlString) {
                    Button {
                        openURL(url)
                    } label: {
                        Text(isZH ? (top.headlineZh ?? top.headline) : top.headline)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                            .underline(true, pattern: .solid, color: .white.opacity(0.2))
                    }
                    .buttonStyle(.plain)
                } else {
                    Text(isZH ? (top.headlineZh ?? top.headline) : top.headline)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            Text("\(top.articles) \(T("news.articles", app.language))")
                .font(.system(size: 10))
                .foregroundStyle(Color.cpTextSecondary)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            LinearGradient(colors: [
                Color.cpDanger.opacity(0.13),
                Color.cpDanger.opacity(0.02),
                Color.white.opacity(0.02)
            ], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 12)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12).stroke(Color.cpDanger.opacity(0.25))
        )
        .padding(.horizontal, 14)
        .padding(.bottom, 12)
    }

    private func secondaryRow(for item: NewsItem) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(item.conflict)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.cpAmber)
            Group {
                if let urlString = item.url, let url = URL(string: urlString) {
                    Link(isZH ? (item.headlineZh ?? item.headline) : item.headline, destination: url)
                        .font(.system(size: 12))
                        .tint(Color(red: 0.58, green: 0.76, blue: 0.99))
                } else {
                    Text(isZH ? (item.headlineZh ?? item.headline) : item.headline)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.cpTextPrimary)
                }
            }
            Text("\(item.articles) \(T("news.articles", app.language))")
                .font(.system(size: 10))
                .foregroundStyle(Color.cpTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 7)
    }

    private func badgeColor(_ badge: NewsBadge) -> Color {
        switch badge {
        case .escalating:    return Color(red: 0.94, green: 0.27, blue: 0.27)
        case .breaking:      return Color(red: 0.86, green: 0.15, blue: 0.15)
        case .highAttention: return Color(red: 0.96, green: 0.62, blue: 0.04)
        }
    }
}

#Preview {
    @Previewable @State var expanded = false
    return ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            Spacer()
            NewsPanelCard(expanded: $expanded)
                .padding(.horizontal, 12)
                .padding(.bottom, 80)
        }
    }
    .environmentObject({
        let s = AppState()
        s.topNews = [
            NewsItem(conflict: "US-Israel-Iran Conflict", headline: "Iran strikes US base after Israel ground operation expands into Lebanon corridor", headlineZh: "伊朗在以色列地面行动扩大至黎巴嫩走廊后袭击美军基地", articles: 87, url: "https://example.com"),
            NewsItem(conflict: "Russia-Ukraine War", headline: "Drones hit Moscow oil refinery, supply lines stretched", headlineZh: nil, articles: 52, url: nil)
        ]
        return s
    }())
}
