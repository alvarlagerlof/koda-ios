//
//  AboutViewController.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 10/11/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//
import UIKit
import Firebase

class AboutController: UIViewController {
    
    @IBOutlet weak var versionTextView: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Analytics.logEvent("settings_about_open", parameters: [:])

        
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: descriptionTextView.frame.size.height)
        
     
        // Version text view
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?
        let version = nsObject as! String
        
        versionTextView.text = versionTextView.text! + version
        
        
        // Long description
        descriptionTextView.sizeToFit()
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
