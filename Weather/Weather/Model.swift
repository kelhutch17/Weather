//
//  Model.swift
//  Weather
//
//  Created by Kelly Hutchison on 10/27/15.
//  Copyright © 2015 Kelly Hutchison. All rights reserved.
//

import Foundation

class Model
{
    enum TemperatureScale: String {
        case Celsius = "metric"
        case Fahrenheit = "imperial"
    }
    
    // Local Variables
    static let sharedInstance = Model()
    private var cities = [City]()

    private let defaultCityName = "Mountain View"
    private let defaultCityID = 5375480
    
    private let authorizationStatusNotificationKey = "AuthorizationStatusChanged"
    private let apiKey = "242dcb57484b603f1a9a2ba52556ee85"
    
    private init () {
    }
    
    func notificationKey() -> String {
        return authorizationStatusNotificationKey
    }
    
    func citiesArrayCount() -> Int {
        return cities.count
    }
    
    func cityForRow(row:Int) -> City {
        return cities[row]
    }
    
    func defaultCityNameString() -> String {
        return defaultCityName
    }
    
    func defaultCityIDValue() -> Int {
        return defaultCityID
    }
    
    func apiKeyValue() -> String {
        return apiKey
    }
    
    func addNewCity(city:City) {
        cities.append(city)
    }
    
    func removeCityFromRow(row:Int) {
        cities.removeAtIndex(row)
    }
}