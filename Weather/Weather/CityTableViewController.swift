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
    func cityTableViewDismissed(resetToDefaultCity:Bool)
}

class CityTableViewController: UITableViewController, UISearchResultsUpdating, SearchCitiesProtocol {
    
    // outlets
   // @IBOutlet weak var searchBar: UISearchBar!

    
    // Constants
    let numSections = 2
    
    // locals
    let model = Model.sharedInstance
    let locationManager = LocationManagerSingleton.sharedInstance
    var weatherAPI:OpenWeatherMap?
    var city:City?
    var delegate:CityTableViewProtocol?
    var notificationKey:String?
    var searchIsActive:Bool = false
    var currentlyShownCity:City?
    var shownCityDeleted:Bool = false
    
    // Search Vars
    var cities=[City]()
    var filteredCities=[City]()
    var resultSearchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // initialize API caller
        weatherAPI = OpenWeatherMap(language: "en", temperatureScale: Model.TemperatureScale.Fahrenheit.rawValue, APIKey: model.apiKeyValue())
        
        // Add notification listener
        notificationKey = model.notificationKey()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "authorizationStatusChanged:" as Selector, name:notificationKey, object:  nil)
        
        resultSearchController = UISearchController(searchResultsController: nil)
        resultSearchController.searchResultsUpdater = self
        resultSearchController.dimsBackgroundDuringPresentation = false
        resultSearchController.searchBar.sizeToFit()
        
        // enable the search bar
        resultSearchController.searchBar.userInteractionEnabled = true
        
        self.tableView.tableHeaderView = self.resultSearchController.searchBar
        
        self.tableView.reloadData()
        
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
        
        if (resultSearchController.active)
        {
            return 1
        } else {
            return numSections
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.resultSearchController.active) {
            return filteredCities.count
        } else {
            switch section {
            case 0:
                return 1
            case 1:
                return model.citiesArrayCount()
                
            default:
                return 1
            }
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        let row = indexPath.row
        
        if (self.resultSearchController.active)
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell?

            cell!.textLabel?.text = filteredCities[row].cityNameValue()
            
            return cell!
        }
        
        // User location
        if section == 0 {
            let cell =  tableView.dequeueReusableCellWithIdentifier("userLocationCell", forIndexPath: indexPath)
            cell.selectionStyle = .None
            return cell
        }
            // Other saved cities
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("cityCustomCell", forIndexPath: indexPath) as! CityTableViewCell
            
            let city = model.cityForRow(row)
            cell.city = city
            cell.cityNameLabel.text = city.cityNameValue()
            cell.temperatureLabel.text = city.temperatureValue()!.description
            
            if let imageName = city.weatherImageNameValue() {
                cell.weatherImageView.image = UIImage(named: "\(imageName).png")
            }
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Search Table View
        if (self.resultSearchController.active)
        {
            // Only can select if there is a returned value
            if filteredCities.count == 0 {
                return
            }
            
            // disable the search bar while we are dismissing
            resultSearchController.searchBar.userInteractionEnabled = false
            
            // return the city for the selected cell
            let selectedCity = filteredCities[indexPath.row]
            
            // Add the selected city to the original table view and reload
            model.addNewCity(selectedCity)
            
            // dismiss the search results table view and reload the old table with the new value added
            dismissViewControllerAnimated(true, completion: nil)
            tableView.reloadData()
            
            // enable the search bar now that we have successfully returned from the search
            resultSearchController.searchBar.userInteractionEnabled = true
        }
        else {
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
                        newCityForUserLocation()
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
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if (self.resultSearchController.active)
        {
            return false
        }
        
        // Don't let the user edit the "Current Location" cell
        if indexPath.section == 0 {
            return false
        }
        
        return true
    }
    
    // Override to perform actions when edit/done button is pressed
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        // Disable the search bar when editing
        if editing {
            resultSearchController.searchBar.userInteractionEnabled = false
        } else {
            resultSearchController.searchBar.userInteractionEnabled = true
        }
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let row = indexPath.row
            
            // Delete the row from the data source
            if let shownCity = currentlyShownCity {
                if model.cityForRow(row) == shownCity {
                    // replace shown city with default city 
                    shownCityDeleted = true
                }
            }
            model.removeCityFromRow(row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            // enable the search bar when we are finished editing
            resultSearchController.searchBar.userInteractionEnabled = true
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
    
    func newCityForUserLocation() {
        
        if let currentLocation = locationManager.currentLocation {
            // make API calls here
            if let weatherAPI = weatherAPI {
                weatherAPI.weatherForCoordinate(currentLocation.coordinate, callback: { result in
                    if let dictionary = result {
                        
                        // Create a new city with SearchCities helper method
                        let searcher = SearchCities()
                        let newCity = searcher.newCityFromCityDictionary(dictionary)
                        
                        // Dismiss and pass the city back
                        if let delegate = self.delegate {
                            delegate.newCitySelected(newCity)
                        } else {
                            NSLog("Delegate not set!")
                        }
                    }
                    else {
                        print("Failed to complete API call")
                    }
                })
            }
        } else {
            NSLog("Could not find the current location. If you are using the simulator, does it have a location?")
        }
    }
    
    // MARK: UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filteredCities.removeAll(keepCapacity: false)
        
        let searchPredicate:String = searchController.searchBar.text!
        let searcher = SearchCities()
        searcher.delegate = self
        searcher.findCitiesWithName(searchPredicate)
    }
    
    // MARK: SearchCitiesProtocol
    func matchingCitiesFound(matchingCities: [City]) {
        filteredCities = matchingCities
        self.tableView.reloadData()
    }
    
    // Actions
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        
        if let delegate = delegate {
            delegate.cityTableViewDismissed(shownCityDeleted)
        } else {
            NSLog("Delegate not set")
        }
    }
}
