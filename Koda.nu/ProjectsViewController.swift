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
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let refreshControl = UIRefreshControl()
    
    var listArray = [ProjectsItem]()
    
    var currentRow = 0
    var currentUrl = ""
    var currentPublicIDComments = ""
    
    var currentNewTitle = ""
    var currentNewPublicID = ""
    var currentNewPrivateID = ""
    
    
    var isFirstTimeVisible = true
    
    var notificationToken: NotificationToken?

    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        // TODO: LoginSync        
        let loginSync: LoginSync = LoginSync()
        loginSync.sync()

        
        let projectsSync: ProjectsSync = ProjectsSync()
        projectsSync.sync()
        
        
        // Init tableView
        self.table.rowHeight = UITableViewAutomaticDimension;
        self.table.estimatedRowHeight = 44.0;
        self.table.tableFooterView = UIView(frame: CGRect.zero)
        
        
        
        // Get projects
        showProjects()
        
        
        // Listen for chages in Realm
        let realm = try! Realm()
        notificationToken = realm.addNotificationBlock { note, realm in
            self.showProjects()
        }
        
        
    }
    

    func showProjects() {
        
        self.listArray.removeAll()
    
        // Header
        self.listArray.append(ProjectsItem(
            type: "header",
            privateID: "",
            publicID: "",
            title: "",
            description: "",
            updated: "",
            isPublic: false))
        
        
        // Contenet
        let objects = try! Realm().objects(ProjectsRealmItem.self).sorted(byKeyPath: "updated", ascending: false)
        
        if (objects.count == 0) {
            self.listArray.append(ProjectsItem(
                type: "noProjects",
                privateID: "",
                publicID: "",
                title: "",
                description: "",
                updated: "",
                isPublic: false))
        } else {
            for i in 0..<objects.count {
                
                self.listArray.append(ProjectsItem(
                    type: "normal",
                    privateID: objects[i].privateID,
                    publicID: objects[i].publicID,
                    title: objects[i].title,
                    description: objects[i].descriptionText,
                    updated: objects[i].updated,
                    isPublic: objects[i].isPublic))
            }
        }

        self.table.reloadData()
        
    }

    
    
    
    // How many sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    // Return int how many rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
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
            
            var updated = listArray[(indexPath.row)].updated
            
            // Fix date
            if (updated != "") {
                if (Double(updated) != nil) {
                    let date = Date(timeIntervalSince1970: Double(updated)!)
                    let dayTimePeriodFormatter = DateFormatter()
                    dayTimePeriodFormatter.dateFormat = "d MMM YYYY, hh:mm"
                    let dateString = dayTimePeriodFormatter.string(from: date)
                    updated = dateString
                }
            }
            
            cell2.titleLabel.text = listArray[(indexPath.row)].title
            cell2.dateLabel.text = updated
            
            
            
            cell2.moreButton.tag = Int(listArray[(indexPath.row)].privateID)!
            cell2.moreButton.addTarget(self, action: #selector(showActionSheet(_:)), for: UIControlEvents.touchUpInside)
            
            cell = cell2
        }
        
        
        return cell
    }
    
    
    // Selecting an item
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showEditor", sender: self)
    }
    
    
    // Set segue data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "showEditor"?:
            let nextViewController = (segue.destination as! EditorViewController)
            
            let indexPath = self.table.indexPathForSelectedRow
            
            if (indexPath == nil) {
                nextViewController.titleString = currentNewTitle
                nextViewController.privateIDString = currentNewPrivateID
                nextViewController.publicIDString = currentNewPublicID
                
            } else {
                let titleString = listArray[(indexPath!.row)].title
                let privateIDString = listArray[(indexPath!.row)].privateID
                let publicIDString = listArray[(indexPath!.row)].publicID
                
                nextViewController.titleString = titleString
                nextViewController.privateIDString = privateIDString
                nextViewController.publicIDString = publicIDString
                
                self.table.deselectRow(at: indexPath!, animated: true)
            }
            
           

        case "showQRViewer"?:
            let nextViewController = (segue.destination as! QRViewerViewController)
            nextViewController.recivedUrl = "http://koda.nu/arkivet/" + self.listArray[self.currentRow].publicID
            
        case "showComments"?:
            let nextViewController = (segue.destination as! CommentsViewController)
            nextViewController.publicIDString = self.listArray[self.currentRow].publicID
            
        default:
            print("none")
        }
        
        
    }
    

    // More button
    func showActionSheet(_ sender: UIButton) {
        
        let currentPrivateID = sender.tag
        
        // 1
        let optionMenu: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
        
        // Share
        let shareAction = UIAlertAction(title: "Dela", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            let message = "Kolla in \(self.listArray[self.currentRow].title) på Koda.nu! http://koda.nu/arkivet/\(self.listArray[self.currentRow].publicID)"
            
            let vc = UIActivityViewController(activityItems: [message], applicationActivities: nil)
            self.present(vc, animated: true, completion: nil)

        })
        
        // QR share
        let qrShareAction = UIAlertAction(title: "Dela QR kod", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "showQRViewer", sender: self)
        })
        
        /*// Comments
        let commentsAction = UIAlertAction(title: "Visa kommentarer", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "showComments", sender: self)
        })*/
        
        
        // Edit
        let editAction = UIAlertAction(title: "Redigera info", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        
        // Delete
        let deleteAction = UIAlertAction(title: "Ta bort", style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            let deleteAlert = UIAlertController(title: "Ta bort \(self.listArray[self.currentRow].title)?", message: "Du kan inte ångra denna operation", preferredStyle: UIAlertControllerStyle.alert)
            
            deleteAlert.addAction(UIAlertAction(title: "Ta bort", style: .destructive, handler: { (action: UIAlertAction!) in
                
                Alamofire.request(URL(string: Vars.URL_PROJECTS_DELETE + self.listArray[self.currentRow].privateID)!).response { response in }
            
            
                let realm = try! Realm()
                let object = realm.objects(ProjectsRealmItem.self).filter("privateID = '\(self.listArray[self.currentRow].privateID)'").first
                try! realm.write {
                    realm.delete(object!)
                }


            }))
            
            deleteAlert.addAction(UIAlertAction(title: "Avbryt", style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            
            self.present(deleteAlert, animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Avbryt", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        
        // 4
        optionMenu.addAction(shareAction)
        optionMenu.addAction(qrShareAction)
        //optionMenu.addAction(commentsAction)
        optionMenu.addAction(editAction)
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        optionMenu.popoverPresentationController?.sourceView = sender
        self.present(optionMenu, animated: true, completion: nil)
        
        
    }
    
    
    func createNew(_ sender: UIButton) {
        
        
        let addAlert = UIAlertController(title: "Vad ska den heta?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        addAlert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Titel"
        })
        
        addAlert.addAction(UIAlertAction(title: "Skapa", style: .default, handler: { (action: UIAlertAction!) in
            
            var title: String
            
            if !addAlert.textFields![0].text!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {
                title = addAlert.textFields![0].text!
            } else {
                title = "Namnlös"
            }
            
            Alamofire.request(URL(string: Vars.URL_PROJECTS_CREATE_NEW)!,parameters: ["title": title])
                .responseString { response in
                    
                    let realm = try! Realm()
                    
                    switch response.result {
                    case .success( _:):
                        
                        let updated = String(Int(round(Date().timeIntervalSince1970)))
                        
                        var readableJSON = JSON(data: response.result.value!.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers, error: nil)
                        
                        
                        let object = ProjectsRealmItem()
                        object.privateID = readableJSON["privateID"].stringValue
                        object.publicID = readableJSON["publicID"].stringValue
                        object.title = title
                        object.descriptionText = ""
                        object.updated = updated
                        object.isPublic = false
                        object.code = String("<script src=\"http://koda.nu/simple.js\">\n\n  circle(100, 100, 20, \"red\");\n\n</script>")
                        
                        try! realm.write {
                            realm.add(object)
                        }
                        
                        self.currentNewTitle = title
                        self.currentNewPrivateID = readableJSON["privateID"].stringValue
                        self.currentNewPublicID = readableJSON["publicID"].stringValue

                        self.performSegue(withIdentifier: "showEditor", sender: self)
                        
                    case .failure( _:):
                        
                        let updated = String(Int(round(Date().timeIntervalSince1970)))
                        
                        
                        let object = ProjectsRealmItem()
                        object.privateID = "offline_" + updated
                        object.publicID = "offline_" + updated
                        object.title = title
                        object.descriptionText = ""
                        object.updated = updated
                        object.isPublic = false
                        object.code = String("<script src=\"http://koda.nu/simple.js\">\n\n  circle(100, 100, 20, \"red\");\n\n</script>")
                        
                        try! realm.write {
                            realm.add(object)
                        }
                        
                        self.currentNewTitle = title
                        self.currentNewPrivateID = "offline_" + updated
                        self.currentNewPublicID = "offline_" + updated
                        
                        self.performSegue(withIdentifier: "showEditor", sender: self)

                        
                    }
                    
            }
            
        }))
        
        addAlert.addAction(UIAlertAction(title: "Avbryt", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        
        self.present(addAlert, animated: true, completion: nil)

        
        
        
    }

    
    deinit{
        if let notificationToken = notificationToken{
            notificationToken.stop()
        }
    }
    

    
}
