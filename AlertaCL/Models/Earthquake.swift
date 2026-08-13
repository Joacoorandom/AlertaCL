import Foundation
import CoreLocation
import SwiftUI

struct Earthquake: Identifiable, Hashable, Sendable {
    let id: String
    let magnitude: Double
    let place: String
    let time: Date
    let latitude: Double
    let longitude: Double
    let depthKm: Double
    let url: URL?
    let tsunami: Bool
    let source: String

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var severity: AlertSeverity {
        AlertSeverity.from(magnitude: magnitude)
    }

    var magnitudeLabel: String {
        String(format: "M %.1f", magnitude)
    }

    var depthLabel: String {
        String(format: "%.0f km", depthKm)
    }

    var relativeTime: String {
        RelativeDateTimeFormatter.alerta.localizedString(for: time, relativeTo: .now)
    }
}

enum AlertSeverity: String, CaseIterable, Sendable {
    case info
    case watch
    case warning
    case critical

    static func from(magnitude: Double) -> AlertSeverity {
        switch magnitude {
        case ..<4.5: .info
        case ..<5.5: .watch
        case ..<6.5: .warning
        default: .critical
        }
    }

    var title: String {
        switch self {
        case .info: "Informativo"
        case .watch: "Vigilancia"
        case .warning: "Alerta"
        case .critical: "Crítico"
        }
    }

    var color: Color {
        switch self {
        case .info: .cyan
        case .watch: .yellow
        case .warning: .orange
        case .critical: .red
        }
    }

    var symbol: String {
        switch self {
        case .info: "info.circle.fill"
        case .watch: "eye.trianglebadge.exclamationmark.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .critical: "sos.circle.fill"
        }
    }
}

struct USGSFeatureCollection: Decodable, Sendable {
    let features: [USGSFeature]
}

struct USGSFeature: Decodable, Sendable {
    let id: String
    let properties: USGSProperties
    let geometry: USGSGeometry
}

struct USGSProperties: Decodable, Sendable {
    let mag: Double?
    let place: String?
    let time: Double?
    let url: String?
    let tsunami: Int?
    let title: String?
}

struct USGSGeometry: Decodable, Sendable {
    let coordinates: [Double]
}

extension Earthquake {
    init?(feature: USGSFeature, source: String = "USGS") {
        guard
            let mag = feature.properties.mag,
            let timeMs = feature.properties.time,
            feature.geometry.coordinates.count >= 2
        else { return nil }

        let lon = feature.geometry.coordinates[0]
        let lat = feature.geometry.coordinates[1]
        let depth = feature.geometry.coordinates.count > 2 ? feature.geometry.coordinates[2] : 0

        self.id = feature.id
        self.magnitude = mag
        self.place = feature.properties.place ?? feature.properties.title ?? "Ubicación desconocida"
        self.time = Date(timeIntervalSince1970: timeMs / 1000)
        self.latitude = lat
        self.longitude = lon
        self.depthKm = depth
        self.url = feature.properties.url.flatMap(URL.init(string:))
        self.tsunami = (feature.properties.tsunami ?? 0) == 1
        self.source = source
    }

    static func demo(magnitude: Double, place: String) -> Earthquake {
        Earthquake(
            id: "demo-\(UUID().uuidString)",
            magnitude: magnitude,
            place: place,
            time: .now,
            latitude: -33.45,
            longitude: -70.66,
            depthKm: 35,
            url: nil,
            tsunami: magnitude >= 7.0,
            source: "DEMO"
        )
    }
}

private extension RelativeDateTimeFormatter {
    static let alerta: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.locale = Locale(identifier: "es_CL")
        f.unitsStyle = .short
        return f
    }()
}
