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
    private let APIKey:String
    
    // Base level URL to request data from
    private let baseURL = "http://api.openweathermap.org/data/2.5"
    
    // local variables
    var language:String
    var temperatureScale:String
    
    init(language:String, temperatureScale:String, APIKey:String) {
        self.language = language
        self.APIKey = APIKey
        self.temperatureScale = temperatureScale
    }
    
    
    func weatherForCityName(cityName: String, callback: (Dictionary<String, AnyObject>?) -> ()) {
        call("/weather?q=\(cityName.removeSpaces())", callback: callback)
    }
    
    func weatherForCoordinate(coordinate: CLLocationCoordinate2D, callback: (Dictionary<String, AnyObject>?) -> ()) {
        let coordinateString = "lat=\(coordinate.latitude)&lon=\(coordinate.longitude)"
        call("/weather?\(coordinateString)", callback: callback)
    }
    
    func weatherForCityID(cityId: Int, callback: (Dictionary<String, AnyObject>?) -> ()) {
        call("/weather?id=\(cityId)", callback: callback)
    }
    
    func findCityForName(cityName: String, callback: (Dictionary<String, AnyObject>?) -> ()) {
        call("/find?q=\(cityName.removeSpaces())", callback: callback)
    }
    
    func findCityForCoordinate(coordinate: CLLocationCoordinate2D, callback: (Dictionary<String, AnyObject>?) -> ()) {
        call("/find?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)", callback: callback)
    }
    
    private func call(operation: String, callback: (Dictionary<String, AnyObject>?) -> ()) {
        let urlPath = baseURL + operation + "&APPID=\(APIKey)&lang=\(language)&units=\(temperatureScale)"
        let url = NSURL(string: urlPath)
        
        assert(url != nil, "URL is invalid")
        
        let queue = NSOperationQueue.currentQueue()
        
        let session = NSURLSession.sharedSession()
        session.dataTaskWithURL(url!, completionHandler: {
            (data, response, error) -> Void in
            
            var error: NSError? = error
            var dictionary: Dictionary<String, AnyObject>?
            
            if let data = data {
                do {
                    dictionary = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? Dictionary<String, AnyObject>
                } catch let e as NSError {
                    error = e
                }
            }
            queue?.addOperationWithBlock {
                let result = dictionary
                if error != nil {
                    NSLog((error?.description)!)
                }
                callback(result)
            }
            
        }).resume()
    }
}
