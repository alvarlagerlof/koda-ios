//
//  RemoteConfigSync.swift
//  Koda.nu
//
//  Created by Alvar Lagerlöf on 4/5/17.
//  Copyright © 2017 Alvar Lagerlöf. All rights reserved.
//

import Foundation
import Firebase
import FirebaseRemoteConfig

public class RemoteConfigSync {

    var remoteConfig: RemoteConfig
    
    init() {
        
        remoteConfig = RemoteConfig.remoteConfig()

        
        let remoteConfigSettings = RemoteConfigSettings(developerModeEnabled: false)
        remoteConfig.configSettings = remoteConfigSettings!
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        
        remoteConfig.fetch(withExpirationDuration: TimeInterval(60)) { (status, error) -> Void in
            if status == .success {
                
                print("Config fetched!")
                
                self.remoteConfig.activateFetched()

                
                if Vars.KILLSWITCH_ON {
                    self.showKillswitch(didNotFetch: false)
                } else {
                    _ = LoginSync()
                }
                
                
                
            } else {
                print("Config not fetched")
                print("Error \(error!.localizedDescription)")
                
                self.showKillswitch(didNotFetch: true)
                
                
            }
        }
    }
    
    
    
    
    
    func showKillswitch(didNotFetch: Bool) {
        let storyboard = UIStoryboard(name: "Killswitch", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "killswitch") as! KillswitchViewController
        vc.didNotFetch = didNotFetch
        ViewHelper().getRoot().present(vc, animated: true, completion: nil)
    }
    

}
