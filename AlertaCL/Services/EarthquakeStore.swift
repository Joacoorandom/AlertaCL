import Foundation
import Observation

@Observable
@MainActor
final class EarthquakeStore {
    private(set) var earthquakes: [Earthquake] = []
    private(set) var isLoading = false
    private(set) var lastUpdated: Date?
    private(set) var errorMessage: String?
    private(set) var latestCritical: Earthquake?

    var minimumMagnitude: Double = 3.5
    var alertThreshold: Double = 5.0

    private let service = EarthquakeAPIService()
    private var pollTask: Task<Void, Never>?
    private var knownIDs = Set<String>()

    var recentCritical: [Earthquake] {
        earthquakes.filter { $0.magnitude >= alertThreshold }
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let fetched = try await service.fetchChileEarthquakes(minMagnitude: minimumMagnitude)
            let previous = knownIDs
            earthquakes = fetched
            lastUpdated = .now

            let newOnes = fetched.filter { !previous.contains($0.id) && !previous.isEmpty }
            knownIDs = Set(fetched.map(\.id))

            if let strongest = newOnes.max(by: { $0.magnitude < $1.magnitude }),
               strongest.magnitude >= alertThreshold {
                latestCritical = strongest
                await NotificationService.shared.sendEarthquakeAlert(strongest)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func startPolling(intervalSeconds: UInt64 = 60) {
        pollTask?.cancel()
        pollTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(intervalSeconds))
                await refresh()
            }
        }
    }

    func stopPolling() {
        pollTask?.cancel()
        pollTask = nil
    }

    func injectDemo(_ quake: Earthquake) async {
        earthquakes.insert(quake, at: 0)
        latestCritical = quake
        await NotificationService.shared.sendEarthquakeAlert(quake)
    }
}
