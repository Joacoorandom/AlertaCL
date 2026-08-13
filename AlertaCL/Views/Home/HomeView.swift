import SwiftUI

struct HomeView: View {
    @Environment(EarthquakeStore.self) private var store
    @Environment(NotificationService.self) private var notifications
    @Namespace private var glassNamespace

    var body: some View {
        NavigationStack {
            ZStack {
                AtmosphericBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header
                        statusStrip
                        latestCard
                        recentList
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .refreshable { await store.refresh() }
            }
            .navigationTitle("AlertaCL")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await store.refresh() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Chile")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
            Text("Monitoreo sísmico en tiempo casi real. Fuentes USGS · bounding box Chile.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }

    private var statusStrip: some View {
        GlassEffectContainer(spacing: 12) {
            HStack(spacing: 12) {
                StatusChip(
                    title: store.isLoading ? "Actualizando…" : "En línea",
                    symbol: store.isLoading ? "arrow.triangle.2.circlepath" : "antenna.radiowaves.left.and.right",
                    tint: store.isLoading ? .orange : .green
                )
                .glassEffectID("online", in: glassNamespace)

                StatusChip(
                    title: notifications.isAuthorized ? "Avisos ON" : "Avisos OFF",
                    symbol: notifications.isAuthorized ? "bell.fill" : "bell.slash",
                    tint: notifications.isAuthorized ? .cyan : .secondary
                )
                .glassEffectID("notifs", in: glassNamespace)
            }
        }
    }

    @ViewBuilder
    private var latestCard: some View {
        if let latest = store.earthquakes.first {
            VStack(alignment: .leading, spacing: 14) {
                Label("Último sismo", systemImage: "bolt.horizontal.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text(latest.magnitudeLabel)
                        .font(.system(size: 48, weight: .heavy, design: .rounded))
                        .foregroundStyle(latest.severity.color)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(latest.place)
                            .font(.headline)
                            .lineLimit(3)
                        Text("\(latest.relativeTime) · \(latest.depthLabel)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                SeverityBadge(severity: latest.severity)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassEffect(.regular.tint(latest.severity.color.opacity(0.25)).interactive(), in: .rect(cornerRadius: 24))
        } else if store.isLoading {
            ProgressView("Cargando sismos…")
                .frame(maxWidth: .infinity)
                .padding(40)
                .glassEffect(.regular, in: .rect(cornerRadius: 24))
        } else {
            ContentUnavailableView(
                "Sin eventos recientes",
                systemImage: "waveform.path",
                description: Text("No hay sismos ≥ \(String(format: "%.1f", store.minimumMagnitude)) en la última semana.")
            )
            .padding()
            .glassEffect(.regular, in: .rect(cornerRadius: 24))
        }
    }

    private var recentList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recientes")
                .font(.title3.weight(.semibold))

            ForEach(store.earthquakes.prefix(12)) { quake in
                EarthquakeRow(quake: quake)
            }
        }
    }
}

struct StatusChip: View {
    let title: String
    let symbol: String
    let tint: Color

    var body: some View {
        Label(title, systemImage: symbol)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .foregroundStyle(tint)
            .glassEffect(.regular.tint(tint.opacity(0.2)).interactive(), in: .capsule)
    }
}

struct SeverityBadge: View {
    let severity: AlertSeverity

    var body: some View {
        Label(severity.title, systemImage: severity.symbol)
            .font(.caption.weight(.bold))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .foregroundStyle(severity.color)
            .glassEffect(.regular.tint(severity.color.opacity(0.35)), in: .capsule)
    }
}

struct EarthquakeRow: View {
    let quake: Earthquake

    var body: some View {
        HStack(spacing: 14) {
            Text(String(format: "%.1f", quake.magnitude))
                .font(.title3.weight(.bold).monospacedDigit())
                .foregroundStyle(quake.severity.color)
                .frame(width: 48)

            VStack(alignment: .leading, spacing: 2) {
                Text(quake.place)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(2)
                Text("\(quake.relativeTime) · \(quake.depthLabel) · \(quake.source)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }
}

struct AtmosphericBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.12, blue: 0.22),
                    Color(red: 0.12, green: 0.18, blue: 0.28),
                    Color(red: 0.22, green: 0.10, blue: 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(.red.opacity(0.18))
                .frame(width: 320, height: 320)
                .blur(radius: 80)
                .offset(x: 120, y: -180)

            Circle()
                .fill(.cyan.opacity(0.12))
                .frame(width: 280, height: 280)
                .blur(radius: 70)
                .offset(x: -140, y: 260)
        }
    }
}
