//
//  City.swift
//  Weather
//
//  Created by Kelly Hutchison on 10/27/15.
//  Copyright © 2015 Kelly Hutchison. All rights reserved.
//

import Foundation
import CoreLocation

class City: NSObject, NSCoding {
    fileprivate let cityName: String
    fileprivate var temperature: Double?
    fileprivate var tempMin: Double?
    fileprivate var tempMax: Double?
    fileprivate let temperatureScale: Model.TemperatureScale
    fileprivate var weatherMain: String = ""
    fileprivate var weatherDescription: String = ""
    fileprivate var weatherImageName: String?
    fileprivate var id: String?
    fileprivate var coordinate:CLLocationCoordinate2D?
    
    init(cityName:String, temperature:Double, tempMin:Double, tempMax:Double, temperatureScale:Model.TemperatureScale,
        weatherImageName:String, weatherMain:String, weatherDescription:String, cityID:String, coordinate:CLLocationCoordinate2D) {
        
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
    
    required init(coder aDecoder: NSCoder) {
        cityName = aDecoder.decodeObject(forKey: "cityname") as! String
        temperature = aDecoder.decodeObject(forKey: "temperature") as? Double
        tempMin = aDecoder.decodeObject(forKey: "tempmin") as? Double
        tempMax = aDecoder.decodeObject(forKey: "tempmax") as? Double
        let tempScaleString = aDecoder.decodeObject(forKey: "tempscale") as! Model.TemperatureScale.RawValue
        temperatureScale = Model.TemperatureScale(rawValue: tempScaleString)!
        weatherImageName = aDecoder.decodeObject(forKey: "imgName") as? String
        weatherMain = aDecoder.decodeObject(forKey: "weathermain") as! String
        weatherDescription = aDecoder.decodeObject(forKey: "weatherdesc") as! String
        id = aDecoder.decodeObject(forKey: "id") as? String
        
        let lat = aDecoder.decodeObject(forKey: "latitude") as? CLLocationDegrees
        let long = aDecoder.decodeObject(forKey: "longitude") as? CLLocationDegrees
        coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(cityName, forKey: "cityname")
        aCoder.encode(temperature, forKey: "temperature")
        aCoder.encode(tempMin, forKey: "tempmin")
        aCoder.encode(tempMax, forKey: "tempmax")
        aCoder.encode(temperatureScale.rawValue, forKey: "tempscale")
        aCoder.encode(weatherImageName, forKey: "imgName")
        aCoder.encode(weatherMain, forKey: "weathermain")
        aCoder.encode(weatherDescription, forKey: "weatherdesc")
        aCoder.encode(id, forKey: "id")
        aCoder.encode(coordinate?.latitude, forKey: "latitude")
        aCoder.encode(coordinate?.longitude, forKey: "longitude")
    }
    
    func updateTemperature(_ newTemp:Double) {
        temperature = newTemp
    }
    
    func updateCityCode(_ newCode:String) {
        id = newCode
    }
    
    func cityCodeValue() -> String {
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
    
    func lowTempValue() -> Double? {
        return tempMin
    }
    
    func highTempValue() -> Double? {
        return tempMax
    }
    
    func weatherDescriptionValue() -> String {
        return weatherDescription
    }
    
    func weatherMainValue() -> String {
        return weatherMain
    }
    
    func weatherImageNameValue() -> String? {
        return weatherImageName
    }
}
