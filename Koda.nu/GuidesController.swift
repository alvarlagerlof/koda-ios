//
//  GuidesYoutubeCollectionView.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 09/11/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher


// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
/*fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}*/


class GuidesController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var listArray: [Any] = []
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Guider"
        
        table.separatorStyle = UITableViewCellSeparatorStyle.none
        
    
        
        // Check if logged in
        /*if (Alamofire.HTTPCookieStorage.getCookiesFor(HTTPCookieStorage) < 1) {
            print("No cookies, login needed")
            self.performSegue(withIdentifier: "showLogin", sender: self)
        } else {
            print("Cookies, login not needed")
        }*/
        
        
        // Init tableView
        self.table.rowHeight = UITableViewAutomaticDimension;
        self.table.estimatedRowHeight = 44.0;
        self.table.isHidden = false
        self.table.tableFooterView = UIView(frame: CGRect.zero)
        
        parseJSON()
        
        
    }
    
    
    
    
    func parseJSON() {
        
        Alamofire.request(URL(string: Vars.URL_GUIDES)!)
            .responseString { response in
                
                
                switch response.result {
                case .success(_:):
                    var readableJSON = JSON(data: response.result.value!.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers, error: nil)
                    
                    print(String(readableJSON["items"].count) + " items")
                    
                    if (readableJSON["items"].count != 0) {
                        for i in 0..<readableJSON["items"].count {
                                                        
                            switch readableJSON["items", i, "type"] {
                            case "line":
                                self.listArray.append(GuidesLineItem(height: 2))
                                
                            case "text":
                                self.listArray.append(GuidesTextItem(text: readableJSON["items", i, "content", "text"].stringValue))
                                
                            case "textWithTitle":
                                self.listArray.append(GuidesTextWithTitleItem(title: readableJSON["items", i, "content", "title"].stringValue, text: readableJSON["items", i, "content", "text"].stringValue))
                                
                            case "image":
                                self.listArray.append(GuidesImageItem(imageUrl: readableJSON["items", i, "content", "imageUrl"].stringValue, link: readableJSON["items", i, "content", "link"].stringValue))
                                
                                
                            default:
                                print("not added this yet, " + readableJSON["items", i, "type"].stringValue)
                            }
                            
                            
                        }
                        
                    } else {
                        // Fix if no items
                        
                    }
                
                    
                case .failure(_:):
                    // Fix offfline
                    print("offline!")
                    
                    
                }
                
                
                // Reload tableview and stop spinner
                self.activityIndicator.stopAnimating()
                self.table.isHidden = false
                self.table.reloadData()
                
                
        }
        
    }
    
    
    // Number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    // Return int for number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    
    
    // Content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch listArray[(indexPath.row)] {
        case is GuidesLineItem:
            return self.table.dequeueReusableCell(withIdentifier: "line", for: indexPath) as! GuidesLineCell
            
        case is GuidesTextItem:
            let cell: GuidesTextCell = self.table.dequeueReusableCell(withIdentifier: "text", for: indexPath) as! GuidesTextCell
            let item = listArray[(indexPath.row)] as! GuidesTextItem
            
            cell.textLabelView.text = item.text
            
            return cell
            
        case is GuidesTextWithTitleItem:
            let cell: GuidesTextWithTitleCell = self.table.dequeueReusableCell(withIdentifier: "textWithTitle", for: indexPath) as! GuidesTextWithTitleCell
            let item = listArray[(indexPath.row)] as! GuidesTextWithTitleItem
            
            cell.titleLabelView.text = item.title
            cell.textLabelView.text = item.text
            
            return cell

        case is GuidesImageItem:
            let cell: GuidesImageCell = self.table.dequeueReusableCell(withIdentifier: "image", for: indexPath) as! GuidesImageCell
            let item = listArray[(indexPath.row)] as! GuidesImageItem
            
            
            cell.bigImage.kf.setImage(with: URL(string: item.imageUrl),
                                      placeholder: nil,
                                      options: [.transition(.fade(0.3))],
                                      completionHandler: { image, error, cacheType, imageURL in
                                        self.table.beginUpdates()
                                        self.table.reloadRows(at: [indexPath], with: .none)
                                        self.table.endUpdates()
                                    })
            
            
            return cell
            
        default:
            print("no type")
        }
        
        return UITableViewCell()
        
    }

    
    
    
    
    
    
        
    
}
