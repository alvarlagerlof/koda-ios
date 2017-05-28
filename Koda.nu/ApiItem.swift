//
//  ApiItem.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 15/11/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import Foundation

struct ApiItem {
    
    var type: type
    var command: String
    var description: String
    
    
    enum type {
        case normal
        case offline
    }
    
}
