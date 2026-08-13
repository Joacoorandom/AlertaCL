import Foundation

actor EarthquakeAPIService {
    /// Bounding box aproximado de Chile + margen oceánico / frontera.
    private let chileBounds = (
        minLat: -56.0,
        maxLat: -17.0,
        minLon: -76.0,
        maxLon: -66.0
    )

    func fetchChileEarthquakes(minMagnitude: Double, limit: Int = 100) async throws -> [Earthquake] {
        let start = Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now.addingTimeInterval(-604_800)
        var components = URLComponents(string: "https://earthquake.usgs.gov/fdsnws/event/1/query")!
        components.queryItems = [
            .init(name: "format", value: "geojson"),
            .init(name: "starttime", value: ISO8601DateFormatter().string(from: start)),
            .init(name: "minmagnitude", value: String(minMagnitude)),
            .init(name: "minlatitude", value: String(chileBounds.minLat)),
            .init(name: "maxlatitude", value: String(chileBounds.maxLat)),
            .init(name: "minlongitude", value: String(chileBounds.minLon)),
            .init(name: "maxlongitude", value: String(chileBounds.maxLon)),
            .init(name: "orderby", value: "time"),
            .init(name: "limit", value: String(limit))
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.setValue("AlertaCL/1.0 (Chile seismic alerts)", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 30

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(USGSFeatureCollection.self, from: data)
        return decoded.features.compactMap { Earthquake(feature: $0) }
    }
}
