//
//  RequestQueueAdd.swift
//  Koda.nu
//
//  Created by Alvar Lagerlöf on 4/7/17.
//  Copyright © 2017 Alvar Lagerlöf. All rights reserved.
//

import Foundation
import RealmSwift


public class RequestQueueAdd {


    init(url: String) {
        
        let realm = try! Realm()
        
        let newRealmProject = RequestQueueItem()
        newRealmProject.url = url
        
        try! realm.write {
            realm.add(newRealmProject)
        }
        
        _ = RequestQueueSync()

        
    }


}
