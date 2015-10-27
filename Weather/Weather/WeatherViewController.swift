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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the model to get info about the default city
        model.setupDefaultCity()
        
        // If API calls succeeded and we have the info about the default city, show it
        if let defaultCity = model.defaultCityToShow() {
            
        } else {
            NSLog("Failed to get info about the default city")
        }
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if locationManager.locationServicesEnabled()  {
            if  locationManager.authorizationStatus() == .NotDetermined {
                locationManager.locationManager!.requestWhenInUseAuthorization()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func displayNewCity() {
        // update labels
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

}

