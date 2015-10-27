//
//  WeatherViewController.swift
//  Weather
//
//  Created by Kelly Hutchison on 10/27/15.
//  Copyright © 2015 Kelly Hutchison. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate, CityTableViewProtocol {

    // constant instances
    let locationManager = CLLocationManager()
    let model = Model.sharedInstance
    
    // locals 
    var city:City?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the location delegate and desired accuracy
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if CLLocationManager.locationServicesEnabled()  {
            if CLLocationManager.authorizationStatus() == .NotDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func displayNewCity() {
        
    }
    
    
    // MARK: CLLocationManagerDelegate
    // If location authorization changes, handle it here
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {

        }
        else {

        }
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

