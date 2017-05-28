//
//  CreateAccountViewController.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 11/11/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import RealmSwift
import SwiftOverlays
import Firebase

class CreateAccountViewController: UIViewController {
    
    
    @IBOutlet weak var imageBackground: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Analytics.logEvent("login_create_open", parameters: [:])

        
        setUpTextField(emailTextField)
        setUpButton(nextButton)
        
        imageBackground.kf.setImage(with: URL(string: Vars.URL_LOGIN_CREATE_IMAGE))
        
    }
    
    
    

    // Buttons
    func setUpButton(_ button: UIButton) {
        button.setTitleColor(UIColor.black, for: UIControlState())
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 5.0
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.white.cgColor
    }

    
    // Text fields
    func setUpTextField(_ textField: UITextField) {
        textField.textColor = UIColor.white
        textField.tintColor = UIColor.white
        textField.backgroundColor =  UIColor(white: 1, alpha: 0.1)
        textField.layer.cornerRadius = 5.0
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
    }
    
    
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        
        Analytics.logEvent("login_create_button_pressed", parameters: [:])

        
        if !Reachability.isConnectedToNetwork() {
            let alert = UIAlertController(title: "Ingen ansluting", message: "Gå in på inställingar och se till att WiFi eller mobildata är på", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            Analytics.logEvent("login_create_failed", parameters: [:])

            
        } else {
            let url = Vars.URL_LOGIN_CREATE
            
            let parameters = [
                "email": emailTextField.text! as String,
                "verification": "8",
                "headless": "thisisheadless"
            ]
            
            self.showWaitOverlay()
            
            Alamofire.request(URL(string: url)!, method: .post, parameters: parameters)
                .responseString { response in
                    
                    
                    let json = JSON(data: response.result.value!.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers, error: nil)
                    
                    var message: String
                    var failed = false
                    
                    if (json["error"].exists()) {
                        Analytics.logEvent("login_create_failed", parameters: [:])

                        message = json["error"].stringValue
                        failed = true
                    } else {
                        Analytics.logEvent("login_create_successful", parameters: [:])

                        message = "E-mail: " + json["username"].stringValue + "\nLösenord: " + json["password"].stringValue
                        
                        UserDefaults.standard.set(json["username"].stringValue, forKey: Vars.USERDEFAULT_EMAIL)
                        UserDefaults.standard.set(json["password"].stringValue, forKey: Vars.USERDEFAULT_PASSWORD)
                        
                    }
                    
                    
                    // Alert
                    let alert = UIAlertController(title: failed ? "Ops!" : "Dina kontouppgifter", message: message, preferredStyle: UIAlertControllerStyle.alert)
                    
                    let okActionClose = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        let realm = try! Realm()

                        try! realm.write {
                            realm.deleteAll()
                        }
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateProjectsDone"), object: self)
                        _ = ProjectsSync()

                        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
                    }
                    
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                    }
                    
                    
                    if (!failed) {
                        alert.addAction(okActionClose)
                    } else {
                        alert.addAction(okAction)
                    }
                    
               
                    self.removeAllOverlays()

                    self.present(alert, animated: true, completion: nil)
            }
        }
        
        
    }
    
    
}
