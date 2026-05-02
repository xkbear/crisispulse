//
//  ConflictDetailView.swift
//  CrisisPulse
//
//  Detail sheet shown when the user taps a hotspot on the map.
//

import SwiftUI

struct ConflictDetailView: View {
    @EnvironmentObject var app: AppState
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss

    let conflict: Conflict

    private var isZH: Bool { app.language.hasPrefix("zh") }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    description
                    if let sources = conflict.sources, !sources.isEmpty {
                        sourcesSection(sources)
                    }
                }
                .padding(20)
            }
            .background(Color.cpBackgroundTop.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(
                        item: shareURL,
                        message: Text("\(conflict.name) — Crisis Pulse")
                    ) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(T("common.done", app.language)) { dismiss() }
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(conflict.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                if conflict.isNew {
                    NewBadge()
                        .padding(.leading, 4)
                }
            }
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.intensity(conflict.intensity))
                    .frame(width: 8, height: 8)
                Text(conflict.type)
                    .foregroundStyle(Color.cpTextPrimary)
                Text("·")
                    .foregroundStyle(Color.cpTextSecondary)
                Text("\(T("detail.intensityLabel", app.language)) \(String(format: "%.1f", conflict.intensity))/10")
                    .foregroundStyle(Color.intensity(conflict.intensity))
                    .fontWeight(.semibold)
            }
            .font(.system(size: 13))
        }
    }

    private var description: some View {
        let body = isZH ? (conflict.descZh ?? conflict.desc) : conflict.desc
        return Text(body)
            .font(.system(size: 15))
            .foregroundStyle(Color.cpTextPrimary)
            .lineSpacing(4)
            .padding(.vertical, 4)
    }

    private func sourcesSection(_ sources: [Conflict.Source]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(T("detail.sourcesTitle", app.language))
                .font(.system(size: 11, weight: .semibold))
                .tracking(1.2)
                .textCase(.uppercase)
                .foregroundStyle(Color.cpTextSecondary)
                .padding(.top, 8)

            ForEach(sources, id: \.url) { source in
                if let url = URL(string: source.url) {
                    Button {
                        openURL(url)
                    } label: {
                        HStack {
                            Text(source.title)
                                .foregroundStyle(Color(red: 0.58, green: 0.76, blue: 0.99))
                                .font(.system(size: 14, weight: .medium))
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Image(systemName: "arrow.up.forward.circle.fill")
                                .foregroundStyle(Color.cpTextSecondary)
                        }
                        .padding(12)
                        .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.06), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var shareURL: URL {
        let slug = conflict.name
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .components(separatedBy: CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-")).inverted)
            .joined()
        return URL(string: "https://crisispulse.org/conflicts/\(slug)")
            ?? URL(string: "https://crisispulse.org/")!
    }
}

#Preview {
    ConflictDetailView(conflict: Conflict(
        name: "Russia-Ukraine War",
        lat: 48.5, lon: 35.5,
        intensity: 9.0,
        type: "Full-Scale War",
        desc: "Largest conventional war in Europe, ongoing fifth year. Drone attacks on infrastructure intensify ahead of winter.",
        descZh: "欧洲最大规模常规战争，进入第五年。冬季前无人机袭击基础设施加剧。",
        sources: [
            .init(title: "CFR: Russia-Ukraine War", url: "https://www.cfr.org/global-conflict-tracker/conflict/conflict-ukraine"),
            .init(title: "ACLED Ukraine Data", url: "https://acleddata.com/ukraine-conflict-monitor/")
        ],
        firstSeen: nil,
        articleCount: 60,
        newsSpike: false,
        intensitySpike: true,
        spikeAt: ISO8601DateFormatter().string(from: Date())
    ))
    .environmentObject(AppState())
}
