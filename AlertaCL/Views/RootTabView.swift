import SwiftUI

struct RootTabView: View {
    @Environment(EarthquakeStore.self) private var store
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Inicio", systemImage: "waveform.path.ecg", value: 0) {
                HomeView()
            }

            Tab("Mapa", systemImage: "map.fill", value: 1) {
                MapView()
            }

            Tab("Alertas", systemImage: "bell.badge.fill", value: 2) {
                AlertsView()
            }

            Tab("Info", systemImage: "book.fill", value: 3) {
                InfoView()
            }
        }
        .tint(.red)
    }
}
