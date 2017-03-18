
//
//  EditorViewController.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 20/07/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift

class EditorViewController: UIViewController {

    var titleString: String = ""
    var privateIDString: String = ""
    var publicIDString: String = ""
    
    var rightBarButtonItem : UIBarButtonItem!
    
    @IBOutlet weak var gameWebView: UIWebView!
    @IBOutlet weak var textEditor: UITextView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameWebView.isHidden = true
        gameWebView.scalesPageToFit = true
        
        
        rightBarButtonItem = UIBarButtonItem(title: "",
                                             style: UIBarButtonItemStyle.plain,
                                             target: self,
                                             action: #selector(reload(_:)))
        
        rightBarButtonItem.image = UIImage(named: "reload")!
        
        
        // Remove shadow from navbar
        for parent in self.navigationController!.navigationBar.subviews {
            for childView in parent.subviews {
                if(childView is UIImageView) {
                    childView.removeFromSuperview()
                }
            }
        }
        
        let realm = try! Realm()
        let object = realm.objects(ProjectsRealmItem.self).filter("privateID = '\(privateIDString)'").first
        
        self.textEditor.text = object?.code
        
    }

   
    @IBAction func tabIndexChanged(_ sender: AnyObject) {
        
        switch segmentedControl.selectedSegmentIndex {
            case 0:
                editor()
            case 1:
                play()
            default:
                break;
        }
        
    }
    
    
    func editor() {
        gameWebView.isHidden = true
        textEditor.isHidden = false
        
        gameWebView.loadHTMLString("", baseURL: nil)
        
        self.navigationItem.rightBarButtonItem = nil
        
    }
  
    func play() {
        gameWebView.isHidden = false
        textEditor.isHidden = true
        
        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem

        
        // Send to server
        let parameters = ["code": textEditor.text]
        Alamofire.request(Vars.URL_EDITOR_SAVE + privateIDString, parameters: parameters).response { response in }

        
        
        // Save offline
        let realm = try! Realm()
        let object = realm.objects(ProjectsRealmItem.self).filter("privateID = '\(privateIDString)'").first
        try! realm.write {
            object!.code = textEditor.text
            object!.updated = String(Int(round(NSDate().timeIntervalSince1970)))
        }
    
  
        gameWebView.loadHTMLString(textEditor.text, baseURL: nil)
        gameWebView.scrollView.isScrollEnabled = false
        
    }
    
    
    
    
    func reload(_ sender: UIBarButtonItem) {
        gameWebView.goBack()
        gameWebView.loadHTMLString(textEditor.text, baseURL: nil)
        
        print("reload")
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
