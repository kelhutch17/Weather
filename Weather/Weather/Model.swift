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
    // Local Variables
    static let sharedInstance = Model()
    private var cities = [City]()
    private var defaultCity:City?
    
    private let authorizationStatusNotificationKey = "AuthorizationStatusChanged"
    
    private init () {
    }
    
    func setupDefaultCity() {
        // Make API calls for default city (Mountain View)
        
        // create new city object and add to array at index 0
        
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
    
    func defaultCityToShow() -> City? {
        return defaultCity
    }
}