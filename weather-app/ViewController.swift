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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        let urlString = "http://api.weatherstack.com/current?access_key=77033fdf6722714ebda1ca8b472128e1&query=\(searchBar.text!.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "%20"))"
        
        let url = URL.init(string: urlString)
        
        var locationName : String?
        var celsiumTemperature : Double?
        var errorHasOccured : Bool = false
         
        let task = URLSession.shared.dataTask(with: url!) {[weak self] (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    as! [String : AnyObject]
                
                if let _ = json["error"] {
                    errorHasOccured = true
                }
                
                if let location = json["location"]  {
                    locationName = location["name"] as? String
                }
                
                if let current = json["current"] {
                    celsiumTemperature = current["temperature"] as? Double
                }
                DispatchQueue.main.async {
                    if errorHasOccured {
                        self?.temperatureLabel.isHidden = true
                        self?.cityLabel.text = "Error has occured"
                    } else {
                        self?.cityLabel.text = locationName
                        self?.temperatureLabel.text = "\(celsiumTemperature!)"
                        self?.temperatureLabel.isHidden = false
                    }
                }
                
            } catch let jsonError {
                print(jsonError)
            }
            
        }
        
        task.resume()
    }
}
