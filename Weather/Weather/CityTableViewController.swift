//
//  CityTableViewController.swift
//  Weather
//
//  Created by Kelly Hutchison on 10/27/15.
//  Copyright © 2015 Kelly Hutchison. All rights reserved.
//

import UIKit
import CoreLocation

protocol CityTableViewProtocol {
    func newCitySelected(city:City)
    func cityTableViewDismissed()
}

class CityTableViewController: UITableViewController {

    enum TemperatureScale: String {
        case Celsius = "metric"
        case Fahrenheit = "imperial"
    }
    
    // Constants
    let numSections = 2
    
    // locals
    let model = Model.sharedInstance
    let locationManager = LocationManagerSingleton.sharedInstance
    let weatherAPI = OpenWeatherMap(language: "en", temperatureScale: TemperatureScale.Fahrenheit.rawValue, APIKey: "242dcb57484b603f1a9a2ba52556ee85")

    var delegate:CityTableViewProtocol?
    
    var notificationKey:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        // Add notification listener
        notificationKey = model.notificationKey()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "authorizationStatusChanged:" as Selector, name:notificationKey, object:  nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: notificationKey, object: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return numSections
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return model.citiesArrayCount()
            
        default:
            return 1
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        let row = indexPath.row
        
        // User location
        if section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("userLocationCell", forIndexPath: indexPath)
            //            cell.textLabel?.text = "Current Location"
            return cell
        }
            // Other saved cities
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("cityCustomCell", forIndexPath: indexPath) as! CityTableViewCell
            
            let city = model.cityForRow(row)
            cell.city = city
            cell.cityNameLabel.text = city.cityName
            cell.temperatureLabel.text = city.temperature.description
            cell.weatherImageView.image = UIImage(named: city.weatherImageName)
            return cell
        }
        
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // check type of cell before casting it
        let cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        let cellType:String = cell.reuseIdentifier!
        
        switch cellType {
        case "cityCustomCell":
            let cityCell = cell as! CityTableViewCell
            
            // return the city for the selected cell
            if let delegate = delegate {
                delegate.newCitySelected(cityCell.city!)
            }
            else {
                NSLog("Delegate not set")
            }
            
            break
            
        case "userLocationCell":
            if locationManager.locationServicesEnabled() {
                if locationManager.authorizationStatus() == .Denied {
                    showErrorAlert("Location Services Turned Off", message: "Change the location settings for this app in your phone's privacy settings to allow us to show the weather in your current location")
                    return
                }
                else {
                    if let delegate = delegate {
                        delegate.newCitySelected(newCityForUserLocation()!)
                    }
                    else {
                        NSLog("Delegate not set")
                    }
                }
            }
            else {
                NSLog("Location services not enabled")
            }
            
            break
            
        default:
            break
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            
        }
    }
    
    // MARK: NSNotification Handlers
    func authorizationStatusChanged(notification:NSNotification) {
        if notification.name == notificationKey {
            let status = notification.object as! CLAuthorizationStatus
            
            if status == CLAuthorizationStatus.AuthorizedWhenInUse {
                
            }
            else {
                
            }
        }
    }
    
    // MARK: Helper Functions
    func showErrorAlert(title:String, message:String) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alertViewController.addAction(alertAction)
        presentViewController(alertViewController, animated: true, completion: nil)
    }
    
    func newCityForUserLocation() -> City? {
        
        let currentLocation = locationManager.currentLocation
        
        // make API calls here
        if let jsonData = weatherAPI.findCityForCoordinate(currentLocation!.coordinate) {
            let cityName = jsonData["name"] as! String
        }
            
//            { result in
//            
//        if let resultType = result.1 {
//            if resultType is NSError {
//                let error = resultType as! NSError
//                NSLog(error.description)
//            } else if resultType is Dictionary<String, AnyObject> {
//                theResult = resultType as! Dictionary<String, AnyObject>
//            }
//        }
//    }
        
        
        //        let cityName = model.cityNameForLocation(location)
        //        let temperature = model.temperatureFor
        //
        //        var newCity = City(cityName: cityName, temperature: <#T##Int#>, temperatureScale: <#T##String#>, weatherImageName: <#T##String#>)
        
        return nil
    }
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        
        if let delegate = delegate {
            delegate.cityTableViewDismissed()
        } else {
            NSLog("Delegate not set")
        }
    }

    
}
