//
//  StringExtension.swift
//  Weather
//
//  Created by Kelly Hutchison on 10/28/15.
//  Copyright © 2015 Kelly Hutchison. All rights reserved.
//

import Foundation

extension String {
    func removeSpaces() -> String {
        return String(self.characters.map {
                $0 == " " ? "+" : $0
            })
    }
}
