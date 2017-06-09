
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
import Firebase

class EditorViewController: UIViewController {

    
    // Set values
    var privateID: String = ""
    
    var rightBarButtonItem : UIBarButtonItem!
    
    
    @IBOutlet weak var textEditor: UITextView!
    @IBOutlet weak var gameWebView: UIWebView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    private var delegate: JLTextStorageDelegate!
    

    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Analytics.logEvent("projects_edit_open", parameters: [:])

        
        
        self.textEditor.text = try! Realm().objects(ProjectsRealmItem.self).filter("privateID = '\(privateID)'").first?.code
        
        
        //self.textEditor.backgroundColor = UIColor(red: 13/255, green: 42/255, blue: 70/255, alpha: 1)
        
        
        delegate = JLTextStorageDelegate(managing: self.textEditor, language: Language.javascript, theme: ColorTheme.default)
        
        registerForKeyboardNotifications()
        
        

        
        // Game view setup
        gameWebView.isHidden = true
        gameWebView.scalesPageToFit = true
        
        
        // NavigationBar items
        rightBarButtonItem = UIBarButtonItem(title: "",
                                             style: UIBarButtonItemStyle.plain,
                                             target: self,
                                             action: #selector(reload(_:)))
        
        rightBarButtonItem.image = UIImage(named: "reload")!
        
        
    }


    // On tab click
    @IBAction func tabIndexChanged(_ sender: AnyObject) {
        
        switch segmentedControl.selectedSegmentIndex {
            case 0:
                editor()
                Analytics.logEvent("projects_edit_tab_editor", parameters: [:])
            case 1:
                play()
                Analytics.logEvent("projects_edit_tab_play", parameters: [:])
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

        gameWebView.loadHTMLString(textEditor.text, baseURL: nil)
        gameWebView.scrollView.isScrollEnabled = false


        saveToRealm()
        
        
        
    }
    
    
    func reload(_ sender: UIBarButtonItem) {
        gameWebView.goBack()
        gameWebView.loadHTMLString(textEditor.text, baseURL: nil)
        Analytics.logEvent("projects_edit_reload", parameters: [:])

    }
    
    
    
    
    func saveToRealm() {
        let realm = try! Realm()
        let object = realm.objects(ProjectsRealmItem.self).filter("privateID = '\(privateID)'").first
        
        if (object?.code != textEditor.text) {
            try! realm.write {
                object!.code = textEditor.text
                object!.updatedRealm = String(Int(round(NSDate().timeIntervalSince1970)))
                object!.isSynced = false
            }
            
            
            _ = ProjectsSync()
            
        }
    }
    
    
    
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        saveToRealm()
    }
    
    
    
    // MARK: Content Insets and Keyboard
    
    func registerForKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unregisterForKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Called when the UIKeyboardDidShowNotification is sent.
    func keyboardWasShown(_ notification: Notification) {
        
        // FIXME: ! could be wrong
        let info = (notification as NSNotification).userInfo!
        let scrollView = self.textEditor
        let kbSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size;
        
        var contentInsets = scrollView?.contentInset;
        contentInsets?.bottom = kbSize.height;
        scrollView?.contentInset = contentInsets!;
        scrollView?.scrollIndicatorInsets = contentInsets!;
        
        // FIXME: ! could be wrong
        var point = self.textEditor.caretRect(for: self.textEditor.selectedTextRange!.start).origin;
        point.y = min(point.y, self.textEditor.frame.size.height - kbSize.height);
        
        var aRect = self.view.frame;
        aRect.size.height -= kbSize.height;
        if (!aRect.contains(point) ) {
            
            var rect = CGRect(x: point.x, y: point.y, width: 1, height: 1)
            rect.size.height = kbSize.height
            rect.origin.y += kbSize.height
            self.textEditor.scrollRectToVisible(rect, animated: true)
        }
    }
    
    // Called when the UIKeyboardWillHideNotification is sent
    func keyboardWillBeHidden(_ notification: Notification) {
                
        var contentInsets = self.textEditor.contentInset;
        contentInsets.bottom = 0;
        self.textEditor.contentInset = contentInsets;
        self.textEditor.scrollIndicatorInsets = contentInsets;
        self.textEditor.contentInset = contentInsets;
        self.textEditor.scrollIndicatorInsets = contentInsets;
    }
    
    
    deinit {
        unregisterForKeyboardNotifications()
    }

    
    
    
    

}
