//
//  NotificationService.swift
//  CrisisPulse
//
//  Local notification scheduling. Server-side daily brief still goes via
//  Resend email; this surfaces "your subscribed conflict escalated" alerts
//  locally based on the latest /api/conflicts payload comparison.
//

import Foundation
import UserNotifications

@MainActor
final class NotificationService: ObservableObject {
    @Published var permissionGranted: Bool = false

    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            self.permissionGranted = granted
        } catch {
            self.permissionGranted = false
        }
    }

    /// Compare a fresh conflict snapshot against the previously stored one and
    /// schedule local notifications for any conflict whose intensity rose ≥ 1.0.
    /// Call this from AppState.refreshConflicts after a successful fetch.
    func notifyEscalations(previous: [Conflict], current: [Conflict]) async {
        guard permissionGranted else { return }

        let prevMap = Dictionary(uniqueKeysWithValues: previous.map { ($0.name, $0.intensity) })
        let escalated = current.filter { conflict in
            guard let prev = prevMap[conflict.name] else { return false }
            return conflict.intensity - prev >= 1.0
        }

        guard !escalated.isEmpty else { return }

        let content = UNMutableNotificationContent()
        content.title = "⚠️ Crisis Pulse Alert"
        if escalated.count == 1 {
            content.subtitle = escalated[0].name
            content.body = escalated[0].desc
        } else {
            content.subtitle = "\(escalated.count) conflicts escalated"
            content.body = escalated.prefix(3).map(\.name).joined(separator: ", ")
        }
        content.sound = .default
        content.badge = NSNumber(value: escalated.count)

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let req = UNNotificationRequest(
            identifier: "escalation-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        try? await UNUserNotificationCenter.current().add(req)
    }
}
