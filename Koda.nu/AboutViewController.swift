//
//  AboutViewController.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 10/11/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//
import UIKit

class AboutController: UIViewController {
    
    @IBOutlet weak var versionTextView: UILabel!
    @IBOutlet weak var descriptionTextView: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        // Version text view
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?
        let version = nsObject as! String
        
        versionTextView.text = versionTextView.text! + version
        
        
        // Long description
        descriptionTextView.numberOfLines = 0
        descriptionTextView.sizeToFit()
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
