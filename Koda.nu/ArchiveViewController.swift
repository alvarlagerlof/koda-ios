 //
//  ArchiveViewController.swift
//  Koda.nu
//
//  Created by Alvar Lagerlöf on 19/07/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ArchiveViewController: UIViewController, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    var resultSearchController = UISearchController()
    
    var listArray = [ArchiveItem]()
    var listArrayFiltered = [ArchiveItem]()
    var titleArray = [String]()
    
    
    var currentPublicIDComments = "";

    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var activityIndicatior: UIActivityIndicatorView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.table.isHidden = true
        
        parseJSON()
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.searchResultsUpdater = self
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.hidesNavigationBarDuringPresentation = false
        self.resultSearchController.searchBar.sizeToFit()
        self.resultSearchController.searchBar.delegate = self
        self.resultSearchController.searchBar.setValue("Avbryt", forKey:"_cancelButtonText")
        self.resultSearchController.searchBar.placeholder = "Sök"

        
        self.navigationItem.titleView = resultSearchController.searchBar
        
        
        
        self.table.rowHeight = UITableViewAutomaticDimension;
        self.table.estimatedRowHeight = 90.0;
        self.table.tableFooterView = UIView(frame: CGRect.zero)

        
        self.table.delegate = self;

        self.table.reloadData()
        
        
    }
    

    

    func parseJSON() {
        let baseURL = URL(string: Vars.URL_ARCHIVE)
        
        Alamofire.request(baseURL!)
            .responseString { response in
                
                switch response.result {
                case .success(_:):
                    
                    var readableJSON = JSON(data: response.result.value!.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers, error: nil)
                    
                    for i in 0...readableJSON.count {
                        
                        let publicID = readableJSON[i, "publicID"].stringValue
                        
                        var title = readableJSON[i, "title"].stringValue
                        var author = readableJSON[i, "author"].stringValue
                        let updated = readableJSON[i, "updated"].stringValue
                        var description = readableJSON[i, "description"].stringValue
                        
                        let like_count = readableJSON[i, "likes"].stringValue
                        let comment_count = readableJSON[i, "comments"].stringValue
                        let char_count = readableJSON[i, "charcount"].stringValue
                        
                        let liked = readableJSON[i, "liked"].boolValue
                        let isAuthor = readableJSON[i, "isAuthor"].boolValue
                        
                        
                        
                        
                        // Base64
                        let decodedTitle = Data(base64Encoded: title, options: NSData.Base64DecodingOptions(rawValue: 0))
                        title = NSString(data: decodedTitle!, encoding: String.Encoding.utf8.rawValue)! as String
                        
                        let decodedAuthor = Data(base64Encoded: author, options: NSData.Base64DecodingOptions(rawValue: 0))
                        author = NSString(data: decodedAuthor!, encoding: String.Encoding.utf8.rawValue)! as String
                        
                        let decodedDescription = Data(base64Encoded: description, options: NSData.Base64DecodingOptions(rawValue: 0))
                        description = NSString(data: decodedDescription!, encoding: String.Encoding.utf8.rawValue)! as String
                        
                        
                        // If null value
                        if (title == "") {
                            title = "Namnlös"
                        }
                        
                        if (author == "") {
                            author = "Anonym"
                        }
                        
                        
                        // Add to list
                        self.listArray += [ArchiveItem(
                            type: "normal",
                            publicID: publicID,
                            title: title,
                            author: author,
                            updated: updated,
                            description: description,
                            like_count: like_count,
                            comment_count: comment_count,
                            char_count: char_count,
                            liked: liked,
                            isAuthor: isAuthor)]
                        
                    }
                    
                    
                case .failure(_:):
                    
                    self.listArray.append(ArchiveItem(
                        type: "offline",
                        publicID: "",
                        title: "",
                        author: "",
                        updated: "",
                        description: "",
                        like_count: "",
                        comment_count: "",
                        char_count: "",
                        liked: false,
                        isAuthor: false))
                    
                }
                
                // Reload tableview and stop spinner
                self.activityIndicatior.stopAnimating()
                self.table.isHidden = false
                self.table.reloadData()
                
        }

        
    }
    
    
    
    
    
    
    
    
    
    
    // Number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.resultSearchController.isActive) {
            return listArrayFiltered.count
        } else {
            return listArray.count
        }
    }
    
    // Number of sections
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    
    // Set contents
    private func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        
        if (listArray[indexPath.row].type == "offline") {
            
            cell = self.table.dequeueReusableCell(withIdentifier: "cellOffline", for: indexPath) as! ArchiveOfflineViewCell
            
        } else {
        
            let cell2 = self.table.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ArchiveViewCell
        
            
            if (self.resultSearchController.isActive) {
                cell2.titleLabel.text = listArrayFiltered[indexPath.row].title
                cell2.creatorLabel.text = listArrayFiltered[indexPath.row].author
                cell2.descriptionLabel.text = listArrayFiltered[indexPath.row].description
                cell2.commentNumberLabel.text = listArrayFiltered[indexPath.row].comment_count
                cell2.likeNumberLabel.text = listArrayFiltered[indexPath.row].like_count
                
                if (listArrayFiltered[indexPath.row].liked) {
                    cell2.likeImage.image = UIImage(named: "like-filled")
                }
                
            } else {
                cell2.titleLabel.text = listArray[indexPath.row].title
                cell2.creatorLabel.text = listArray[indexPath.row].author
                cell2.descriptionLabel.text = listArray[indexPath.row].description
                cell2.commentNumberLabel.text = listArray[indexPath.row].comment_count
                cell2.likeNumberLabel.text = listArray[indexPath.row].like_count

                if (listArray[indexPath.row].liked) {
                    cell2.likeImage.image = UIImage(named: "like-filled")
                } else {
                    cell2.likeImage.image = UIImage(named: "like")
                }
                
            }
        
        
            cell2.expandButton.tag = indexPath.row
            cell2.expandButton.addTarget(self, action: #selector(ArchiveViewController.expandCollapse(_:)), for: UIControlEvents.touchUpInside)
            
            
            let gesture = UITapGestureRecognizer(target: self, action: #selector(ArchiveViewController.openComments(_:)))
            cell2.commentView.addGestureRecognizer(gesture)
            
            let gesture2 = UITapGestureRecognizer(target: self, action: #selector(ArchiveViewController.like(_:)))
            cell2.likeView.addGestureRecognizer(gesture2)
            
            let gesture3 = UITapGestureRecognizer(target: self, action: #selector(ArchiveViewController.showMoreOptions(_:)))
            cell2.moreButton.tag = indexPath.row
            cell2.moreButton.addGestureRecognizer(gesture3)
            
            cell = cell2
        }
            
        return cell
    }
    
    
    // Expand and collapse description
    func expandCollapse(_ sender: UIButton) {
        
        let collapseImage = UIImage(named: "collapse")
        let expandImage = UIImage(named: "expand")
        
        let row = sender.tag
        let indexPath = IndexPath(row: row, section: 0)
        
        let cell = self.table.cellForRow(at: indexPath) as! ArchiveViewCell
        
        
        if (sender.currentImage == UIImage(named: "expand")) {
            sender.setImage(collapseImage, for: UIControlState())
            
            //cell.moreViewHeight.constant = 200.0
            cell.moreViewHeight.isActive = false
    
        } else {
            sender.setImage(expandImage, for: UIControlState())
            
            //cell.moreViewHeight.constant = 0
            cell.moreViewHeight.isActive = true
            
        }
        
        
        self.table.beginUpdates()
        self.table.endUpdates()
        
    }
    

    // Open comments
    func openComments(_ sender: UITapGestureRecognizer) {

        let tapLocation = sender.location(in: self.table)
        let indexPath = self.table.indexPathForRow(at: tapLocation)
        
        if (self.resultSearchController.isActive) {
            currentPublicIDComments = listArrayFiltered[(indexPath?.row)!].publicID
        } else {
            currentPublicIDComments = listArray[(indexPath?.row)!].publicID
        }
        
        self.performSegue(withIdentifier: "openComments", sender: self)
        
    }
    
    
    
    // Like
    func like(_ sender: UITapGestureRecognizer) {
        
        let tapLocation = sender.location(in: self.table)
        let indexPath = self.table.indexPathForRow(at: tapLocation)
        
        let cell = table.cellForRow(at: indexPath!) as! ArchiveViewCell
        
        if (self.resultSearchController.isActive) {
            
            if (!listArrayFiltered[(indexPath?.row)!].isAuthor) {
                listArrayFiltered[(indexPath?.row)!].liked = !listArrayFiltered[(indexPath?.row)!].liked
                cell.likeImage.image = UIImage(named: listArrayFiltered[(indexPath?.row)!].liked ? "like-filled" : "like")
                
                var likeNumberString: String! = cell.likeNumberLabel.text
                var likeNumberInt: Int! = Int(likeNumberString!)
                likeNumberInt = likeNumberInt! + (listArrayFiltered[(indexPath?.row)!].liked ? 1 : -1)
                likeNumberString = String(likeNumberInt)
                cell.likeNumberLabel.text = likeNumberString!
                
                
                let url = URL(string: (listArrayFiltered[(indexPath?.row)!].liked ? Vars.URL_LIKE : Vars.URL_DISSLIKE) + listArrayFiltered[(indexPath?.row)!].publicID)
                let parameters = ["headless": "headless"]
                _ = Alamofire.request(url!, parameters: parameters)
            }
            
            
            
        } else {
            
            if (!listArray[(indexPath?.row)!].isAuthor) {
            
                listArray[(indexPath?.row)!].liked = !listArray[(indexPath?.row)!].liked
                cell.likeImage.image = UIImage(named: listArray[(indexPath?.row)!].liked ? "like-filled" : "like")
            
                var likeNumberString: String! = cell.likeNumberLabel.text
                var likeNumberInt: Int! = Int(likeNumberString!)
                likeNumberInt = likeNumberInt! + (listArray[(indexPath?.row)!].liked ? 1 : -1)
                likeNumberString = String(likeNumberInt)
                cell.likeNumberLabel.text = likeNumberString!
            
            
                let url = URL(string: (listArray[(indexPath?.row)!].liked ? Vars.URL_LIKE : Vars.URL_DISSLIKE) + listArray[(indexPath?.row)!].publicID)
                let parameters = ["headless": "headless"]
                _ = Alamofire.request(url!, parameters: parameters)
            }
            
        }
        
        
    }
    
    
    
    // Clicked a row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "playFromArchive", sender: self)
    }
    
    
    // Set segue data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "playFromArchive") {

            
            let yourNextViewController = (segue.destination as! PlayViewController)
            let indexPath = self.table.indexPathForSelectedRow
            
            if (self.resultSearchController.isActive) {
            
                let titleString = listArrayFiltered[(indexPath?.row)!].title
                var urlString = listArrayFiltered[(indexPath?.row)!].publicID
                
                urlString = "http://koda.nu/arkivet/\(urlString)"
                
                yourNextViewController.recivedTitle = titleString
                yourNextViewController.recivedUrl = urlString
                
            } else {
                
                let titleString = listArray[(indexPath?.row)!].title
                var urlString = listArray[(indexPath?.row)!].publicID
                
                urlString = "http://koda.nu/arkivet/\(urlString)"
                
                yourNextViewController.recivedTitle = titleString
                yourNextViewController.recivedUrl = urlString
                
            }
            
            table.deselectRow(at: indexPath!, animated: true)
            
            
        } else if (segue.identifier == "openComments") {
            let yourNextViewController = (segue.destination as! CommentsViewController)
            yourNextViewController.publicIDString = currentPublicIDComments
            
        }
        
    }
    
    // More button
    func showMoreOptions(_ sender: UIButton) {
        
        print(sender.tag)
        
        let currentRow = 0
        
        
        let optionMenu: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Share
        let shareAction = UIAlertAction(title: "Dela", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            let message = "Kolla in \(self.listArray[currentRow].title) på Koda.nu! http://koda.nu/arkivet/\(self.listArray[currentRow].publicID)"
            
            let vc = UIActivityViewController(activityItems: [message], applicationActivities: nil)
            self.present(vc, animated: true, completion: nil)
            
        })
        
        // QR share
        let qrShareAction = UIAlertAction(title: "Dela QR kod", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            //self.performSegueWithIdentifier("showQRViewer", sender: self)
        })
        
        // Profile
        let profileAction = UIAlertAction(title: "Visa profil", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            //self.performSegueWithIdentifier("showProfile", sender: self)
        })
        
        let cancelAction = UIAlertAction(title: "Avbryt", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        
        // 4
        optionMenu.addAction(shareAction)
        optionMenu.addAction(qrShareAction)
        optionMenu.addAction(profileAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        optionMenu.popoverPresentationController?.sourceView = sender
        self.present(optionMenu, animated: true, completion: nil)
        
        
    }

    

    
    
    
    
    
    
    
    
    
    /*
      ____    _____      _      ____     ____   _   _
     / ___|  | ____|    / \    |  _ \   / ___| | | | |
     \___ \  |  _|     / _ \   | |_) | | |     | |_| |
     ___) |  | |___   / ___ \  |  _ <  | |___  |  _  |
     |____/  |_____| /_/   \_\ |_| \_\  \____| |_| |_|
  
    */
    
    
    
    // Update list when searching
    func updateSearchResults(for searchController: UISearchController) {
        self.listArrayFiltered.removeAll(keepingCapacity: false)
        
        for i in 0..<listArray.count {
            if (searchController.searchBar.text == "") {
                self.listArrayFiltered = self.listArray
            } else {
                if (listArray[i].title.lowercased().contains(searchController.searchBar.text!.lowercased())) {
                    listArrayFiltered.append(listArray[i])
                } else if (listArray[i].author.lowercased().contains(searchController.searchBar.text!.lowercased())) {
                    listArrayFiltered.append(listArray[i])
                }
                
                
            }
            
        }
        
        // Sort based on search term
        if (searchController.searchBar.text != "") {
           
            let filtered = self.listArrayFiltered.filter {
                
                let title = $0.title.lowercased()
                let author = $0.author.lowercased()
                
                return title.range(of: searchController.searchBar.text!.lowercased()) != nil || author.range(of: searchController.searchBar.text!.lowercased()) != nil
            }
                
            self.listArrayFiltered = filtered
            
            self.table.reloadData()
        }

    }
    
        
    
    // Cancel button pressed
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.resultSearchController.searchBar.endEditing(true)
        self.resultSearchController.isActive = false
        self.listArrayFiltered = listArray
        self.table.reloadData()
        
    }
    
    
    // Dissmiss keyboard on scroll
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.resultSearchController.searchBar.endEditing(true)
    }
    
    
}
