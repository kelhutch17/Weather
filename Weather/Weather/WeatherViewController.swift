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
    @IBOutlet weak var loadingOverlay: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show loading overlay
        self.loadingOverlay.hidden = false
        
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
        
        // Make API calls for default city (Mountain View)
        let weatherAPI = OpenWeatherMap(language: "en", temperatureScale: Model.TemperatureScale.Fahrenheit.rawValue, APIKey: model.apiKeyValue())
        
        weatherAPI.weatherForCityID(model.defaultCityIDValue(), callback: { result in
            if let dictionary = result {
                
                // Create a new city with SearchCities helper method
                let searcher = SearchCities()
                self.city = searcher.newCityFromCityDictionary(dictionary)
                
                // Add city to model so we can populate the table view with default city in it
                if let city = self.city {
                    self.model.addNewCity(city)
                }
                
                // Set labels for new city here
                self.displayNewCity()
                
                // Show loading overlay
                self.loadingOverlay.hidden = true
            }
            else {
                print("Error in reaching API")
            }
        })
    }

    
    func displayNewCity() {
        // update labels for new city
        if let city = city {
            cityNameLabel.text = city.cityNameValue()
            temperatureLabel.text = city.temperatureValue()?.description
        } else {
            cityNameLabel.text = "Error in loading city. Please try again later."
        }
    }
    
    
    // MARK: CityTableViewProtocol
    func newCitySelected(selectedCity:City) {
        
        // show the overlay while we load
        loadingOverlay.hidden = false
        
        // Store the selected city and create completion block to show this city
        city = selectedCity
        let completionBlock = {
            self.displayNewCity()
            self.loadingOverlay.hidden = true
        }
        
        // dismiss the presented view controller
        dismissViewControllerAnimated(true, completion: completionBlock)
    }
    
    func cityTableViewDismissed(resetToDefaultCity: Bool) {
        // If the previously shown city was deleted from the table view, reset to default city
        if resetToDefaultCity {
            setupDefaultCity()
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "addNewLocation":
            let navigationController = segue.destinationViewController as! UINavigationController
            let destinationViewController = navigationController.topViewController as! CityTableViewController
            destinationViewController.delegate = self
            destinationViewController.currentlyShownCity = city
            break
        default:
            NSLog("Unhandled segue")
            break
        }
    }

}

