//
//  ProjectsSyncNew.swift
//  Koda.nu
//
//  Created by Alvar Lagerlöf on 6/20/17.
//  Copyright © 2017 Alvar Lagerlöf. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import SwiftyJSON
import Alamofire


public class ProjectsSync {
    
    var nav: UINavigationController? = nil
    var openPrivateID: String? = nil


    init() {
        
        // Sync or just update list
        if Reachability.isConnectedToNetwork() {
            sendToServer()
        } else {
            NotificationCenter.default.post(name: .projectsReload, object: self)
        }
    }
    
    
    
    init(nav: UINavigationController, openPrivateID: String) {
        self.nav = nav
        self.openPrivateID = openPrivateID

        
        // Open editor
        let storyboard = UIStoryboard(name: "Editor", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "editor") as! EditorViewController
        vc.firstPrivateID = self.openPrivateID!
        self.nav?.pushViewController(vc, animated: true)
        
        
        // Sync or just update list
        if Reachability.isConnectedToNetwork() {
            sendToServer()
        } else {
            NotificationCenter.default.post(name: .projectsReload, object: self)
        }
    }
    
    
    
    
    
    
    func sendToServer() {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            
            let realm = try! Realm()
            
        
            // Get all realm projects
            let realmProjects = realm.objects(ProjectsRealmItem.self)
            
            
            // Create a json array
            var projects: [JSON] = []
            
            
            // Loop over realm projects
            for realmProject: ProjectsRealmItem in realmProjects {
                
                
                var jsonObject: JSON = ["privateID": realmProject.privateID,
                                        "updated": realmProject.updatedServer]
                
                if !realmProject.isSynced {
                    jsonObject["title"].string       = realmProject.title.base64encode
                    jsonObject["description"].string = realmProject.descriptionText.base64encode
                    jsonObject["public"].bool        = realmProject.isPublic
                    jsonObject["code"].string        = realmProject.code.base64encode
                }
                
                projects.append(jsonObject)
                
                
            }
            
            
            // Create parameters
            let parameters: Parameters = ["projects": JSON(projects)]
            
    
            Alamofire.request(Vars.URL_PROJECTS_SYNC, method: .post, parameters: parameters).responseJSON { response in
                switch response.result {
                case .success:
                    
                    // Get JSON array
                    let json = JSON(response.result.value as Any)["projects"].arrayValue
                    
                    
                    // Get new openPrivateID
                    if response.result.value != nil && self.openPrivateID != nil {
                        for item in json {
                            if self.openPrivateID == item["old_privateID"].string {
                                self.openPrivateID = item["privateID"].string
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.sendNothing()
                    }
                    
                case .failure(let error):
                    print(error)
                    
                }
                
            }
        }

        
    }
    
    
    
    func sendNothing() {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            
            // Create parameters
            let parameters: Parameters = ["projects": "[]"]
            
            
            Alamofire.request(Vars.URL_PROJECTS_SYNC, method: .post, parameters: parameters).responseJSON { response in
                switch response.result {
                case .success:
                    
                    DispatchQueue.main.async {
                        self.dealWithResponse(response: JSON(response.result.value as Any))
                    }
                    
                case .failure(let error):
                    print(error)
                    
                }
                
            }
        }
    }
    
    
    func dealWithResponse(response: JSON) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            let realm = try! Realm()
            
            
            // Get child "projects" -> Array
            let responseArray: Array = response["projects"].arrayValue
            
            // If resonse is not empty
            if responseArray.count > 0 {
                
                
                // Remove projects that exists on the client but not on the server
                for project in realm.objects(ProjectsRealmItem.self) {
                    var hasFoundInJson = false
                    
                    for item in responseArray {
                        if item["privateID"].string == project.privateID {
                            hasFoundInJson = true
                        }
                    }
                    if !hasFoundInJson {
                        try! realm.write {
                            realm.delete(project)
                        }
                    }
                }
                    
                
                
                
                // Loop over response
                for responseItem in responseArray {
                    
                    
                    // Get realm project based on privateID
                    // and deal with nil
                    if let realmProject: ProjectsRealmItem = realm.objects(ProjectsRealmItem.self).filter("privateID = '" + responseItem["old_privateID"].string! + "'").first {
                        
                        
                        // Edit existing one
                        try! realm.write {
                            realmProject.privateID       = responseItem["privateID"].string!
                            realmProject.publicID        = responseItem["publicID"].string!
                            realmProject.title           = responseItem["title"].string!.base64decode
                            realmProject.descriptionText = responseItem["description"].string!.base64decode
                            realmProject.code            = responseItem["code"].string!.base64decode
                            realmProject.isSynced        = true
                            realmProject.isPublic        = responseItem["public"].bool!
                            realmProject.updatedServer   = String(describing: responseItem["updated"])
                            realmProject.updatedRealm    = String(describing: responseItem["updated"])
                                                        
                        }
                    } else {
                        
                        // Create new
                        let newRealmProject = ProjectsRealmItem()
                        newRealmProject.privateID       = responseItem["privateID"].string!
                        newRealmProject.publicID        = responseItem["publicID"].string!
                        newRealmProject.title           = responseItem["title"].string!.base64decode
                        newRealmProject.descriptionText = responseItem["description"].string!.base64decode
                        newRealmProject.code            = responseItem["code"].string!.base64decode
                        newRealmProject.isSynced        = true
                        newRealmProject.isPublic        = responseItem["public"].bool!
                        newRealmProject.updatedServer   = String(describing: responseItem["updated"])
                        newRealmProject.updatedRealm    = String(describing: responseItem["updated"])
                        
                        try! realm.write {
                            realm.add(newRealmProject)
                        }
                    }
                }
                
                
            } else {
                NotificationCenter.default.post(name: .projectsReload, object: self)
                
            }
            
            if self.openPrivateID != nil {
                //let syncDataDict:[String: String] = ["image": self.openPrivateID!]

                NotificationCenter.default.post(name: .editorSyncedID, object: self, userInfo: ["synced_id": self.openPrivateID!])
            }
            
            
            
        }
        
    }
    
    
    
}
