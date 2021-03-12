//
//  ViewController.swift
//  weather-app
//
//  Created by 18426447 on 10.03.2021.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    let locationManager = LocationManager()
    let requestHelper = RequestHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        guard let exposedLocation = self.locationManager.exposedLocation else {
            print("*** Error in \(#function): exposed location is nil")
            return
        }
        
        self.locationManager.getPlace(for: exposedLocation) { placemark in
            guard let placemark = placemark else {return}
            if let town = placemark.locality {
                self.searching(cityName: town)
            }
        }
        
        
        
        
    }
    func searching(cityName: String) {
        requestHelper.getTemperatureForCity(city: cityName) { result in
            DispatchQueue.main.async {
                if result.0 == "ERROR" {
                    self.temperatureLabel.isHidden = true
                    self.cityLabel.text = "Error has occured"
                } else {
                    self.cityLabel.text = result.0
                    self.temperatureLabel.text = "\(result.1)"
                    self.temperatureLabel.isHidden = false
                }
            }
        }
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        guard let cityName = searchBar.text else {return}
        
        searching(cityName: cityName)
    }
}
