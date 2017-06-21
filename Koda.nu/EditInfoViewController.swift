//
//  EditInfoViewController.swift
//  Koda.nu
//
//  Created by Alvar Lagerlöf on 5/26/17.
//  Copyright © 2017 Alvar Lagerlöf. All rights reserved.
//


import UIKit
import RealmSwift
import Eureka

class EditInfoViewController: FormViewController {
    
    var privateID: String = ""
	
    let realm = try! Realm()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Redigera info"

        
        let object = realm.objects(ProjectsRealmItem.self).filter("privateID = '\(privateID)'").first
        
        
        
        form +++ Section("Titel")
            <<< TextRow("title") { row in
                row.placeholder = "Ingen titel skriven"
                row.value = object?.title
            }
            
            +++ Section("Beskrivning")
            <<< TextAreaRow("description") { row in
                row.placeholder = "Ingen beskrivning skriven"
                row.value = object?.descriptionText
            }
            
            +++ Section("Synlighet på arkivet")
            <<< SwitchRow("public") { row in
                row.title = "Ska vara publik"
                row.value = object?.isPublic
            }
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        let titleRow : TextRow? = form.rowBy(tag: "title")
        let descriptionRow : TextAreaRow? = form.rowBy(tag: "description")
        let publicRow : SwitchRow? = form.rowBy(tag: "public")
        
        
        let object = realm.objects(ProjectsRealmItem.self).filter("privateID = '\(privateID)'").first
        
        
        try! realm.write {
            object?.title = titleRow?.value == nil ? "Namnlös" : (titleRow?.value)!
            object?.descriptionText = descriptionRow?.value == nil ? "" : (descriptionRow?.value)!
            object?.isPublic = (publicRow?.value)!
            object?.updatedRealm = String(Int(round(NSDate().timeIntervalSince1970)))
            object?.isSynced = false
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateProjectsDone"), object: self)
        
        _ = ProjectsSync()
        
    }
    
    
    
}
