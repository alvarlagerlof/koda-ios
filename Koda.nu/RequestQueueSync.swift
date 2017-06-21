//
//  RequestQueueSync.swift
//  Koda.nu
//
//  Created by Alvar Lagerlöf on 4/7/17.
//  Copyright © 2017 Alvar Lagerlöf. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire

public class RequestQueueSync {
    
    var nav: UINavigationController? = nil
    
    
    init() {
        
        if Reachability.isConnectedToNetwork() {
            eatQueue()
        } else {
            _ = ProjectsSync()
        }
        
    }
    
    
    func eatQueue() {
    
        DispatchQueue.global(qos: .userInitiated).async {
        
            
            // Get realm
            let realm = try! Realm()
            
            
            // Get all request in queue
            let requestQueue = realm.objects(RequestQueueItem.self)
            var requestCount = requestQueue.count
            
            
            
            // If no request in the queue,
            // run sync. Else, clear queue
            if requestQueue.count == 0 {
                DispatchQueue.main.async() {
                    _ = ProjectsSync()
                }
                
            } else {
                
                
                
                // Request
                Alamofire.request(requestQueue[0].url, method: .post).responseString { response in
                    
                    
                    if response.result.isSuccess {
                        
                        let realmAlamo = try! Realm()
                        
                        try! realmAlamo.write {
                            realmAlamo.delete(realmAlamo.objects(RequestQueueItem.self).first!)
                        }
                        
                        requestCount -= 1
                        
                        
                        if requestCount > 1 {
                            DispatchQueue.main.async() {
                                self.eatQueue()
                            }
                        } else {
                            DispatchQueue.main.async() {
                                _ = ProjectsSync()
                            }
                        }
                    } else {
                        DispatchQueue.main.async() {
                            _ = ProjectsSync()
                        }
                    }
                    
                    
                   
                    
                
                }
                
            }
            
            
        
        }
    
    }
    
}
