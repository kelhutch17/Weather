//
//  WeatherViewController.swift
//  Weather
//
//  Created by Kelly Hutchison on 10/27/15.
//  Copyright © 2015 Kelly Hutchison. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController, CityTableViewProtocol {

    // shared instances
    let locationManager = LocationManagerSingleton.sharedInstance
    let model = Model.sharedInstance
    
    // locals 
    var city:City?
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the model to get info about the default city
        setupDefaultCity()
        
        // If API calls succeeded and we have the info about the default city, show it
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if locationManager.locationServicesEnabled()  {
            if  locationManager.authorizationStatus() == .NotDetermined {
                locationManager.locationManager.requestWhenInUseAuthorization()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setupDefaultCity() {
        
        // create new city object and add to array at index 0
        city = City(cityName: model.defaultCityNameString(), temperatureScale: Model.TemperatureScale.Fahrenheit)
        
        cityNameLabel.text = city?.cityNameValue()
        
        // Make API calls for default city (Mountain View)
        let weatherAPI = OpenWeatherMap(language: "en", temperatureScale: Model.TemperatureScale.Fahrenheit.rawValue, APIKey: model.apiKeyValue())
        
        weatherAPI.weatherForCityName(city!.cityNameValue(), callback: { result in
            if let dictionary = result {
                let weather = dictionary["main"] as? Dictionary<String, AnyObject>
                
                if let weatherDict = weather {
                    let temp = weatherDict["temp"]
                    self.city!.updateTemperature(temp as! Double)
                    self.temperatureLabel.text = self.city?.temperatureValue()?.description
                }
                
            }
            else {
                print("error")
            }
        })
    }

    
    func displayNewCity() {
        // update labels
        cityNameLabel.text = city?.cityNameValue()
        self.temperatureLabel.text = self.city?.temperatureValue()?.description
    }
    
    
    // MARK: CityTableViewProtocol
    func newCitySelected(selectedCity:City) {
        
        // Store the selected city and create completion block to show this city
        city = selectedCity
        let completionBlock = {
            self.displayNewCity()
        }
        
        // dismiss the presented view controller
        dismissViewControllerAnimated(true, completion: completionBlock)
    }
    
    func cityTableViewDismissed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "addNewLocation":
            let navigationController = segue.destinationViewController as! UINavigationController
            let destinationViewController = navigationController.topViewController as! CityTableViewController
            destinationViewController.delegate = self
            break
        default:
            NSLog("Unhandled segue")
            break
        }
    }

}

