//
//  CommentsViewController.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 10/11/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift
import AVFoundation
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


class CommentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var publicIDString: String = ""
    var listArray = [CommentItem]()

    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var commentTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Init tableView
        self.table.rowHeight = UITableViewAutomaticDimension;
        self.table.estimatedRowHeight = 44.0;
        self.table.isHidden = true
        self.table.tableFooterView = UIView(frame: CGRect.zero)

        
        
        // Get data
        parseJSON()
        
        commentTextField.returnKeyType = UIReturnKeyType.send

        
        NotificationCenter.default.addObserver(self, selector: #selector(CommentsViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(CommentsViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
        
    }
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func parseJSON() {
        let baseURL = URL(string: Vars.URL_COMMENTS + publicIDString)
        
        Alamofire.request(baseURL!, parameters: ["order" : "DESC"])
            .responseString { response in
                
                self.listArray += [CommentItem(
                    type: "header",
                    comment: "",
                    date: "",
                    user: "")]
                
                switch response.result {
                case .success(_:):
                    var readableJSON = JSON(data: response.result.value!.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers, error: nil)
                    
                    
                    if (readableJSON.count != 0) {
                        
                        for i in 0..<readableJSON.count {
                            
                            var comment = readableJSON[i, "comment"].stringValue
                            let date = readableJSON[i, "created"].stringValue
                            var author = readableJSON[i, "author"].stringValue
                            
                            
                            // Base64
                            let decodedComment = Data(base64Encoded: comment, options: NSData.Base64DecodingOptions(rawValue: 0))
                            comment = NSString(data: decodedComment!, encoding: String.Encoding.utf8.rawValue)! as String
                            
                            let decodedAuthor = Data(base64Encoded: author, options: NSData.Base64DecodingOptions(rawValue: 0))
                            author = NSString(data: decodedAuthor!, encoding: String.Encoding.utf8.rawValue)! as String
                            
                            if (author == "") {
                                author = "Anonym"
                            }
                            
                            
                            // Add to list
                            self.listArray.append(CommentItem(
                                type: "normal",
                                comment: comment,
                                date: date,
                                user: author))
                            
                            
                            
                        }
                    } else {
                        // Add to list
                        self.listArray += [CommentItem(
                            type: "noComments",
                            comment: "",
                            date: "",
                            user: "")]
                    }
                    
                    
                    
                    // Reload tableview and stop spinner
                    self.activityIndicator.stopAnimating()
                    self.table.isHidden = false
                    self.table.reloadData()
                    
                    
                    
                    
                case .failure(_:):
                    
                    self.listArray += [CommentItem(
                        type: "offline",
                        comment: "",
                        date: "",
                        user: "")]
                    
                    // Reload tableview and stop spinner
                    self.activityIndicator.stopAnimating()
                    self.table.isHidden = false
                    self.table.reloadData()
                
                    
                }
                
                
        }
        
    }
    
    
    
    // How many sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    // Return int for number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    
    

    // Content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        var cell: UITableViewCell
        
        
        switch listArray[(indexPath.row)].type {
        case "header":
            cell = self.table.dequeueReusableCell(withIdentifier: "commentHeaderCell", for: indexPath) as! CommentHeaderViewCell
            
        case "noComments":
            cell = self.table.dequeueReusableCell(withIdentifier: "cellNoComments", for: indexPath) as! CommentsNoCommentsViewCell
            
        case "offline":
            cell = self.table.dequeueReusableCell(withIdentifier: "cellOffline", for: indexPath) as! CommentsOfflineViewCell
            
        default:
            let cell2 = self.table.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentViewCell
            
            var date = listArray[(indexPath.row)].date
            if (date != "") {
                let nsDate = Date(timeIntervalSince1970: Double(date)!)
                
                let dayTimePeriodFormatter = DateFormatter()
                dayTimePeriodFormatter.dateFormat = "d MMM YYYY, hh:mm"
                
                let dateString = dayTimePeriodFormatter.string(from: nsDate)
                
                date = dateString
            }
            
            cell2.userLabel.text = listArray[(indexPath.row)].user
            cell2.dateLabel.text = date
            cell2.commentLabel.text = listArray[(indexPath.row)].comment
            
            cell = cell2
        }
        
        
        return cell
    }

    
    
    
    @IBAction func primaryActionTriggered(_ sender: UITextField) {
        
        
        commentTextField.resignFirstResponder()
        commentTextField.endEditing(true)
        
        if Reachability.isConnectedToNetwork() {
            let timeStamp = String(Int(round(Date().timeIntervalSince1970)))
            
            for i in 0..<listArray.count {
                if (listArray[i].type == "noComments") {
                    listArray.remove(at: i)
                }
            }
            
            listArray.insert(CommentItem(
                type: "normal",
                comment: commentTextField.text!,
                date: timeStamp,
                user: UserDefaults.standard.string(forKey: Vars.USERDEFAULT_NICK_NAME)!), at: listArray.count)
            
            
            self.table.reloadData()
            
            
            let delay = 0.01 * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                
                let numberOfSections = self.table.numberOfSections
                let numberOfRows = self.table.numberOfRows(inSection: numberOfSections - 1)
                
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: numberOfRows - 1, section: (numberOfSections - 1))
                    self.table.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
                }
                
                
            })
            
            let baseURL = URL(string: Vars.URL_COMMENTS_ADD + publicIDString)
            let parameters = ["comment": commentTextField.text!]
            Alamofire.request(baseURL!, parameters: parameters).response { response in }

            
            
            commentTextField.text = ""
            
        } else {
            let alert = UIAlertController(title: "Kunde inte lägga till kommentren", message: "Gå in i inställnignar och se till att du är online", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        
        
        
    }
    
    
    
    
    // Dissmiss keyboard on scroll
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.commentTextField.endEditing(true)
    }
    
    
    func keyboardWillHide(_ sender: Notification) {
        let userInfo: [AnyHashable: Any] = sender.userInfo!
        let keyboardSize: CGSize = (userInfo[UIKeyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue.size
        self.view.frame.origin.y += keyboardSize.height
    }
    
    
    func keyboardWillShow(_ sender: Notification) {
        let userInfo: [AnyHashable: Any] = sender.userInfo!
        
        let keyboardSize: CGSize = (userInfo[UIKeyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue.size
        let offset: CGSize = (userInfo[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size
        
        if keyboardSize.height == offset.height {
            if self.view.frame.origin.y == 0 {
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.view.frame.origin.y -= keyboardSize.height
                })
            }
        } else {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.view.frame.origin.y += keyboardSize.height - offset.height
            })
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }
    




}
