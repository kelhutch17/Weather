//
//  City.swift
//  Weather
//
//  Created by Kelly Hutchison on 10/27/15.
//  Copyright © 2015 Kelly Hutchison. All rights reserved.
//

import Foundation

class City: NSObject {
    let cityName: String
    let temperature: Int
    let temperatureScale: String
    let weatherImageName: String
    
    init(cityName:String, temperature:Int, temperatureScale:String, weatherImageName:String) {
        
        self.cityName = cityName
        self.temperature = temperature
        self.temperatureScale = temperatureScale
        self.weatherImageName = weatherImageName
        
        super.init()
    }
}
