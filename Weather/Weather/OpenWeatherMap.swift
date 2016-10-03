//
//  OpenWeatherMap.swift
//  Weather
//
//  Created by Kelly Hutchison on 10/27/15.
//  Copyright © 2015 Kelly Hutchison. All rights reserved.
//

import Foundation
import CoreLocation

class OpenWeatherMap: NSObject {
    
    // API Key
    fileprivate let APIKey:String
    
    // Base level URL to request data from
    fileprivate let baseURL = "http://api.openweathermap.org/data/2.5"
    
    // local variables
    var language:String
    var temperatureScale:String
    
    init(language:String, temperatureScale:String, APIKey:String) {
        self.language = language
        self.APIKey = APIKey
        self.temperatureScale = temperatureScale
    }
    
    // API Call Functions
    func weatherForCityName(_ cityName: String, callback: @escaping (Dictionary<String, AnyObject>?) -> ()) {
        call("/weather?q=\(cityName.removeSpaces())", callback: callback)
    }
    
    func weatherForCoordinate(_ coordinate: CLLocationCoordinate2D, callback: @escaping (Dictionary<String, AnyObject>?) -> ()) {
        let coordinateString = "lat=\(coordinate.latitude)&lon=\(coordinate.longitude)"
        call("/weather?\(coordinateString)", callback: callback)
    }
    
    func weatherForCityID(_ cityId: Int, callback: @escaping (Dictionary<String, AnyObject>?) -> ()) {
        call("/weather?id=\(cityId)?appid=\(Model.apiKeyValue)", callback: callback)
    }
    
    func findCityForName(_ cityName: String, callback: @escaping (Dictionary<String, AnyObject>?) -> ()) {
        call("/find?q=\(cityName.removeSpaces())", callback: callback)
    }
    
    func findCityForCoordinate(_ coordinate: CLLocationCoordinate2D, callback: @escaping (Dictionary<String, AnyObject>?) -> ()) {
        call("/find?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)", callback: callback)
    }
    
    // Main Call Function - opens the URL Session and gets the data back
    fileprivate func call(_ operation: String, callback: @escaping (Dictionary<String, AnyObject>?) -> ()) {
        let urlPath = baseURL + operation + "&APPID=\(APIKey)&lang=\(language)&units=\(temperatureScale)"
        let url = URL(string: urlPath)
        
        assert(url != nil, "URL is invalid")
        
        let queue = OperationQueue.current
        
        let session = URLSession.shared
        session.dataTask(with: url!, completionHandler: {
            (data, response, error) -> Void in
            
            var error: NSError? = error as NSError?
            var dictionary: Dictionary<String, AnyObject>?
            
            // Check for errors 
            if let data = data {
                do {
                    dictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? Dictionary<String, AnyObject>
                } catch let e as NSError {
                    error = e
                }
            }
            queue?.addOperation {
                let result = dictionary
                if error != nil {
                    NSLog((error?.description)!)
                }
                callback(result)
            }
            
        }).resume()
    }
}
