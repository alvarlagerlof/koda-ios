//
//  ProjectsSync.swift
//  Koda.nu
//
//  Created by Alvar Lagerlöf on 2/12/17.
//  Copyright © 2017 Alvar Lagerlöf. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift
import FirebaseAnalytics
import SwiftOverlays

public class ProjectsSyncOld {

    var openPrivateID: String = ""
    var sendNothing: Bool = false
    var nav: UINavigationController? = nil
    
    
    init() {
                
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateProjectsStarted"), object: self)

        if Reachability.isConnectedToNetwork() {
            sendToServer()
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateProjectsDoneOffline"), object: self)
        }
    }
    
    
    init(openPrivateID: String, sendNothing: Bool, nav: UINavigationController) {
        self.sendNothing = true
        self.openPrivateID = openPrivateID
        self.nav = nav

        if Reachability.isConnectedToNetwork() {
            sendToServer()
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateProjectsDoneOffline"), object: self)
        }
    }
    
    
    init(openPrivateID: String, nav: UINavigationController) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateProjectsStarted"), object: self)
        self.openPrivateID = openPrivateID
        self.nav = nav
        
        if Reachability.isConnectedToNetwork() {
            sendToServer()
            
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateProjectsDoneOffline"), object: self)

            let storyboard = UIStoryboard(name: "Editor", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "editor") as! EditorViewController
            vc.firstPrivateID = self.openPrivateID
            self.nav?.pushViewController(vc, animated: true)
        }
    }
    
    
   
    
    
    
    func sendToServer() {
        
        DispatchQueue.global(qos: .userInitiated).async {
        

            let realm = try! Realm()
            
            
            // Get all realm projects
            let realmProjects = realm.objects(ProjectsRealmItem.self)
            
            
            
            // Create json array
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
            
            
            
            var parameters: Parameters = ["projects": JSON(projects)]
            
            if (realmProjects.count == 0 || self.sendNothing) {
                parameters = ["projects": "[]"]
            }
            
            
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
                            
                            
                            if (realmProject.title == "") { realmProject.title = "Namnlös" }
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
                        
                        if (newRealmProject.title == "") { newRealmProject.title = "Namnlös" }
                        
                        try! realm.write {
                            realm.add(newRealmProject)
                        }
                        
                        
                    }
                    
                    
                    
                    // Open id for project to open
                    if (!self.sendNothing) {
                        if self.openPrivateID == responseItem["old_privateID"].string {
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateProjectsStarted"), object: self)
                            self.openPrivateID = responseItem["privateID"].string!
                        }
                    }
                    
                    
                    
                    

                }
                
                
                
            }
            
            
            
            DispatchQueue.main.async {

                NotificationCenter.default.post(name: Notification.Name(rawValue: "updateProjectsStarted"), object: self)
                
                
                if (!self.sendNothing) {
                    
                    let realm = try! Realm()
                    
                    try! realm.write {
                        realm.delete(realm.objects(ProjectsRealmItem.self))
                    }

                    if self.nav == nil {
                        _ = ProjectsSyncOld(openPrivateID: self.openPrivateID, sendNothing: true, nav: UINavigationController.init())
                    } else {
                        _ = ProjectsSyncOld(openPrivateID: self.openPrivateID, sendNothing: true, nav: self.nav!)
                    }
                    
                    
                } else {
                    

                    
                    // Open new project
                    if self.openPrivateID != "" {
                        DispatchQueue.main.async() {
                            let storyboard = UIStoryboard(name: "Editor", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "editor") as! EditorViewController
                            vc.firstPrivateID = self.openPrivateID
                            self.nav?.pushViewController(vc, animated: true)
                        }
                        
                    }
                    

                    
                }
            }
            
           
        }

        
    }
    
    

}
