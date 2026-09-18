import Foundation
import SwiftUI
import CoreLocation

@MainActor final class LocationRefreshService: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationRefreshService()
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var updating = false
    private override init() { super.init(); manager.delegate = self; manager.desiredAccuracy = kCLLocationAccuracyKilometer }
    func refresh() { guard TokenStore.shared.token != nil, CLLocationManager.locationServicesEnabled() else { return }; updating=true; manager.requestWhenInUseAuthorization(); manager.startUpdatingLocation() }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) { if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways { manager.startUpdatingLocation() } }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { guard updating, let location=locations.last else{return}; updating=false; manager.stopUpdatingLocation(); let lat=String(location.coordinate.latitude), lon=String(location.coordinate.longitude); geocoder.reverseGeocodeLocation(location){[weak self] places,_ in Task { @MainActor in guard let self else{return}; let city=places?.first?.locality ?? places?.first?.administrativeArea; guard let city,!city.isEmpty else{return}; let _:APIEnvelope<EmptyResponse>?=try? await APIClient.shared.request(path:"fruser/location",method:"PUT",body:LocationUpdateRequest(city:city,lat:lat,lon:lon)); UserDefaults.standard.set(city,forKey:"friend.current.city") } } }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) { updating=false; manager.stopUpdatingLocation() }
}
struct LocationUpdateRequest: Encodable { let city: String; let lat: String; let lon: String }
