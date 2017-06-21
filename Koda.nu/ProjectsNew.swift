//
//  ProjectsNew.swift
//  Koda.nu
//
//  Created by Alvar Lagerlöf on 4/5/17.
//  Copyright © 2017 Alvar Lagerlöf. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Firebase

public class ProjectsNew {


    init(nav: UINavigationController) {
        
        let addAlert = UIAlertController(title: "Vad ska den heta?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        addAlert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Titel"
        })
        
        addAlert.addAction(UIAlertAction(title: "Skapa", style: .default, handler: { (action: UIAlertAction!) in
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateProjectsStarted"), object: self)

            
            let tmpID = "ny_ny_" + String(Int64(Date().timeIntervalSince1970 * 1000))
            
            let object = ProjectsRealmItem()
            object.privateID = tmpID
            object.publicID = tmpID
            object.title = !addAlert.textFields![0].text!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty ? addAlert.textFields![0].text! : "Namnlös"
            object.descriptionText = ""
            object.updatedRealm = String(Int64(Date().timeIntervalSince1970))
            object.updatedServer = ""
            object.isPublic = false
            object.isSynced = false
            object.code = String("<script src=\"http://koda.nu/simple.js\">\n\n  circle(100, 100, 20, \"red\");\n\n</script>")
            
            
            let realm = try! Realm()
            
            try! realm.write {
                realm.add(object)
            }
            
            
            _ = ProjectsSync(nav: nav, openPrivateID: tmpID)
            
            Analytics.logEvent("projects_create_successful", parameters: [:])

            
            
            
        }))
        
        addAlert.addAction(UIAlertAction(title: "Avbryt", style: .cancel, handler: { (action: UIAlertAction!) in }))
        
        ViewHelper().getRoot().present(addAlert, animated: true, completion: nil)

        
    }

}
