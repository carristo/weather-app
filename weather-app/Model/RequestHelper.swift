//
//  RequestHelper.swift
//  weather-app
//
//  Created by 18426447 on 11.03.2021.
//

import Foundation

class RequestHelper {
    
    private let weatherApiUrlBase = "http://api.weatherstack.com/current?access_key=77033fdf6722714ebda1ca8b472128e1&query="
    
    func getTemperatureForCity(city: String, completion: @escaping (Result<WeatherModel, NetworkError>) -> Void) {
        let urlString = weatherApiUrlBase + city.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "%20")
        let url = URL.init(string: urlString)

        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            guard let safeData = data else { return }
            do {
                let model = try JSONDecoder().decode(WeatherModel.self, from: safeData)
                completion(.success(model))
            } catch let jsonError {
                completion(.failure(.network("huid")))
                print(jsonError)
            }
            
        }
        
        task.resume()
    }
    
    func getImage(path: String, completion: @escaping (Data) -> Void) {
        guard let url = URL(string: path) else { return }
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let safeData = data else { return }
            completion(safeData)
        }
        
        task.resume()
    }
    
}
enum NetworkError: Error {
    case network(String)
}
struct WeatherModel: Decodable {
    let cityName: String
    let tempretuare: Double
    let imagePath: String
    
    enum CodingKeys: CodingKey {
        case location
        case current
    }
    
    enum LocationKeys: CodingKey {
        case name
    }
    
    enum CurrentKeys: String, CodingKey {
        case weatherIcons = "weather_icons"
        case temperature
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let locationContainer = try container.nestedContainer(keyedBy: LocationKeys.self, forKey: .location)
        let currentContainer = try container.nestedContainer(keyedBy: CurrentKeys.self, forKey: .current)
        cityName = try locationContainer.decode(String.self, forKey: .name)
        
        imagePath = try currentContainer.decode([String].self, forKey: .weatherIcons).first ?? ""
        tempretuare = try currentContainer.decode(Double.self, forKey: .temperature)
    }
}
