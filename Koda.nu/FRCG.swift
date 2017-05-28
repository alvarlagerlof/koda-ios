//
//  RemoteConfigGet.swift
//  Koda.nu
//
//  Created by Alvar Lagerlöf on 4/5/17.
//  Copyright © 2017 Alvar Lagerlöf. All rights reserved.
//

import Foundation
import Firebase
import FirebaseRemoteConfig


public class FRCG {


    func getS(name: String) -> String {
                
        return RemoteConfig.remoteConfig()[name].stringValue!
        
    }
    
    func getB(name: String) -> Bool {
        
        return RemoteConfig.remoteConfig()[name].boolValue
        
    }


}
