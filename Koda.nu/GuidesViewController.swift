//
//  GuidesViewController.swift
//  Koda.nu
//
//  Created by Alvar Lagerlöf on 19/07/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import UIKit

class GuidesViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var youtubeDescriptionTextView: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Guider"
        
        // Only scroll vertically
        Scrollable.createContentView(scrollView)
        
        
        // Mutlitine
        youtubeDescriptionTextView.numberOfLines = 0;
        youtubeDescriptionTextView.sizeToFit()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}