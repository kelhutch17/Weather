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
    func newCitySelected(_ city:City)
    func cityTableViewDismissed(_ resetToDefaultCity:Bool)
}

class CityTableViewController: UITableViewController, UISearchResultsUpdating, SearchCitiesProtocol {
    // Constants
    let numSections = 2
    
    // Shared Singletons
    let model = Model.sharedInstance
    let locationManager = LocationManagerSingleton.sharedInstance
    
    // Locals
    var weatherAPI:OpenWeatherMap?
    var searcher:SearchCities?
    var city:City?
    var delegate:CityTableViewProtocol?
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
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Set up the search view controller
        resultSearchController = UISearchController(searchResultsController: nil)
        resultSearchController.searchResultsUpdater = self
        resultSearchController.dimsBackgroundDuringPresentation = false
        resultSearchController.searchBar.sizeToFit()
        
        // enable the search bar
        resultSearchController.searchBar.isUserInteractionEnabled = true
        self.tableView.tableHeaderView = self.resultSearchController.searchBar
        
        // Initialize the search helper class variables
        searcher = SearchCities()
        weatherAPI = OpenWeatherMap(language: "en", temperatureScale: Model.TemperatureScale.Fahrenheit.rawValue, APIKey: model.apiKeyValue())

        // reload the table view
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        // If this is the search results table view
        if (resultSearchController.isActive) {
            return 1
        } else {
            return numSections
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.resultSearchController.isActive) {
            return filteredCities.count
        } else {
            switch section {
            case 0:
                return 1
            case 1:
                if let citiesArray = model.retrieveCities() {
                    return citiesArray.count
                } else {
                    return 1
                }
                
            default:
                return 1
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = (indexPath as NSIndexPath).section
        let row = (indexPath as NSIndexPath).row
        
        // If this is the search results table view add the search results
        if (self.resultSearchController.isActive)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell?

            cell!.textLabel?.text = filteredCities[row].cityNameValue()
            
            return cell!
        }
        
        // User location
        if section == 0 {
            let cell =  tableView.dequeueReusableCell(withIdentifier: "userLocationCell", for: indexPath)
            cell.selectionStyle = .none
            return cell
        }
        // Other saved cities
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cityCustomCell", for: indexPath) as! CityTableViewCell
            let city: City
            
            if let citiesArray = model.retrieveCities() {
                city = citiesArray[row]
            } else {
                city = model.cityForRow(row)
            }
            cell.city = city
            cell.cityNameLabel.text = city.cityNameValue()
            cell.temperatureLabel.text = city.temperatureValue()!.description
            
            // If there is an image for this weather condition, add it
            if let imageName = city.weatherImageNameValue() {
                cell.weatherImageView.image = UIImage(named: "\(imageName).png")
            }
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Search Table View
        if (self.resultSearchController.isActive)
        {
            // Only can select if there is a returned value
            if filteredCities.count == 0 {
                return
            }
            
            // disable the search bar while we are dismissing
            resultSearchController.searchBar.isUserInteractionEnabled = false
            
            // return the city for the selected cell
            let selectedCity = filteredCities[(indexPath as NSIndexPath).row]
            
            // Add the selected city to the original table view and reload
            if let citiesArray = self.model.retrieveCities() {
                // check for duplication
                if !model.cityIsADuplicate(city: selectedCity, storedCities: citiesArray) {
                    self.model.addCityToDefaults(city: selectedCity)
                }
            }
            model.addNewCity(selectedCity)
            
            // dismiss the search results table view and reload the old table with the new value added
            dismiss(animated: true, completion: nil)
            tableView.reloadData()
            
            // enable the search bar now that we have successfully returned from the search
            resultSearchController.searchBar.isUserInteractionEnabled = true
        }
        // Cities (Main) Table View
        else {
            // check type of cell before casting it
            let cell:UITableViewCell = tableView.cellForRow(at: indexPath)!
            let cellType:String = cell.reuseIdentifier!
            
            switch cellType {
            // City cell
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
            
            // Current Location cell
            case "userLocationCell":
                if locationManager.locationServicesEnabled() {
                    // If location is denied, remind the user of this
                    if locationManager.authorizationStatus() == .denied {
                        showErrorAlert("Location Services Turned Off", message: "Change the location settings for this app in your phone's privacy settings to allow us to show the weather in your current location")
                        return
                    }
                    // Show the current location's weather via delegate method
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
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        // Do not allow the search results table to be edited
        if (self.resultSearchController.isActive)
        {
            return false
        }
        
        // Do not let the user edit the "Current Location" cell
        if (indexPath as NSIndexPath).section == 0 {
            return false
        }
        
        // Allow the regular cities table view cells to be edited
        return true
    }
    
    // Override to perform actions when edit/done button is pressed
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        // Disable the search bar when editing
        if editing {
            resultSearchController.searchBar.isUserInteractionEnabled = false
        } else {
            resultSearchController.searchBar.isUserInteractionEnabled = true
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let row = (indexPath as NSIndexPath).row
            
            if var citiesArray = model.retrieveCities() {
                updateCurrentlyShownCityIfNeeded(deletedCity: citiesArray[row])
                model.removeCityFromDefaults(atIndex: row)
            } else {
                // Delete the row from the data source
                updateCurrentlyShownCityIfNeeded(deletedCity: model.cityForRow(row))
            }
            
            // Delete the city from the array then the table view
            //model.removeCityFromRow(row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // enable the search bar when we are finished editing
            resultSearchController.searchBar.isUserInteractionEnabled = true
            resultSearchController.searchBar.placeholder = "Search by City Name or Postal Code"
        }
    }
    
    func updateCurrentlyShownCityIfNeeded(deletedCity: City) {
        // Delete the row from the data source
        if let shownCity = currentlyShownCity {
            if deletedCity == shownCity {
                // replace shown city with default city
                shownCityDeleted = true
            }
        }
    }
    
    // MARK: Helper Functions
    func showErrorAlert(_ title:String, message:String) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertViewController.addAction(alertAction)
        present(alertViewController, animated: true, completion: nil)
    }
    
    // Create a new City object for the current user location
    func newCityForUserLocation() {
        if let currentLocation = locationManager.currentLocation {
            // make API calls here
            if let weatherAPI = weatherAPI {
                weatherAPI.weatherForCoordinate(currentLocation.coordinate, callback: { result in
                    if let dictionary = result {
                        
                        // Create a new city with SearchCities helper method
                        if let searcher = self.searcher {
                            let newCity = searcher.newCityFromCityDictionary(dictionary)
                            
                            // Add the selected city to the original table view and reload
                            if let citiesArray = self.model.retrieveCities() {
                                // check for duplication
                                if !self.model.cityIsADuplicate(city: newCity, storedCities: citiesArray) {
                                    self.model.addCityToDefaults(city: newCity)
                                }
                            }
                            
                            // Dismiss and pass the city back
                            if let delegate = self.delegate {
                                delegate.newCitySelected(newCity)
                            } else {
                                NSLog("Delegate not set!")
                            }
                        } else {
                            NSLog("SearchCities object not initialized")
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
    func updateSearchResults(for searchController: UISearchController) {
        filteredCities.removeAll(keepingCapacity: false)
        
        let searchPredicate:String = searchController.searchBar.text!
        
        // Create a new city with SearchCities helper method
        if let searcher = searcher {
            searcher.delegate = self
            searcher.findCitiesWithName(searchPredicate)
        } else {
            NSLog("SearchCities object not initialized")
        }
    }
    
    // MARK: SearchCitiesProtocol
    func matchingCitiesFound(_ matchingCities: [City]) {
        filteredCities = matchingCities
        self.tableView.reloadData()
    }
    
    // Actions
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        
        if let delegate = delegate {
            delegate.cityTableViewDismissed(shownCityDeleted)
        } else {
            NSLog("Delegate not set")
        }
    }
}
