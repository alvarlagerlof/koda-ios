//
//  ProjectsMoreActionSheet.swift
//  Koda.nu
//
//  Created by Alvar Lagerlöf on 4/5/17.
//  Copyright © 2017 Alvar Lagerlöf. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Alamofire
import Firebase


public class ProjectsMoreActionSheet {
    
    
    init(sender: UIButton, privateID: String, nav: UINavigationController) {
        

        // Get realm object
        let realm = try! Realm()
        let project = realm.objects(ProjectsRealmItem.self).filter("privateID = '\(privateID)'").first
        
        
        
        // Create action sheet
        let optionMenu: UIAlertController = UIAlertController(title: project?.title, message: nil, preferredStyle: .actionSheet)
        
        
        // Share
        optionMenu.addAction(UIAlertAction(title: "Dela via app", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            Analytics.logEvent("projects_more_share_normal", parameters: [:])

            let message = "Kolla in " + (project?.title)! + " på Koda.nu! http://koda.nu/arkivet/" + (project?.publicID)!
            
            let vc = UIActivityViewController(activityItems: [message], applicationActivities: nil)
            ViewHelper().getRoot().present(vc, animated: true, completion: nil)
            
        }))
        
    
        // QR share
        optionMenu.addAction(UIAlertAction(title: "Dela via QR kod", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            Analytics.logEvent("projects_more_share_qr", parameters: [:])

            
            let storyboard = UIStoryboard(name: "QRViewer", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "QRViewer") as! QRViewerViewController
            
            vc.recivedUrl = "http://koda.nu/arkivet/" + (project?.publicID)!
            vc.recivedTitle = (project?.title)!

            
            nav.pushViewController(vc, animated: true)
            
            
        }))
        
        
        
        // Edit
        optionMenu.addAction(UIAlertAction(title: "Redigera info", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            Analytics.logEvent("projects_more_edit", parameters: [:])

            
            let vc = EditInfoViewController()
            vc.hidesBottomBarWhenPushed = true
            vc.privateID = privateID
            
            nav.pushViewController(vc, animated: true)
            
        }))
        
        
        // Delete
        optionMenu.addAction(UIAlertAction(title: "Ta bort", style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            
            Analytics.logEvent("projects_more_delete", parameters: [:])

            
            if project != nil {
                // Alert
                let deleteAlert = UIAlertController(title: "Ta bort \"" + (project?.title)! + "\"", message: "Du kan inte ångra denna operation", preferredStyle: UIAlertControllerStyle.alert)
                
                
                // Delete action
                deleteAlert.addAction(UIAlertAction(title: "Ta bort", style: .destructive, handler: { (action: UIAlertAction!) in
                    
                    Analytics.logEvent("projects_more_delete_successful", parameters: [:])
                    
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateProjectsStarted"), object: self)
                    
                    _ = RequestQueueAdd(url: Vars.URL_PROJECTS_DELETE + (project?.privateID)! )
                    
                    try! realm.write {
                        realm.delete(project!)
                    }
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateProjectsDone"), object: self)
                    
                }))
                
                
                // Cancel action
                deleteAlert.addAction(UIAlertAction(title: "Stäng", style: .cancel, handler: { (action: UIAlertAction!) in
                    Analytics.logEvent("projects_more_delete_canceled", parameters: [:])
                }))
                
                // Show
                ViewHelper().getRoot().present(deleteAlert, animated: true, completion: nil)
            }
            
            
        }))
        
        
        // Cancel
        optionMenu.addAction(UIAlertAction(title: "Avbryt", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            Analytics.logEvent("projects_more_cancel", parameters: [:])
        }))
        
        

        
        // Show
        optionMenu.popoverPresentationController?.sourceView = sender
        ViewHelper().getRoot().present(optionMenu, animated: true, completion: nil)
        
        
    }
    
}


// Add later


/*
 
 // Comments
 let commentsAction = UIAlertAction(title: "Visa kommentarer", style: .default, handler: {
 (alert: UIAlertAction!) -> Void in
 self.performSegue(withIdentifier: "showComments", sender: self)
 })


 //optionMenu.addAction(commentsAction)
 
*/
