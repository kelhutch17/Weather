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
    private let baseURL = "api.openweathermap.org/data/2.5/"
    
    // Response Queue
    private var queue: NSOperationQueue
    
    // local variables
    var language:String
    var temperatureScale:String
    
    init(language:String, temperatureScale:String, APIKey:String) {
        self.language = language
        self.APIKey = APIKey
        self.temperatureScale = temperatureScale
        self.queue = NSOperationQueue()
    }
    
    
//    func weatherForCityName(cityName: String, callback: (NSURLResponse?, AnyObject?) -> ()) {
//        call("/weather?q=\(cityName)", callback: callback)
//    }
//    
//    func weatherForCoordinate(coordinate: CLLocationCoordinate2D, callback: (NSURLResponse?, AnyObject?) -> ()) {
//        let coordinateString = "lat=\(coordinate.latitude)&lon=\(coordinate.longitude)"
//        call("/weather?\(coordinateString)", callback: callback)
//    }
//    
//    func findCityForName(cityName: String, callback: (NSURLResponse?, AnyObject?) -> ()) {
//        call("/find?q=\(cityName)", callback: callback)
//    }
    
    func findCityForCoordinate(coordinate: CLLocationCoordinate2D) -> Dictionary<String, AnyObject?>? {
        let callResponse = call("/find?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)")
        
        if callResponse.0 != nil {
            NSLog("Failed to parse JSON for coordinate")
            return nil
        } else {
            return callResponse.1
        }
    }
    
    func call(operation:String) -> (NSError?, Dictionary<String, AnyObject?>) {
        let url = baseURL + operation + "&APPID=\(APIKey)&lang=\(language)&units=\(temperatureScale)"
        let data = NSData(contentsOfURL: NSURL(string: url)!)!
        var responseError:NSError?
        var jsonResponse:Dictionary<String, AnyObject?>?
        //let request = NSURLRequest(URL: NSURL(string: url)!)
        
        
        do {
            if let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? Dictionary<String, AnyObject?> {
                jsonResponse = json
            }
        } catch let error as NSError {
            responseError = error
        }
        
        return(responseError, jsonResponse!)
    }
//
//        // change to NSURLSession
//        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
//            var error: NSError? = error
//            var dictionary: NSDictionary?
//            
//            if let data = data {
//                do {
//                    dictionary = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? NSDictionary
//                } catch let e as NSError {
//                    error = e
//                }
//            }
//            
//            currentQueue?.addOperationWithBlock {
//                // check for error
//                if error != nil {
//                    callback(response, error)
//                } else {
//                    callback(response, dictionary)
//                }
//            }
//        }
    //}
}
