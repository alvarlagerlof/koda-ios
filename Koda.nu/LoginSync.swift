//
//  LoginSync.swift
//  Koda.nu
//
//  Created by Alvar Lagerlöf on 2/16/17.
//  Copyright © 2017 Alvar Lagerlöf. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public class LoginSync {

    
    init() {
        
        // If connected to internet
        if Reachability.isConnectedToNetwork() {
        
            // Get status
            Alamofire.request(URL(string: Vars.URL_LOGIN_STAUS)!).responseString { response in
                
                if response.result.isSuccess {
                    let json = JSON(data: response.result.value!.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers, error: nil)
                    
                    if json["logged_in"].boolValue {
                        _ = RequestQueueSync()
                    } else {
                        self.login()
                    }

                } else {
                    _ = RequestQueueSync()
                }
                
            }
    
        } else {
            _ = RequestQueueSync()
        }
    
    }
    
    

    func login() {
        
        if userValuesStored() {
            
            
            // Set up parameters
            let parameters = [
                "email": UserDefaults.standard.value(forKey: Vars.USERDEFAULT_EMAIL) as! String,
                "password": UserDefaults.standard.value(forKey: Vars.USERDEFAULT_PASSWORD) as! String,
                "headless": "thisisheadless"
            ]
            
            
            // Request
            if Reachability.isConnectedToNetwork() {
                Alamofire.request(URL(string: Vars.URL_LOGIN)!, method: .post, parameters: parameters)
                    .responseString { response in
                        
                        if response.result.isSuccess {
                            // Response to json
                            var json = JSON(data: response.result.value!.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers, error: nil)
                            
                            
                            if (json["access"].string == "denied") {
                                
                                // Access denied, open login view-controller
                                
                                let storyboard = UIStoryboard(name: "Login", bundle: nil)
                                let controller = storyboard.instantiateViewController(withIdentifier: "login")
                                ViewHelper().getRoot().present(controller, animated: true, completion: nil)
                                
                            } else {
                                
                                // Login succeded
                                _ = RequestQueueSync()
                                
                            }
                            
                        } else {
                            _ = RequestQueueSync()
                        }
                        
                }
            } else {
                _ = RequestQueueSync()
            }
            
           
            
        } else {
            
            // No user values are stored, open login view-controller

            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "login")
            ViewHelper().getRoot().present(controller, animated: true, completion: nil)

        }
        
        
        
    }
    
    
    func userValuesStored() -> Bool {
        
        if (UserDefaults.standard.value(forKey: Vars.USERDEFAULT_EMAIL) != nil) {
            return true
        }
        
        return false
    }

    
    
    


}
