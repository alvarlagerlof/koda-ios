//
//  DateHelper.swift
//  Koda.nu
//
//  Created by Alvar Lagerlöf on 4/5/17.
//  Copyright © 2017 Alvar Lagerlöf. All rights reserved.
//

import Foundation

public class DateHelper {
    
    func timeStampToDate(timeStamp: String) -> String {
        
        if (timeStamp != "") {
            if (Double(timeStamp) != nil) {
                let date = Date(timeIntervalSince1970: Double(timeStamp)!)
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
