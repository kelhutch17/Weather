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
    fileprivate var cities = [City]()

    fileprivate let defaultCityName = "Mountain View"
    fileprivate let defaultCityID = 5375480
    
    fileprivate let authorizationStatusNotificationKey = "AuthorizationStatusChanged"
    fileprivate let apiKey = "242dcb57484b603f1a9a2ba52556ee85"
    
    fileprivate init () {
    }
    
    func archiveCities(cities:[City]) -> NSData {
        let archivedObject = NSKeyedArchiver.archivedData(withRootObject: cities as NSArray)
        return archivedObject as NSData
    }
    
    func saveCities(cities:[City]) {
        let archivedObject = archiveCities(cities: cities)
        let defaults = UserDefaults.standard
        defaults.set(archivedObject, forKey: "CITIES")
        defaults.synchronize()
    }
    
    func retrieveCities() -> [City]? {
        if let unarchivedObject = UserDefaults.standard.object(forKey: "CITIES") as? NSData {
            return NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject as Data) as? [City]
        }
        return nil
    }
    
    func addCityToDefaults(city: City) {
        if var cities = retrieveCities() {
            cities.append(city)
            saveCities(cities: cities)
        } else {
            saveCities(cities: [city])
        }
    }
    
    func cityIsADuplicate(city: City, storedCities: [City]) -> Bool {
        for storedCity in storedCities {
            if storedCity.cityNameValue() == city.cityNameValue() {
                return true
            }
        }
        return false
    }
    
    func removeCityFromDefaults(atIndex: Int) {
        if var cities = retrieveCities() {
            cities.remove(at: atIndex)
            saveCities(cities: cities)
        }
    }
    
    // Setter and Getters
    func notificationKey() -> String {
        return authorizationStatusNotificationKey
    }
    
    func citiesArrayCount() -> Int {
        return cities.count
    }
    
    func cityForRow(_ row:Int) -> City {
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
    
    func addNewCity(_ city:City) {
        cities.append(city)
    }
    
    func removeCityFromRow(_ row:Int) {
        cities.remove(at: row)
    }
}
