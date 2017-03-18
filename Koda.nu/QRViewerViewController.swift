//
//  QRViewerViewController.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 03/09/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import UIKit
import QRCode

class QRViewerViewController: UIViewController {
    
    var recivedUrl: String = ""
    
    @IBOutlet weak var image: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        image.image = {
            var qrCode = QRCode(recivedUrl)!
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
