import SwiftUI
import MapKit

struct MapView: View {
    @Environment(EarthquakeStore.self) private var store
    @Environment(LocationService.self) private var location
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -33.45, longitude: -70.66),
            span: MKCoordinateSpan(latitudeDelta: 12, longitudeDelta: 8)
        )
    )
    @State private var selected: Earthquake?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Map(position: $position, selection: $selected) {
                    ForEach(store.earthquakes) { quake in
                        Annotation(quake.magnitudeLabel, coordinate: quake.coordinate, anchor: .center) {
                            MagnitudePin(quake: quake)
                        }
                        .tag(quake)
                    }

                    if let coord = location.coordinate {
                        Annotation("Tú", coordinate: coord) {
                            Image(systemName: "location.fill")
                                .foregroundStyle(.cyan)
                                .padding(8)
                                .glassEffect(.regular.tint(.cyan.opacity(0.3)), in: .circle)
                        }
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .ignoresSafeArea(edges: .top)

                if let selected {
                    EarthquakeDetailCard(quake: selected) {
                        self.selected = nil
                    }
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    mapChrome
                }
            }
            .animation(.spring(duration: 0.35), value: selected?.id)
            .navigationTitle("Mapa")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var mapChrome: some View {
        GlassEffectContainer {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(store.earthquakes.count) eventos")
                        .font(.headline)
                    Text("Últimos 7 días · Chile")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    withAnimation {
                        position = .region(
                            MKCoordinateRegion(
                                center: CLLocationCoordinate2D(latitude: -33.45, longitude: -70.66),
                                span: MKCoordinateSpan(latitudeDelta: 12, longitudeDelta: 8)
                            )
                        )
                    }
                } label: {
                    Image(systemName: "scope")
                        .padding(10)
                }
                .glassEffect(.regular.interactive(), in: .circle)
            }
            .padding(16)
            .glassEffect(.regular, in: .rect(cornerRadius: 20))
            .padding()
        }
    }
}

struct MagnitudePin: View {
    let quake: Earthquake

    var body: some View {
        Text(String(format: "%.1f", quake.magnitude))
            .font(.caption2.weight(.bold).monospacedDigit())
            .foregroundStyle(.white)
            .padding(8)
            .background(quake.severity.color.gradient, in: Circle())
            .shadow(color: quake.severity.color.opacity(0.5), radius: 6)
    }
}

struct EarthquakeDetailCard: View {
    let quake: Earthquake
    var onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(quake.magnitudeLabel)
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(quake.severity.color)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .padding(8)
                }
                .glassEffect(.regular.interactive(), in: .circle)
            }
            Text(quake.place)
                .font(.headline)
            HStack(spacing: 16) {
                Label(quake.depthLabel, systemImage: "arrow.down.to.line")
                Label(quake.relativeTime, systemImage: "clock")
                if quake.tsunami {
                    Label("Tsunami flag", systemImage: "water.waves")
                        .foregroundStyle(.red)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            SeverityBadge(severity: quake.severity)
        }
        .padding(20)
        .glassEffect(.regular.tint(quake.severity.color.opacity(0.2)).interactive(), in: .rect(cornerRadius: 24))
    }
}
