//
//  ViewHelper.swift
//  Koda.nu
//
//  Created by Alvar Lagerlöf on 4/5/17.
//  Copyright © 2017 Alvar Lagerlöf. All rights reserved.
//

import Foundation
import UIKit

public class ViewHelper {
    
    
    func getRoot() -> UIViewController {
        
        var rootViewController = (UIApplication.shared.keyWindow?.rootViewController)!
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first!
        }
        if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController!
        }
        
        
        return rootViewController
        
    }
    
    
}
