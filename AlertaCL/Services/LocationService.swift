import Foundation
import CoreLocation
import Observation

@Observable
@MainActor
final class LocationService: NSObject {
    private let manager = CLLocationManager()
    private(set) var authorization: CLAuthorizationStatus
    private(set) var coordinate: CLLocationCoordinate2D?
    private(set) var cityHint: String = "Chile"

    override init() {
        authorization = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func requestWhenInUse() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
}

extension LocationService: @preconcurrency CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorization = status
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                self.manager.startUpdatingLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coord = locations.last?.coordinate
        Task { @MainActor in
            self.coordinate = coord
            self.manager.stopUpdatingLocation()
        }
    }
}
