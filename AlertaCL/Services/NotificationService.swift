import Foundation
import UserNotifications
import Observation
import AudioToolbox

@Observable
@MainActor
final class NotificationService {
    static let shared = NotificationService()

    private(set) var isAuthorized = false
    private(set) var criticalAlertsAllowed = false
    private(set) var statusText = "Sin permiso"

    func requestAuthorization() async {
        let center = UNUserNotificationCenter.current()
        do {
            // timeSensitive + critical requieren capabilities/aprobación según plataforma.
            // En sideload, critical suele fallar silenciosamente; timeSensitive puede degradarse.
            let granted = try await center.requestAuthorization(options: [
                .alert, .sound, .badge
            ])
            isAuthorized = granted
            let settings = await center.notificationSettings()
            criticalAlertsAllowed = settings.criticalAlertSetting == .enabled
            statusText = describe(settings)
        } catch {
            isAuthorized = false
            statusText = "Error: \(error.localizedDescription)"
        }
    }

    func refreshSettings() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
        criticalAlertsAllowed = settings.criticalAlertSetting == .enabled
        statusText = describe(settings)
    }

    func sendEarthquakeAlert(_ quake: Earthquake) async {
        let content = UNMutableNotificationContent()
        content.title = quake.severity == .critical
            ? "⚠️ ALERTA SÍSMICA CRÍTICA"
            : "Sismo detectado — \(quake.magnitudeLabel)"
        content.subtitle = quake.place
        content.body = "Profundidad \(quake.depthLabel) · Fuente \(quake.source) · \(quake.relativeTime)"
        content.sound = sound(for: quake.severity)
        content.badge = 1
        content.userInfo = [
            "quakeId": quake.id,
            "magnitude": quake.magnitude,
            "lat": quake.latitude,
            "lon": quake.longitude
        ]
        content.interruptionLevel = interruptionLevel(for: quake.severity)
        content.relevanceScore = min(1.0, quake.magnitude / 9.0)

        if quake.severity == .critical || quake.severity == .warning {
            content.threadIdentifier = "alerta-sismica-critica"
        }

        let request = UNNotificationRequest(
            identifier: "quake-\(quake.id)-\(Int(Date().timeIntervalSince1970))",
            content: content,
            trigger: nil
        )

        try? await UNUserNotificationCenter.current().add(request)

        if quake.severity == .critical {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }

    func sendDemoAlert(level: AlertSeverity) async {
        let mag: Double = switch level {
        case .info: 4.2
        case .watch: 5.1
        case .warning: 6.2
        case .critical: 7.4
        }
        let quake = Earthquake.demo(
            magnitude: mag,
            place: "Demo — Región Metropolitana, Chile"
        )
        await sendEarthquakeAlert(quake)
    }

    private func sound(for severity: AlertSeverity) -> UNNotificationSound {
        // Critical sound only works with Apple critical-alerts entitlement.
        if severity == .critical, criticalAlertsAllowed {
            return .defaultCritical
        }
        return .default
    }

    private func interruptionLevel(for severity: AlertSeverity) -> UNNotificationInterruptionLevel {
        switch severity {
        case .info: .passive
        case .watch: .active
        case .warning: .timeSensitive
        case .critical:
            criticalAlertsAllowed ? .critical : .timeSensitive
        }
    }

    private func describe(_ settings: UNNotificationSettings) -> String {
        let auth: String = switch settings.authorizationStatus {
        case .notDetermined: "Sin decidir"
        case .denied: "Denegado"
        case .authorized: "Autorizado"
        case .provisional: "Provisional"
        case .ephemeral: "Efímero"
        @unknown default: "Desconocido"
        }
        let critical: String = switch settings.criticalAlertSetting {
        case .enabled: "Critical ON"
        case .disabled: "Critical OFF"
        case .notSupported: "Critical N/A (sideload / sin entitlement)"
        @unknown default: "Critical ?"
        }
        return "\(auth) · \(critical)"
    }
}
