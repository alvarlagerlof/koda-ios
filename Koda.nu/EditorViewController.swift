
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

class EditorViewController: UIViewController, UITextViewDelegate {

    
    // Set values
    var firstPrivateID: String = ""
    var syncedPrivateID: String = ""
    var notificationToken: NotificationToken?

    
    var overflowItems: Array<String> = []
    
    var rightBarButtonItem: UIBarButtonItem!
    private var delegate: JLTextStorageDelegate!

    
    
    @IBOutlet weak var textEditor: UITextView!
    @IBOutlet weak var gameWebView: UIWebView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var scrollView: UIScrollView!

    
    
    

    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Analytics.logEvent("projects_edit_open", parameters: [:])

        
        // Private id
        if !firstPrivateID.contains("ny_ny_") {
            syncedPrivateID = firstPrivateID
        }
        
        

        // Editor setup
        NotificationCenter.default.addObserver(self, selector: #selector(EditorViewController.setSyncedId(_:)), name: .editorSyncedID, object: nil)
        
        delegate = JLTextStorageDelegate(managing: self.textEditor, language: Language.javascript, theme: ColorTheme.default)
        registerForKeyboardNotifications()
        specialCharsBarSetup()
        getProject(setText: true)

        
        

        
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
    
    


    
    
    
    func editor() {
        
        gameWebView.isHidden = true
        textEditor.isHidden = false
        
        gameWebView.loadHTMLString("", baseURL: nil)
        
        self.navigationItem.rightBarButtonItem = nil
        
    }
    
  
    func play() {
        textEditor.endEditing(true)
        
        
        gameWebView.isHidden = false
        textEditor.isHidden = true
        
        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem

        gameWebView.loadHTMLString(textEditor.text, baseURL: nil)
        gameWebView.scrollView.isScrollEnabled = false


        saveProject()
    
        
    }
    
    
    
    
    func getProject(setText: Bool) {
        if setText {
            self.textEditor.text = try! Realm().objects(ProjectsRealmItem.self).filter("privateID = '\(syncedPrivateID != "" ? syncedPrivateID : firstPrivateID)'").first?.code
        }
    }
    
    
    func saveProject() {
        if self.syncedPrivateID != "" || !Reachability.isConnectedToNetwork() {
            
            let realm = try! Realm()
            let object = realm.objects(ProjectsRealmItem.self).filter("privateID = '\(self.syncedPrivateID)'").first
                    
            try! realm.write {
                object?.code = self.textEditor.text
                object?.updatedRealm = String(Int(round(NSDate().timeIntervalSince1970)))
                object?.isSynced = false
            }
            
            _ = ProjectsSync()
            
        }
    }
    
    
    func setSyncedId(_ notification: NSNotification) {
        if let id = notification.userInfo?["synced_id"] as? String {
            syncedPrivateID = id
            getProject(setText: false)
        }
    }
    
    
    
    
    
    
    
    
    
    
    func specialCharsBarSetup() {
        
        // Lists
        let specialChars = ["( )", "{ }", "[ ]", ".", ",", "\" \"",
                            ":",
                            "-", "+", "*", "/",
                            "=", "!",
                             "<",  ">",
                            "%", "?",
                            "&", "|"]
        
        overflowItems.removeAll()
        
        var toolbarItems = [UIBarButtonItem]()

        
        // Add tooblarItems
        for (index, item) in specialChars.enumerated() {
            if (index < 6) {
                toolbarItems.append(UIBarButtonItem(title: (index == 0 ? "  " : "   ") + item + "   " , style: .plain, target: nil, action: #selector(addSpecialChar)))
            } else {
                overflowItems.append(item)
            }
        }
        
        
        // Extra items
        toolbarItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        toolbarItems.append(UIBarButtonItem(image: UIImage(named: "more"), landscapeImagePhone: UIImage(named: "more"), style: .plain, target: nil, action: #selector(specialCharsMore)))
        
        
        // Create toolbar and add to keyboard
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.items = toolbarItems
        toolbar.tintColor = UIColor(hex: Vars.APP_COLOR)
        
        self.textEditor.inputAccessoryView = toolbar
        
    }
    
    
    
    func specialCharsMore(_ sender: UIBarButtonItem) {
        
        
        // Create action sheet
        let optionMenu: UIAlertController = UIAlertController(title: "Fler specialtecken", message: nil, preferredStyle: .actionSheet)
        
        
        for item in overflowItems {
            
            optionMenu.addAction(UIAlertAction(title: item, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.textEditor.insertText(item)
                if item.characters.count == 2 {
                    if let selectedRange = self.textEditor.selectedTextRange {
                        if let newPosition = self.textEditor.position(from: selectedRange.start, offset: -1) {
                            self.textEditor.selectedTextRange = self.textEditor.textRange(from: newPosition, to: newPosition)
                        }
                    }
                }
        
            }))
            
        }
        
        
        
        // Cancel
        optionMenu.addAction(UIAlertAction(title: "Avbryt", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            Analytics.logEvent("projects_more_cancel", parameters: [:])
        }))
        
        
        
        // Show
        optionMenu.popoverPresentationController?.barButtonItem = sender
        self.present(optionMenu, animated: true, completion: nil)

    }
    
    // Special chars bar click
    func addSpecialChar(sender: UIBarButtonItem) {
        let text = sender.title?.replacingOccurrences(of: " ", with: "")
        self.textEditor.insertText(text!)
        if text?.characters.count == 2 {
            if let selectedRange = self.textEditor.selectedTextRange {
                if let newPosition = self.textEditor.position(from: selectedRange.start, offset: -1) {
                    self.textEditor.selectedTextRange = self.textEditor.textRange(from: newPosition, to: newPosition)
                }
            }
        }
    }
    
    
    
    
    func reload(_ sender: UIBarButtonItem) {
        gameWebView.goBack()
        gameWebView.loadHTMLString(textEditor.text, baseURL: nil)
        Analytics.logEvent("projects_edit_reload", parameters: [:])
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
    

    
    // Save on close
    override func viewWillDisappear(_ animated: Bool) {
        saveProject()
    }
    
    
    
    
    
    
    // MARK: Content Insets and Keyboard
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    

}
