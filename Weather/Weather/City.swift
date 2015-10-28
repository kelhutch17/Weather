//
//  City.swift
//  Weather
//
//  Created by Kelly Hutchison on 10/27/15.
//  Copyright © 2015 Kelly Hutchison. All rights reserved.
//

import Foundation

class City: NSObject {
    private let cityName: String
    private var temperature: Double?
    private let temperatureScale: Model.TemperatureScale
    private var weatherImageName: String?
    
    // Setup if you do not have the weather info yet
    init(cityName:String, temperatureScale:Model.TemperatureScale) {
        self.cityName = cityName
        self.temperatureScale = temperatureScale
        super.init()
    }
    
    init(cityName:String, temperature:Double, temperatureScale:Model.TemperatureScale, weatherImageName:String) {
        
        self.cityName = cityName
        self.temperature = temperature
        self.temperatureScale = temperatureScale
        self.weatherImageName = weatherImageName
        
        super.init()
    }
    
    func updateTemperature(newTemp:Double) {
        temperature = newTemp
    }
    
    func cityNameValue() -> String {
        return cityName
    }
    
    func temperatureValue() -> Double? {
        return temperature
    }
    
    func temperatureScaleValue() -> Model.TemperatureScale {
        return temperatureScale
    }
    
    func weatherImageNameValue() -> String? {
        return weatherImageName
    }
}
