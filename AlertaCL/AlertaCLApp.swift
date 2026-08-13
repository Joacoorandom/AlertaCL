import SwiftUI
import UserNotifications

@main
struct AlertaCLApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var earthquakeStore = EarthquakeStore()
    @State private var notificationService = NotificationService.shared
    @State private var locationService = LocationService()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(earthquakeStore)
                .environment(notificationService)
                .environment(locationService)
                .task {
                    await notificationService.requestAuthorization()
                    locationService.requestWhenInUse()
                    await earthquakeStore.refresh()
                    earthquakeStore.startPolling()
                }
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = NotificationCenterDelegate.shared
        return true
    }
}

final class NotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate, @unchecked Sendable {
    static let shared = NotificationCenterDelegate()

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound, .badge]
    }
}
