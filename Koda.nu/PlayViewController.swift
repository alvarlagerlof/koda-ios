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
    var recivedAuthor: String = ""
    
    @IBOutlet weak var gameWebView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationItem.title = recivedTitle
        
        
        gameWebView.isHidden = true
        gameWebView.scalesPageToFit = true
        
        
        let gameUrl = URL(string: recivedUrl)
        let requestObj = URLRequest(url: gameUrl!);
        gameWebView.loadRequest(requestObj)
        gameWebView.scrollView.isScrollEnabled = false
        
        
        print(recivedTitle)
        print(recivedUrl)
        
        
        
    }
    
    
    // Reload
    @IBAction func refresh(_ sender: UIBarButtonItem) {
        activityIndicator.startAnimating()
        gameWebView.isHidden = true
        gameWebView.goBack()
        let gameUrl = URL(string: recivedUrl)
        let requestObj = URLRequest(url: gameUrl!);
        gameWebView.loadRequest(requestObj)
    }
    
    
    // Share
    @IBAction func share(_ sender: UIBarButtonItem) {
        
        
        // Create action sheet
        let optionMenu: UIAlertController = UIAlertController(title: "Dela " + self.recivedTitle, message: nil, preferredStyle: .actionSheet)
        
        
        // Share
        optionMenu.addAction(UIAlertAction(title: "Dela via app", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            let message = "Kolla in "+self.recivedTitle+" av "+self.recivedAuthor+" på Koda.nu! " + self.recivedUrl
            
            let vc = UIActivityViewController(activityItems: [message], applicationActivities: nil)
            ViewHelper().getRoot().present(vc, animated: true, completion: nil)
            
        }))
        
        
        // QR share
        optionMenu.addAction(UIAlertAction(title: "Dela via QR kod", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            
            let storyboard = UIStoryboard(name: "QRViewer", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "QRViewer") as! QRViewerViewController
            
            vc.recivedUrl = "http://koda.nu/arkiver/" + self.recivedUrl
            vc.recivedTitle = self.recivedTitle
            
            
            ViewHelper().getRoot().present(vc, animated: true)
            
            
            
        }))
        
        
     
        // Cancel
        optionMenu.addAction(UIAlertAction(title: "Avbryt", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        }))
        
    
        
        // Show
        //optionMenu.popoverPresentationController?.sourceView = sender
        ViewHelper().getRoot().present(optionMenu, animated: true, completion: nil)

        
        
        
        
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
