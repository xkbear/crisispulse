//
//  LocationManager.swift
//  CrisisPulse
//

import Foundation
import CoreLocation

@MainActor
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocation?
    @Published var country: String?
    @Published var authorization: CLAuthorizationStatus = .notDetermined

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        authorization = manager.authorizationStatus
    }

    /// Ask the OS for "When In Use" permission. The map page calls this on appear.
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    /// One-shot location fetch.
    func requestLocation() {
        manager.requestLocation()
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorization = manager.authorizationStatus
            if manager.authorizationStatus == .authorizedWhenInUse ||
               manager.authorizationStatus == .authorizedAlways {
                manager.requestLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        Task { @MainActor in
            self.location = loc
            // Reverse geocode to fill in country
            do {
                let placemarks = try await geocoder.reverseGeocodeLocation(loc)
                self.country = placemarks.first?.country
            } catch {
                // Silent — country stays nil, downstream UI uses fallback
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Swallow CLError.locationUnknown which fires often during initial fix
        if (error as? CLError)?.code == .locationUnknown { return }
        print("Location error: \(error.localizedDescription)")
    }
}
