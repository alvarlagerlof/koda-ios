//
//  QRViewerViewController.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 03/09/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import UIKit
import QRCode
import SwiftyJSON

class QRViewerViewController: UIViewController {
    
    var recivedUrl: String = ""
    var recivedTitle: String = ""
    
    @IBOutlet weak var image: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get nickname
        let author = UserDefaults.standard.string(forKey: Vars.USERDEFAULT_NICK_NAME)
        
        // Set QR image
        image.image = {
            
            // Create data json object
            var data: JSON = ["url": "", "title": "", "author": ""]
            data["url"].string = Base64Helper.encode(decoded: self.recivedUrl)
            data["title"].string = Base64Helper.encode(decoded: self.recivedTitle)
            data["author"].string = Base64Helper.encode(decoded: ((author == "" || author == nil) ? "Anonym" : author!))
            
            
            // Create QR code
            var qrCode = QRCode(data.rawString()!)!
            qrCode.size = self.image.bounds.size
            
            return qrCode.image
        }()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}
