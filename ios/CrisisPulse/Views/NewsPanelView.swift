//
//  NewsPanelView.swift
//  CrisisPulse
//
//  Bottom sheet showing today's #1 top story as a hero card,
//  plus 4 secondary "also tracking" items. Mirrors the web's news-panel.
//

import SwiftUI

struct NewsPanelView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 6) {
                    PulseDot(color: .cpDanger, size: 6)
                    Text(T("news.title", app.language))
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(1.2)
                        .foregroundStyle(Color.cpTextPrimary.opacity(0.7))
                        .textCase(.uppercase)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 6)

            ScrollView {
                if app.topNews.isEmpty {
                    Text(T("news.empty", app.language))
                        .font(.system(size: 12))
                        .foregroundStyle(Color.cpTextSecondary)
                        .padding()
                        .frame(maxWidth: .infinity)
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        if let top = app.topNews.first {
                            heroCard(for: top)
                        }
                        if app.topNews.count > 1 {
                            Text(T("news.alsoTracking", app.language))
                                .font(.system(size: 9, weight: .semibold))
                                .tracking(1.2)
                                .textCase(.uppercase)
                                .foregroundStyle(Color.cpTextSecondary)
                                .padding(.horizontal, 16)
                                .padding(.top, 14)
                                .padding(.bottom, 4)
                            VStack(spacing: 0) {
                                ForEach(Array(app.topNews.dropFirst().prefix(4).enumerated()), id: \.element.id) { _, item in
                                    secondaryRow(for: item)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .presentationBackground(Color.cpBackgroundTop)
    }

    private func heroCard(for top: NewsItem) -> some View {
        let conflictData = app.conflicts.first { $0.name == top.conflict }
        let badge = NewsBadge.of(top: top, conflict: conflictData)
        let isZH = app.language.hasPrefix("zh")

        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(isZH ? badge.labelZH : badge.labelEN)
                    .font(.system(size: 9, weight: .heavy))
                    .tracking(1)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(badgeColor(badge), in: RoundedRectangle(cornerRadius: 4))

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
                .padding(.top, 4)

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
        .padding(14)
        .background(
            LinearGradient(colors: [
                Color.cpDanger.opacity(0.12),
                Color.cpDanger.opacity(0.02),
                Color.white.opacity(0.02)
            ], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 12)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12).stroke(Color.cpDanger.opacity(0.25), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }

    private func secondaryRow(for item: NewsItem) -> some View {
        let isZH = app.language.hasPrefix("zh")
        return VStack(alignment: .leading, spacing: 3) {
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
        .padding(.vertical, 8)
        .overlay(alignment: .top) {
            Divider().background(Color.white.opacity(0.08))
        }
    }

    private func badgeColor(_ badge: NewsBadge) -> Color {
        switch badge {
        case .escalating:    return Color(red: 0.94, green: 0.27, blue: 0.27)
        case .breaking:      return Color(red: 0.86, green: 0.15, blue: 0.15)
        case .highAttention: return Color(red: 0.96, green: 0.62, blue: 0.04)
        }
    }
}

struct PulseDot: View {
    let color: Color
    let size: CGFloat
    @State private var pulse = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .opacity(pulse ? 0.3 : 1)
            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulse)
            .onAppear { pulse = true }
    }
}

#Preview {
    NewsPanelView()
        .environmentObject({
            let s = AppState()
            s.topNews = [
                NewsItem(conflict: "US-Israel-Iran Conflict", headline: "Iran strikes US base after Israel ground operation expands", headlineZh: "伊朗在以色列地面行动扩大后袭击美军基地", articles: 87, url: "https://example.com"),
                NewsItem(conflict: "Russia-Ukraine War", headline: "Drones hit Moscow oil refinery, supply lines stretched", headlineZh: nil, articles: 52, url: nil)
            ]
            return s
        }())
}
