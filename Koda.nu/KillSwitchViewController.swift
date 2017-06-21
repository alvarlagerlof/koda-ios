//
//  KillSwitchViewController.swift
//  Koda.nu
//
//  Created by Alvar Lagerlöf on 5/27/17.
//  Copyright © 2017 Alvar Lagerlöf. All rights reserved.
//

import UIKit
import Firebase

class KillswitchViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextVIew: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var actionTextView: UITextView!

    var didNotFetch: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        scrollView.backgroundColor = UIColor(hex: Vars.APP_COLOR)

        
        if !didNotFetch {
            titleTextVIew.text = Vars.KILLSWITCH_TITLE
            descriptionTextView.text = Vars.KILLSWITCH_DESCRIPTION
            actionTextView.text = Vars.KILLSWITCH_ACTION
            
        } else {
            titleTextVIew.text = "Tjänsten nere."
            descriptionTextView.text = "Koda.nu lyckades inte nå servern."
            actionTextView.text = "Pröva att starta appen igen om en stund."
        }
        
        
        
        titleTextVIew.backgroundColor = UIColor(hex: Vars.APP_COLOR)
        descriptionTextView.backgroundColor = UIColor(hex: Vars.APP_COLOR)
        actionTextView.backgroundColor = UIColor(hex: Vars.APP_COLOR)

        titleTextVIew.sizeToFit()
        descriptionTextView.sizeToFit()
        actionTextView.sizeToFit()

        
        Analytics.logEvent("killswitch_open", parameters: [:])
        
        
        
        
        
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
    
    
    
    

    
}
