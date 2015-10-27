//
//  Model.swift
//  Weather
//
//  Created by Kelly Hutchison on 10/27/15.
//  Copyright © 2015 Kelly Hutchison. All rights reserved.
//

import Foundation

class Model
{
    // Local Variables
    static let sharedInstance = Model()
    var cities = [City]()
    
    private init () {
    }
    
}