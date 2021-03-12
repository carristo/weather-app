//
//  ViewController.swift
//  weather-app
//
//  Created by 18426447 on 10.03.2021.
//

import UIKit
import CoreLocation
import MapKit

class MainScreenVC: UIViewController {

    private lazy var cityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Avenir", size: 35)
        view.addSubview(label)
        return label
    }()
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Avenir", size: 35)
        view.addSubview(label)
        return label
    }()
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        view.addSubview(searchBar)
        return searchBar
    }()
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        return imageView
    }()
    let locationManager = LocationManager()
    let requestHelper = RequestHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        constraints()

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
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        singleTapGestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(singleTapGestureRecognizer)
    }
    
    func searching(cityName: String) {
        requestHelper.getTemperatureForCity(city: cityName) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self.cityLabel.text = model.cityName
                    self.temperatureLabel.text = "\(model.tempretuare)"
                    self.temperatureLabel.isHidden = false
                    self.requestHelper.getImage(path: model.imagePath) { (data) in
                        DispatchQueue.main.async {
                            let image = UIImage(data: data)
                            self.imageView.image = image
                        }
                    }
                case .failure(let error):
                    self.temperatureLabel.isHidden = true
                    switch error {
                    case .network(let text):
                        self.cityLabel.text = text
                    }
                }
            }
        }
    }
    
    func constraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            searchBar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            
            cityLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -10),
            cityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            temperatureLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 10),
            temperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            imageView.widthAnchor.constraint(equalToConstant: 64),
            imageView.heightAnchor.constraint(equalToConstant: 64),
            imageView.bottomAnchor.constraint(equalTo: cityLabel.topAnchor, constant: -10),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc
    func dismissKeyboard() {
        searchBar.endEditing(true)
    }
}

extension MainScreenVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        guard let cityName = searchBar.text else {return}
        
        searching(cityName: cityName)
    }
}
