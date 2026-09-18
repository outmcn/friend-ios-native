import Foundation
import SwiftUI
import CoreLocation

@MainActor final class LocationRefreshService: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationRefreshService()
    private let manager = CLLocationManager(); private let geocoder = CLGeocoder(); private var updating=false
    private let cityKey="friend.current.city"; private let latKey="friend.current.lat"; private let lonKey="friend.current.lon"; private let timeKey="friend.current.location.time"
    private override init(){super.init();manager.delegate=self;manager.desiredAccuracy=kCLLocationAccuracyKilometer}
    var cachedCity:String? { UserDefaults.standard.string(forKey: cityKey) }
    func refreshIfNeeded(){ guard TokenStore.shared.token != nil else{return}; let age=Date().timeIntervalSince1970-UserDefaults.standard.double(forKey: timeKey); if age < 3600, cachedCity != nil { return }; refresh() }
    func refresh(){ guard TokenStore.shared.token != nil,CLLocationManager.locationServicesEnabled() else{return}; updating=true;manager.requestWhenInUseAuthorization();manager.startUpdatingLocation() }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager){if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways{manager.startUpdatingLocation()}}
    func locationManager(_ manager: CLLocationManager,didUpdateLocations locations:[CLLocation]){guard updating,let location=locations.last else{return};updating=false;manager.stopUpdatingLocation();let lat=String(location.coordinate.latitude),lon=String(location.coordinate.longitude);geocoder.reverseGeocodeLocation(location){[weak self] places,_ in Task{@MainActor in guard let self else{return};guard let city=places?.first?.locality ?? places?.first?.administrativeArea,!city.isEmpty else{return};let _:APIEnvelope<EmptyResponse>?=try? await APIClient.shared.request(path:"fruser/location",method:"PUT",body:LocationUpdateRequest(city:city,lat:lat,lon:lon));UserDefaults.standard.set(city,forKey:self.cityKey);UserDefaults.standard.set(lat,forKey:self.latKey);UserDefaults.standard.set(lon,forKey:self.lonKey);UserDefaults.standard.set(Date().timeIntervalSince1970,forKey:self.timeKey);NotificationCenter.default.post(name:.locationCityUpdated,object:city)}}}
    func locationManager(_ manager: CLLocationManager,didFailWithError error:Error){updating=false;manager.stopUpdatingLocation()}
}
extension Notification.Name { static let locationCityUpdated=Notification.Name("friend.location.city.updated") }
struct LocationUpdateRequest:Encodable{let city:String;let lat:String;let lon:String}
