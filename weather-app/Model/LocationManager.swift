//
//  LocationManager.swift
//  location-test-app
//
//  Created by 18426447 on 11.03.2021.
//

import Foundation
import CoreLocation

class LocationManager : NSObject {
    private let locationManager = CLLocationManager()
    
    public var exposedLocation: CLLocation? {
        return self.locationManager.location
    }
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestLocation()
    }
    
    func getPlace(for location: CLLocation,
                  completion: @escaping (CLPlacemark?) -> Void) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { placemarks, error in
            guard error == nil else {
                print("*** Error in \(#function): \(error!.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let placemark = placemarks?[0] else {
                print("*** Error in \(#function): placemark is nill")
                completion(nil)
                return
            }
            
            completion(placemark)
        }
    }
    
    func getCurrentCity() -> String? {
        var output : String?
        getPlace(for: exposedLocation!) { placemark in
            guard let placemark = placemark else {return}
            if let town = placemark.locality {
                output = "\(town)"
            }
        }
        return output
    }
    
}


extension LocationManager : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("*** Error getting location")
    }
}
