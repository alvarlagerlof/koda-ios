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

public class ProjectsSync {

    let realm = try! Realm()

    
    public func sync() {
        
        print("Sync")
        
        // If connected to internet
        if (Reachability.isConnectedToNetwork()) {
            
            Alamofire.request(URL(string: Vars.URL_PROJECTS)!)
                .responseString { response in
                    
                    print(response.result.value)

                    if response.result.isSuccess {
                        
                        
                        // Response to json
                        var response = JSON(data: response.result.value!.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers, error: nil)
                        
                        
                        // Update nick name
                        var nickName = response["user", "nick"].stringValue
                        if (nickName != "") {
                            let decodedNickName = Data(base64Encoded: nickName, options: NSData.Base64DecodingOptions(rawValue: 0))
                            nickName = NSString(data: decodedNickName!, encoding: String.Encoding.utf8.rawValue) as! String
                            UserDefaults.standard.set(nickName, forKey: Vars.USERDEFAULT_NICK_NAME)
                        }
                        
                        
                        print(nickName)
                        
                        
                        
                        
                        
                        // Create a lists with server and realm projects
                        var serverProjects: JSON = response["games"]
                        let realmProjects = self.realm.objects(ProjectsRealmItem.self)
                        
                        
                        
                        // Loop over server projects
                        for i in 0..<serverProjects.count {
                            
                            let serverProject = serverProjects[i]
                            let realmProject = self.realm.objects(ProjectsRealmItem.self)
                                .filter("privateID = '\(serverProject["privateID"].stringValue)'")
                                .first


                            if (realmProject != nil) {
                                
                                // If it does exist on the server
                                self.updateOldest(realmProject: realmProject!, serverProject: serverProject)
                                
                            } else {
                            
                                // If it does NOT exist on realm
                                let object = ProjectsRealmItem()
                                object.privateID = serverProject["privateID"].stringValue
                                object.publicID = serverProject["publicID"].stringValue
                                object.title = Base64Helper.decode(encoded: serverProject["title"].stringValue)
                                object.descriptionText = Base64Helper.decode(encoded: serverProject["description"].stringValue)
                                object.updated = serverProject["updated"].stringValue
                                object.code = Base64Helper.decode(encoded: serverProject["code"].stringValue)
                                
                                object.title = object.title == "" ? "Namnlös" : object.title
                                
                                
                                try! self.realm.write {
                                    self.realm.add(object)
                                }
                                
                            }

                            
                            
                        }
                        
                        
                        
                        // Loop over realm projects
                        for e in 0..<realmProjects.count {

                            let realmProject: ProjectsRealmItem = realmProjects[e]
                            let serverProject = self.getJsonObjectByPrivateId(serverProjects: [serverProjects], privateID: realmProject.privateID)
                            
                            
                            if (serverProject != JSON.null) {
                            
                                // If it does exist on the server
                                self.updateOldest(realmProject: realmProject, serverProject: serverProject)
                                
                            } else {
                                
                                // If it does not exist on the serer
                                
                                // TODO: UPLOAD TO SERVER
                                
                                
                            }
                        
                        }
                        
                        
                    }
        
            }
        }
    }
    
    
    
    
    func updateOldest(realmProject: ProjectsRealmItem, serverProject: JSON) {
    
        let realmUpdatedInt = Int(realmProject.updated)
        let serverUpdatedInt = Int(serverProject["updated"].stringValue)
        
        
        
        // If latest updated on realm
        if (realmUpdatedInt! > serverUpdatedInt!) {
        
            if (Reachability.isConnectedToNetwork()) {
                
                DispatchQueue.global(qos: .userInitiated).async {
                    
                    // Save code
                    Alamofire.request(Vars.URL_EDITOR_SAVE + realmProject.privateID, parameters: ["code": realmProject.code]).response { response in }
                    
                    
                    // Save meteadata
                    let parameters = ["title": realmProject.title,
                                      "description": realmProject.description,
                                      "author": "",
                                      "publicOrNot": realmProject.isPublic ? "CHECKED" : ""]
                    
                    
                    Alamofire.request(Vars.URL_PROJECTS_EDIT + realmProject.privateID, parameters: parameters).response { response in }
                    
                }
        
        }
            
            
        
        // If latest updated on the server
        if (serverUpdatedInt! > realmUpdatedInt!) {
            
            try! realm.write {
                realmProject.privateID = serverProject["privateID"].stringValue
                realmProject.publicID = serverProject["publicID"].stringValue
                realmProject.title = Base64Helper.decode(encoded: serverProject["title"].stringValue)
                realmProject.descriptionText = Base64Helper.decode(encoded: serverProject["description"].stringValue)
                realmProject.updated = serverProject["updated"].stringValue
                realmProject.code = Base64Helper.decode(encoded: serverProject["code"].stringValue)
                
                realmProject.title = realmProject.title == "" ? "Namnlös" : realmProject.title
            }
        
        }
        
    
        }
        
        
    }
    
    
    
    
    
    
        
    
    func getJsonObjectByPrivateId(serverProjects: Array<JSON>, privateID: String) -> JSON {
    
        for i in 0..<serverProjects.count {
            
            if serverProjects[i]["privateID"].stringValue == privateID {
                return serverProjects[i]["privateID"]
            }
        
        }
        
        return JSON.null
        
    }
    
    
    

}
