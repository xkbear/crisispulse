//
//  MapTabView.swift
//  CrisisPulse
//
//  Main world map with conflict hotspots, NEW badges, and a bottom sheet
//  showing today's top news story.
//

import SwiftUI
import MapKit

struct MapTabView: View {
    @EnvironmentObject var app: AppState
    @StateObject private var locationManager = LocationManager()

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 20, longitude: 10),
            span: MKCoordinateSpan(latitudeDelta: 120, longitudeDelta: 220)
        )
    )

    @State private var selectedConflict: Conflict?
    @State private var newsExpanded: Bool = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                mapBody

                topBar
                    .padding(.horizontal)
                    .padding(.top, 8)

                // Inline news card pinned to the bottom — does NOT cover the
                // tab bar (we used to use .sheet here which hid the tab bar).
                VStack {
                    Spacer()
                    NewsPanelCard(expanded: $newsExpanded)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 6)
                }
                .ignoresSafeArea(.keyboard)
            }
            .navigationBarHidden(true)
            .background(Color.cpBackgroundTop.ignoresSafeArea())
            .onAppear {
                // Skip the location permission prompt on the iOS Simulator —
                // on real devices, request normally.
                #if !targetEnvironment(simulator)
                locationManager.requestPermission()
                #endif
            }
            .sheet(item: $selectedConflict) { conflict in
                ConflictDetailView(conflict: conflict)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .refreshable {
                await app.refreshConflicts()
            }
        }
    }

    private var mapBody: some View {
        Map(position: $cameraPosition) {
            // User location pin
            if let coord = locationManager.location?.coordinate {
                Annotation("", coordinate: coord, anchor: .center) {
                    UserLocationDot()
                }
                .annotationTitles(.hidden)
            }

            // Conflict hotspots
            ForEach(app.conflicts) { conflict in
                Annotation(conflict.name, coordinate: conflict.coordinate, anchor: .center) {
                    HotspotMarker(conflict: conflict)
                        .onTapGesture {
                            selectedConflict = conflict
                        }
                }
                .annotationTitles(.hidden)
            }
        }
        .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
        .colorScheme(.dark)
    }

    private var topBar: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(T("map.title", app.language))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.cpTextPrimary)
                Text(T("map.subtitle", app.language))
                    .font(.system(size: 11))
                    .foregroundStyle(Color.cpTextSecondary)
                LiveTag(text: T("map.live", app.language))
                    .padding(.top, 4)
            }
            Spacer()
            Button {
                Task { await app.refreshConflicts() }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .foregroundStyle(Color.cpTextPrimary)
                    .rotationEffect(.degrees(app.isLoading ? 360 : 0))
                    .animation(app.isLoading
                               ? .linear(duration: 1).repeatForever(autoreverses: false)
                               : .default,
                               value: app.isLoading)
                    .padding(8)
                    .background(Color.white.opacity(0.06))
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}

/// Pulsing tag like the web `<live-tag>`.
struct LiveTag: View {
    let text: String
    @State private var pulse = false

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(Color.cpDanger)
            .padding(.horizontal, 10)
            .padding(.vertical, 2)
            .background(Color.cpDanger.opacity(0.12), in: Capsule())
            .opacity(pulse ? 0.5 : 1)
            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulse)
            .onAppear { pulse = true }
    }
}

/// Per-conflict marker rendered on the map. Pulsing ring + filled dot,
/// optional "NEW" badge floats above-right.
struct HotspotMarker: View {
    let conflict: Conflict

    @State private var ringScale: CGFloat = 1.0

    private var color: Color { Color.intensity(conflict.intensity) }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.6), lineWidth: 1.5)
                    .frame(width: 12, height: 12)
                    .scaleEffect(ringScale)
                    .opacity(2 - ringScale)
                Circle()
                    .fill(color)
                    .frame(width: max(4, conflict.intensity * 1.0), height: max(4, conflict.intensity * 1.0))
            }
            .frame(width: 28, height: 28) // hit area + ring growth space

            if conflict.isNew {
                NewBadge()
                    .offset(x: 14, y: -10)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.6).repeatForever(autoreverses: false)) {
                ringScale = 2.4
            }
        }
        .accessibilityLabel(conflict.name)
        .accessibilityValue("Intensity \(String(format: "%.1f", conflict.intensity)) of 10")
    }
}

struct NewBadge: View {
    @State private var pulse = false

    var body: some View {
        Text("NEW")
            .font(.system(size: 8, weight: .heavy))
            .tracking(0.5)
            .foregroundStyle(.white)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(Color.cpDanger, in: Capsule())
            .opacity(pulse ? 0.5 : 1)
            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulse)
            .onAppear { pulse = true }
    }
}

struct UserLocationDot: View {
    var body: some View {
        Circle()
            .fill(Color.green)
            .frame(width: 12, height: 12)
            .overlay(Circle().stroke(.white, lineWidth: 2))
            .shadow(color: .green.opacity(0.6), radius: 6)
    }
}

#Preview {
    MapTabView()
        .environmentObject(AppState())
}
