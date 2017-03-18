//
//  File.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 01/09/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import Foundation
import RealmSwift

class ProjectsRealmItem: Object {
    dynamic var privateID = ""
    dynamic var publicID = ""
    dynamic var title = ""
    dynamic var descriptionText = ""
    dynamic var updated = ""
    dynamic var code = ""
    dynamic var isPublic = false
    
}
