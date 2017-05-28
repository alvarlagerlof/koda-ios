//
//  ApiViewController.swift
//  Koda.nu
//
//  Created by Alvar Lagerlöf on 19/07/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//


import UIKit
import Alamofire
import SwiftyJSON
import SwiftOverlays
import Firebase


class ApiViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    var currentList = [ApiItem]()
    
    var list2d = [ApiItem]()
    var list3d = [ApiItem]()
    
    enum apiVersion {
        case api2d
        case api3d
    }
    
   

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init
        self.table.rowHeight = UITableViewAutomaticDimension
        self.table.estimatedRowHeight = 140
        self.table.tableFooterView = UIView(frame: CGRect.zero)

        
        // Load first
        getData(list: self.list2d, version: apiVersion.api2d)
        
        
    }
    

    
    
    @IBAction func segmentChange(_ sender: UISegmentedControl) {
        
        table.setContentOffset(CGPoint.zero, animated: false)
        
        switch segmentController.selectedSegmentIndex {
            case 0:
                getData(list: self.list2d, version: apiVersion.api2d)
                Analytics.logEvent("api_tab_2d", parameters: [:])
            case 1:
                getData(list: self.list3d, version: apiVersion.api3d)
                Analytics.logEvent("api_tab_3d", parameters: [:])

            default:
                print("more than two tabs")
            
        }
        
    }
    
    
    
    
    func getData(list: Array<ApiItem>, version: apiVersion) {
        
        // Create tmp list with recived data
        var tmpList = list
        
        
        // If already loaded
        if tmpList.count > 0 && tmpList[0].type != .offline {
            
            // Set to already loaded
            self.currentList = tmpList
            self.table.reloadData()
            
        } else {
            
            // Prepare table
            self.table.isHidden = true
            self.showWaitOverlay()
            
            
            Alamofire.request(URL(string: version == apiVersion.api2d ? Vars.URL_API_2D : Vars.URL_API_3D)!)
                .responseString { response in
                    
                    switch response.result {
                        case .success( _:):
                        
                            for (_, subJson):(String, JSON) in JSON(data: response.result.value!.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers, error: nil) {
                                tmpList += [ApiItem(
                                    type: .normal,
                                    command: subJson["command"].stringValue,
                                    description: subJson["description"].stringValue)]
                            }
                  
                        
                        case .failure( _:):
                            
                            tmpList.removeAll()
                        
                            tmpList += [ApiItem(
                                type: .offline,
                                command: "",
                                description: "")]
                        
                        
                    }
                    
                    
                    // Set to cached list
                    switch version {
                        case .api2d:
                            self.list2d = tmpList
                        case .api3d:
                            self.list3d = tmpList
                    }
                    
                    
                    // Show in table
                    self.currentList = tmpList
                    self.removeAllOverlays()
                    self.table.isHidden = false
                    self.table.reloadData()
                    
                    
            }
            
        }
        
        
    }
    
    
    
    
    
    
    
    
    // Poulate views
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch currentList[indexPath.row].type {
            case .offline:
                return self.table.dequeueReusableCell(withIdentifier: "cellOffline", for: indexPath) as! ApiOfflineViewCell
            
            case .normal:
                let cell = self.table.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ApiViewCell
            
                cell.commandLabel.text = currentList[indexPath.row].command
                cell.descriptionLabel.text = currentList[indexPath.row].description
            
                return cell
            
        }
        
    }

    
    // Default crap
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return currentList.count }
    
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("api")
    }
    
    
    
    
}
