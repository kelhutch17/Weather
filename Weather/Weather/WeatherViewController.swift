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
    
    // Outlets
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var loadingOverlay: UIView!
    @IBOutlet weak var lowTemperatureLabel: UILabel!
    @IBOutlet weak var highTemperatureLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show loading overlay
        self.loadingOverlay.isHidden = false
        
        // Setup the model to get info about the default city
        setupDefaultCity()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Request location permission from user
        if locationManager.locationServicesEnabled()  {
            if  locationManager.authorizationStatus() == .notDetermined {
                locationManager.locationManager.requestWhenInUseAuthorization()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Function to set a default city when the app is first launched
    func setupDefaultCity() {
        
        // Make API calls for default city (Mountain View)
        let weatherAPI = OpenWeatherMap(language: "en", temperatureScale: Model.TemperatureScale.Fahrenheit.rawValue, APIKey: model.apiKeyValue())
        
        // Get the weather info for default city's ID
        weatherAPI.weatherForCityID(model.defaultCityIDValue(), callback: { result in
            if let dictionary = result {
                
                // Create a new city with SearchCities helper method
                let searcher = SearchCities()
                self.city = searcher.newCityFromCityDictionary(dictionary)

                // Add city to model so we can populate the table view with default city in it
                if let city = self.city {
                    if let citiesArray = self.model.retrieveCities() {
                        // check for duplication
                        if !self.model.cityIsADuplicate(city: city, storedCities: citiesArray) {
                            self.model.addCityToDefaults(city: city)
                        }
                    } else {
                        self.model.addCityToDefaults(city: city)
                    }
                    
                    self.model.addNewCity(city)
                }
                
                // Set labels for new city here
                self.displayNewCity()
                
                // Show loading overlay
                self.loadingOverlay.isHidden = true
            }
            else {
                print("Error in reaching API")
            }
        })
    }
    
    // Populate labels with new city's weather info
    func displayNewCity() {
        // update labels for new city
        if let city = city {
            cityNameLabel.text = city.cityNameValue()
            temperatureLabel.text = city.temperatureValue()?.description
            highTemperatureLabel.text = city.highTempValue()?.description
            highTemperatureLabel.text = city.lowTempValue()?.description
            weatherDescriptionLabel.text = city.weatherDescriptionValue()
            if let imgName = city.weatherImageNameValue() {
                icon.image = UIImage(named: imgName)
            }
        } else {
            cityNameLabel.text = "Error in loading city. Please try again later."
        }
    }
    
    
    // MARK: CityTableViewProtocol
    
    // Function called when a new city was selected from the table view of cities
    func newCitySelected(_ selectedCity:City) {
        
        // show the overlay while we load
        loadingOverlay.isHidden = false
        
        // Store the selected city and create completion block to show this city
        city = selectedCity
        let completionBlock = {
            self.displayNewCity()
            self.loadingOverlay.isHidden = true
        }
        
        // dismiss the presented view controller
        dismiss(animated: true, completion: completionBlock)
    }
    
    // Function called when cancel button on table view is pressed
    func cityTableViewDismissed(_ resetToDefaultCity: Bool) {
        // If the previously shown city was deleted from the table view, reset to default city
        if resetToDefaultCity {
            setupDefaultCity()
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "addNewLocation":
            let navigationController = segue.destination as! UINavigationController
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

