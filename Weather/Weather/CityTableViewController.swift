//
//  CityTableViewController.swift
//  Weather
//
//  Created by Kelly Hutchison on 10/27/15.
//  Copyright © 2015 Kelly Hutchison. All rights reserved.
//

import UIKit

protocol CityTableViewProtocol {
    func newCitySelected(city:City)
}

class CityTableViewController: UITableViewController {
    
    // Constants
    let numSections = 2
    
    // locals
    let model = Model.sharedInstance
    var delegate:CityTableViewProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            return model.cities.count
        
        default:
            return 1
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cityCustomCell", forIndexPath: indexPath)
        
        // Configure the cell...

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! CityTableViewCell
        
        if let delegate = delegate {
            if let city = cell.city {
                delegate.newCitySelected(city)
            }
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

}
