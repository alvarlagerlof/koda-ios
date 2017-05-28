//
//  MyCreationsViewController.swift
//  Koda.nu
//
//  Created by Alvar Lagerlöf on 19/07/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift
import AVFoundation
import SpriteKit
import SwiftOverlays
import Firebase


// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class ProjectsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let realm = try! Realm()
    var listArray = [ProjectsItem]()
    var notificationToken: NotificationToken?

    var shouldWait = true
    
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.showProgress()

        
        // Init tableView
        self.table.rowHeight = UITableViewAutomaticDimension;
        self.table.estimatedRowHeight = 44.0;
        self.table.tableFooterView = UIView(frame: CGRect.zero)
        
        
        // Listen for updates
        NotificationCenter.default.addObserver(self, selector: #selector(ProjectsViewController.showProgress), name: NSNotification.Name(rawValue: "updateProjectsStarted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProjectsViewController.hideProgress), name: NSNotification.Name(rawValue: "updateProjectsDone"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProjectsViewController.loadProjects), name: NSNotification.Name(rawValue: "updateProjectsDoneOffline"), object: nil)

        
        
        
        // Realm updates
        notificationToken = realm.addNotificationBlock { note, realm in
            self.showProgress()
            self.shouldWait = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.loadProjects()
            }
        }
        
        
        // If offline, sync won't do anything
        // and it will be done before the view is loaded
        if !Reachability.isConnectedToNetwork() {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateProjectsDone"), object: self)
        }
        
    }

    

    

    func loadProjects() {
        
        
        if shouldWait == false {
            
            self.showProgress()
            
            // Remove all
            self.listArray.removeAll()
            
            
            // Header
            self.listArray.append(ProjectsItem(type: "header", privateID: "", publicID: "", title: "", description: "", updated: "", isPublic: false))
            
            
            // Content
            let objects = realm.objects(ProjectsRealmItem.self).sorted(byKeyPath: "updatedRealm", ascending: false)
            
            
            if (objects.count == 0) {
                self.listArray.append(ProjectsItem(
                    type: "noProjects",
                    privateID: "",
                    publicID: "",
                    title: "",
                    description: "",
                    updated: "",
                    isPublic: false))
                Analytics.logEvent("projects_no_projects", parameters: [:])
                
            } else {
                for i in 0..<objects.count {
                    
                    self.listArray.append(ProjectsItem(
                        type: "normal",
                        privateID: objects[i].privateID,
                        publicID: objects[i].publicID,
                        title: objects[i].title,
                        description: objects[i].descriptionText,
                        updated: objects[i].updatedRealm,
                        isPublic: objects[i].isPublic))
                }
            }
            
            if table != nil {
                self.table.reloadData()
                self.removeAllOverlays()
            }
            
            let indexPath = IndexPath(row: 0, section: 0)
            self.table.scrollToRow(at: indexPath, at: .top, animated: true)
            
        }
        
    }

    
    
    
    
    // Content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        
        switch listArray[indexPath.row].type {
            case "header":
                let cell2 = self.table.dequeueReusableCell(withIdentifier: "cellNew", for: indexPath) as! ProjectsNewViewCell
                cell2.newButton.addTarget(self, action: #selector(createNew(_:)), for:.touchUpInside)
                cell = cell2
            
            case "noProjects":
                cell = self.table.dequeueReusableCell(withIdentifier: "cellNoProjects", for: indexPath) as! ProjectsNoProjectsViewCell
            
            default:
                let cell2 = self.table.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProjectsViewCell
            
                cell2.titleLabel.text = listArray[(indexPath.row)].title
                cell2.dateLabel.text = DateHelper().timeStampToDate(timeStamp: listArray[(indexPath.row)].updated)
            
                if indexPath.row != 0 {
                    cell2.moreButton.tag = indexPath.row
                    cell2.moreButton.addTarget(self, action: #selector(showActionSheet(_:)), for: UIControlEvents.touchUpInside)
                }
                
            
                cell = cell2
        }
        
        return cell
    }
    
    
    
    // Selecting an item
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        Analytics.logEvent("projects_selct_item", parameters: [:])
        
        table.deselectRow(at: indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: "Editor", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "editor") as! EditorViewController
        vc.privateID = self.listArray[indexPath.row].privateID
        
        navigationController?.pushViewController(vc, animated: true)
        

    }
    
    
 
    

    // More button
    func showActionSheet(_ sender: UIButton) {
        _ = ProjectsMoreActionSheet(sender: sender, privateID: self.listArray[sender.tag].privateID, nav: (navigationController)!)
        Analytics.logEvent("projects_selct_item", parameters: [:])
    }
    
    
    // New project
    func createNew(_ sender: UIButton) {
        _ = ProjectsNew(nav: navigationController!)
        Analytics.logEvent("projects_create_new", parameters: [:])
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    
    
    
    
    // # of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    // # of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    
    
    
    func showProgress() {
        self.showWaitOverlay()
    }
    
    func hideProgress() {
        self.removeAllOverlays()
    }
    
    deinit{
        if let notificationToken = notificationToken{
            notificationToken.stop()
        }
    }
    
    
}
