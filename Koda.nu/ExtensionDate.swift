//
//  ExtensionDate.swift
//  Koda.nu
//
//  Created by Alvar Lagerlöf on 6/20/17.
//  Copyright © 2017 Alvar Lagerlöf. All rights reserved.
//

import Foundation

extension String {
    
    var timestampToDate: String {
    
        if (self != "") {
            if (Double(self) != nil) {
                let date = Date(timeIntervalSince1970: Double(self)!)
                let dayTimePeriodFormatter = DateFormatter()
                dayTimePeriodFormatter.dateFormat = "d MMM YYYY, HH:mm"
                let dateString = dayTimePeriodFormatter.string(from: date)
                
                return dateString
                
            } else {
                return "Error"
            }
        } else {
            return "Error"
        }
    
    }
    
    
    
}
