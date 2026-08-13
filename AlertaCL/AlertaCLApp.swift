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

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound, .badge]
    }
}
