//
//  City.swift
//  Weather
//
//  Created by Kelly Hutchison on 10/27/15.
//  Copyright © 2015 Kelly Hutchison. All rights reserved.
//

import Foundation
import CoreLocation

class City: NSObject {
    private let cityName: String
    private var temperature: Double?
    private var tempMin: Double?
    private var tempMax: Double?
    private let temperatureScale: Model.TemperatureScale
    private var weatherMain: String?
    private var weatherDescription: String?
    private var weatherImageName: String?
    private var id:String?
    private var coordinate:CLLocationCoordinate2D?
    
    init(cityName:String, temperature:Double, tempMin:Double, tempMax:Double, temperatureScale:Model.TemperatureScale, weatherImageName:String, weatherMain:String, weatherDescription:String, cityID:String, coordinate:CLLocationCoordinate2D) {
        self.cityName = cityName
        self.temperature = temperature
        self.tempMin = tempMin
        self.tempMax = tempMax
        self.temperatureScale = temperatureScale
        self.weatherImageName = weatherImageName
        self.weatherMain = weatherMain
        self.weatherDescription = weatherDescription
        id = cityID
        self.coordinate = coordinate
        
        super.init()
    }
    
    func updateTemperature(newTemp:Double) {
        temperature = newTemp
    }
    
    func updateCityCode(newCode:String) {
        id = newCode
    }
    
    func cityCodeValue() -> String{
        if let _ = id {
            return id!
        } else {
            return ""
        }
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
