import SwiftUI

struct AlertsView: View {
    @Environment(EarthquakeStore.self) private var store
    @Environment(NotificationService.self) private var notifications
    @State private var demoRunning = false

    var body: some View {
        @Bindable var store = store
        NavigationStack {
            ZStack {
                AtmosphericBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        permissionCard
                        thresholdCard(store: store)
                        demoSection
                        criticalHistory
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Alertas")
        }
    }

    private var permissionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Notificaciones", systemImage: "bell.badge.fill")
                .font(.headline)

            Text(notifications.statusText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if !notifications.criticalAlertsAllowed {
                Text("Critical Alerts reales requieren entitlement de Apple. En sideload (Sideloadly) se usan avisos time-sensitive / normales con sonido y vibración.")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            Button {
                Task {
                    await notifications.requestAuthorization()
                    await notifications.refreshSettings()
                }
            } label: {
                Text(notifications.isAuthorized ? "Actualizar permisos" : "Activar notificaciones")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .glassEffect(.regular.tint(.red.opacity(0.35)).interactive(), in: .capsule)
        }
        .padding(20)
        .glassEffect(.regular, in: .rect(cornerRadius: 22))
    }

    private func thresholdCard(store: EarthquakeStore) -> some View {
        @Bindable var store = store
        return VStack(alignment: .leading, spacing: 12) {
            Text("Umbral de alerta push")
                .font(.headline)
            Text("Avisar desde magnitud \(String(format: "%.1f", store.alertThreshold))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Slider(value: $store.alertThreshold, in: 4.0...7.5, step: 0.1)
                .tint(.red)
        }
        .padding(20)
        .glassEffect(.regular, in: .rect(cornerRadius: 22))
    }

    private var demoSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Demos")
                .font(.title3.weight(.semibold))
            Text("Simula alertas locales para probar sonido, banner y severidad. No son eventos reales.")
                .font(.caption)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(AlertSeverity.allCases, id: \.self) { level in
                    Button {
                        Task {
                            demoRunning = true
                            let mag: Double = switch level {
                            case .info: 4.2
                            case .watch: 5.1
                            case .warning: 6.2
                            case .critical: 7.4
                            }
                            let quake = Earthquake.demo(
                                magnitude: mag,
                                place: "DEMO \(level.title) — Santiago, Chile"
                            )
                            await store.injectDemo(quake)
                            demoRunning = false
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: level.symbol)
                            Text(level.title)
                                .font(.caption.weight(.semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .foregroundStyle(level.color)
                    }
                    .glassEffect(.regular.tint(level.color.opacity(0.3)).interactive(), in: .rect(cornerRadius: 16))
                    .disabled(demoRunning)
                }
            }
        }
    }

    private var criticalHistory: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sobre umbral")
                .font(.title3.weight(.semibold))

            if store.recentCritical.isEmpty {
                Text("Ningún sismo reciente supera el umbral.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .glassEffect(.regular, in: .rect(cornerRadius: 16))
            } else {
                ForEach(store.recentCritical) { quake in
                    EarthquakeRow(quake: quake)
                }
            }
        }
    }
}
