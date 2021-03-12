//
//  RequestHelper.swift
//  weather-app
//
//  Created by 18426447 on 11.03.2021.
//

import Foundation

class RequestHelper {
    
    private let weatherApiUrlBase = "http://api.weatherstack.com/current?access_key=77033fdf6722714ebda1ca8b472128e1&query="
    
    func getTemperatureForCity(city: String, completion: @escaping ((String, Double)) -> Void) {
        let urlString = weatherApiUrlBase + city.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "%20")
        let url = URL.init(string: urlString)
        

        var result: (city : String, temperature : Double) = (" ", 0)

        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            do {

                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    as! [String : AnyObject]
                
                
                if let location = json["location"]  {
                    result.city = location["name"] as! String
                }
                
                if let current = json["current"] {
                    result.temperature = current["temperature"] as! Double
                }
                completion(result)
            } catch let jsonError {
                print(jsonError)
            }
            
        }
        
        task.resume()
    }
    
}
