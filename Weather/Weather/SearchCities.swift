//
//  SearchCities.swift
//  Weather
//
//  Created by Kelly Hutchison on 10/29/15.
//  Copyright © 2015 Kelly Hutchison. All rights reserved.
//

import Foundation
import CoreLocation

protocol SearchCitiesProtocol {
    func matchingCitiesFound(matchingCities:[City])
}

class SearchCities {
    
    var matchingCities = [City]()
    let model = Model.sharedInstance
    let weatherAPI:OpenWeatherMap?
    var delegate:SearchCitiesProtocol?
    
    init() {
        weatherAPI = OpenWeatherMap(language: "en", temperatureScale: Model.TemperatureScale.Fahrenheit.rawValue, APIKey: model.apiKeyValue())
    }
    
    // Filter all cities based on input string
    func findCitiesWithName(name:String) {
        // Make API Call with city substring
        if let weatherAPI = weatherAPI {
            weatherAPI.findCityForName(name, callback: { result in
                if let dictionary = result {
                    // check return value
                    if (dictionary["cod"] as! String) != "200" {
                        return
                    }
                    let returnedCities = dictionary["list"] as! Array<Dictionary<String, AnyObject>>
                    
                    if let delegate = self.delegate {
                        delegate.matchingCitiesFound(self.findMatchingCities(returnedCities))
                    } else {
                        NSLog("Delegate not set")
                    }
                }
                else {
                    NSLog("Could not successfully reach API")
                }
            })
        }
        
    }
    
    private func findMatchingCities(allCities:Array<Dictionary<String, AnyObject>>) -> [City] {
        var matchingCities = [City]()
        for city:Dictionary<String, AnyObject> in allCities {
            matchingCities.append(newCityFromCityDictionary(city))
        }
        return matchingCities
    }
    
    // Creates a new City object from a JSON Dictionary 
    func newCityFromCityDictionary(city:Dictionary<String, AnyObject>) -> City {
        // EXAMPLE JSON DICTIONARY from API call
        // {"id":4525353,"name":"Springfield","coord":{"lon":-83.808823,"lat":39.924229},"main":{"temp":47.12,"temp_min":47.12,"temp_max":47.12,"pressure":990.13,"sea_level":1024.35,"grnd_level":990.13,"humidity":79},"dt":1446149192,"wind":{"speed":15.79,"deg":270.003},"sys":{"country":"US"},"clouds":{"all":0},"weather":[{"id":800,"main":"Clear","description":"Sky is Clear","icon":"01d"}]}
        
        // Outmost part of Dictionary
        let id = (city["id"] as! Int).description
        let name = city["name"] as! String
        
        // Coord Dictionary
        let coordDict = city["coord"] as! Dictionary<String, Double>
        let longitude = coordDict["lon"]! as CLLocationDegrees
        let latitude = coordDict["lat"]! as CLLocationDegrees
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // Weather Dictionary
        var weatherMain=""
        var weatherDescription = ""
        var weatherImageName = ""
        
        let weather = city["weather"] as! Array<Dictionary<String, AnyObject>>
        if weather.count > 0 {
            let firstWeatherResult = weather[0] 
            weatherMain = firstWeatherResult["main"]! as! String
            weatherDescription = firstWeatherResult["description"]! as! String
            weatherImageName = firstWeatherResult["icon"]! as! String
        }
        
        let temperatureScale = Model.TemperatureScale.Fahrenheit
        
        // Main Dictionary
        let main = city["main"] as! Dictionary<String, Double>
        let temp = main["temp"]!
        let tempMin = main["temp_min"]!
        let tempMax = main["temp_max"]!
        
        
        // Return the new city
        return City(cityName: name, temperature: temp, tempMin: tempMin, tempMax: tempMax, temperatureScale: temperatureScale, weatherImageName: weatherImageName, weatherMain: weatherMain, weatherDescription: weatherDescription, cityID: id, coordinate: coordinate)
    }
}