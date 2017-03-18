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

class ApiViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var listArray = [ApiItem]()

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var activityIndicatior: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parseJSON(Vars.URL_API_2D)
        
        self.table.rowHeight = UITableViewAutomaticDimension
        self.table.estimatedRowHeight = 140
        self.table.tableFooterView = UIView(frame: CGRect.zero)

        
        
    }
    
    // Default crap
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return listArray.count }
    
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    
    // Poulate views
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        
        if (listArray[indexPath.row].type == "offline") {
            
            cell = self.table.dequeueReusableCell(withIdentifier: "cellOffline", for: indexPath) as! ApiOfflineViewCell
            
        } else {
            
            let cell2 = self.table.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ApiViewCell
            
            cell2.commandLabel.text = listArray[indexPath.row].command
            cell2.descriptionLabel.text = listArray[indexPath.row].description
            
            cell = cell2
            
        }
        
        return cell
    }
    
    
    
    func parseJSON(_ url: String) {
        let baseURL = URL(string: url)
        
        listArray.removeAll()
        
        self.table.isHidden = true
        self.activityIndicatior.startAnimating()
        
        Alamofire.request(baseURL!)
            .responseString { response in
                
                switch response.result {
                case .success( _:):
                    
                    var readableJSON = JSON(data: response.result.value!.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers, error: nil)
                    
                    for i in 0..<readableJSON.count {
                                        
                        // Add to list
                        self.listArray += [ApiItem(
                            type: "normal",
                            command: readableJSON[i, "command"].stringValue,
                            description: readableJSON[i, "description"].stringValue)]
                        
                    }
                    
                    // Reload tableview and stop spinner
                    self.activityIndicatior.stopAnimating()
                    self.table.isHidden = false
                    self.table.reloadData()
                    
                    
                case .failure( _:):
                    
                    // Add to list
                    self.listArray += [ApiItem(
                        type: "offline",
                        command: "",
                        description: "")]
                    
                    
                    self.activityIndicatior.stopAnimating()
                    self.table.isHidden = false
                    self.table.reloadData()
                    
                    
                }

                
        
        }
        
    }

    
    @IBAction func segmentChange(_ sender: UISegmentedControl) {
        
        table.setContentOffset(CGPoint.zero, animated: false)
        
        if (segmentController.selectedSegmentIndex == 0) {
            parseJSON(Vars.URL_API_2D)
        } else {
            parseJSON(Vars.URL_API_3D)
        }
    }

    
    
}
