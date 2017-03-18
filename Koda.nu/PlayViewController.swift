//
//  PlayViewController.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 20/07/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import UIKit

class PlayViewController: UIViewController {
    
    var recivedUrl: String = ""
    var recivedTitle: String = ""
    
    @IBOutlet weak var gameWebView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationItem.title = recivedTitle
        
        
        gameWebView.isHidden = true
        gameWebView.scalesPageToFit = true
        
        
        let gameUrl = URL (string: recivedUrl)
        let requestObj = URLRequest(url: gameUrl!);
        gameWebView.loadRequest(requestObj)
        gameWebView.scrollView.isScrollEnabled = false
        
        
        
        
        
    }
    
    
    // Reload
    @IBAction func refresh(_ sender: UIBarButtonItem) {
        gameWebView.reload()
    }
    
    // Share
    @IBAction func share(_ sender: UIBarButtonItem) {
        
        var message: String = ""
        
        if (recivedTitle != "Spela") {
            message = "Kolla in \(recivedTitle) på Koda.nu! \(recivedUrl)"
        } else {
            message = recivedUrl
        }
        
        let vc = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            //let popOver: UIPopoverController = UIPopoverController(contentViewController: vc)
            //popOver.presentPopoverFromBarButtonItem(self.shareButton, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            
        } else {
            self.present(vc, animated: true, completion: nil)
        }
        
        
        
    }
    
    
    // Stop spinner
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        gameWebView.isHidden = false
    }
    
    // Back button
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        if parent == nil {
            //setTabBarVisible(true, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
