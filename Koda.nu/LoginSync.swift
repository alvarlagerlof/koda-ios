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

    public func sync() {
        
        
        // Get root ViewController
        var rootViewController = UIApplication.shared.keyWindow?.rootViewController
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        }
        if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController
        }
        
        
        
        if Reachability.isConnectedToNetwork() {
        
            if userValuesStored() {
            
                let parameters = [
                    "email": UserDefaults.standard.value(forKey: Vars.USERDEFAULT_EMAIL) as! String,
                    "password": UserDefaults.standard.value(forKey: Vars.USERDEFAULT_PASSWORD) as! String,
                    "headless": "thisisheadless"
                ]
                
                

                
                Alamofire.request(URL(string: Vars.URL_LOGIN)!, parameters: parameters)
                    .responseString { response in
                        
                        var json = JSON(data: response.result.value!.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers, error: nil)
                        
                        
                        print(response.result.value)

                        
                        if (json["access"].string == "denied") {
                            
                            
                            let alertController = UIAlertController(title: "Ops", message: "Du har loggats ut", preferredStyle: UIAlertControllerStyle.alert)
                            
                            alertController.addAction(UIAlertAction(title: "LOGGA IN", style: UIAlertActionStyle.default) {
                                (result : UIAlertAction) -> Void in
                                
                                let storyboard = UIStoryboard(name: "Login", bundle: nil)
                                let controller = storyboard.instantiateViewController(withIdentifier: "someViewController")
                                rootViewController?.present(controller, animated: true, completion: nil)
                                
                                
                            })
                            
                            
                            rootViewController?.present(alertController, animated: true, completion: nil)
                            
                        }
                        
                }
            
            } else {
            
                let storyboard = UIStoryboard(name: "Login", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "login")
                rootViewController?.present(controller, animated: true, completion: nil)
                
            }
            
            
            
            let projectsSync: ProjectsSync = ProjectsSync()
            projectsSync.sync()

        
        }
    
    
    }
    
    
    
    
    func userValuesStored() -> Bool {
        
        if (UserDefaults.standard.value(forKey: Vars.USERDEFAULT_EMAIL) != nil) {
            return true
        }
        
        return false
    }

    
    
    


}
