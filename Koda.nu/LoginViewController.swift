//
//  LoginViewController.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 30/08/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire
import SwiftyJSON

class LoginViewController: UIViewController {

    @IBOutlet weak var imageBackground: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPassButton: UIButton!
    @IBOutlet weak var createAccoutButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setUpTextField(emailTextField)
        setUpTextField(passwordTextField)
        setUpButtonColored(loginButton)
        
        setUpButton(forgotPassButton)
        setUpButtonColored(createAccoutButton)
        
        imageBackground.kf.setImage(with: URL(string: Vars.URL_LOGIN_IMAGE))
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    
    
    
    // Buttons
    func setUpButton(_ button: UIButton) {
        button.setTitleColor(UIColor.black, for: UIControlState())
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 5.0
    }
    
    func setUpButtonColored(_ button: UIButton) {
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.backgroundColor = UIColor(red: 63.0/255.0, green: 81.0/255.0, blue: 181.0/255.0, alpha: 1.0)
        button.layer.cornerRadius = 5.0
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
    
    
    
    
    @IBAction func pressLogin(_ sender: UIButton) {
        
        if !Reachability.isConnectedToNetwork() {
            let alert = UIAlertController(title: "Ingen ansluting", message: "Gå in på inställingar och se till att WiFi eller mobildata är på", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            let parameters = [
                "email": emailTextField.text! as String,
                "password": passwordTextField.text! as String,
                "headless": "thisisheadless"
            ]
            
            
            Alamofire.request(URL(string: Vars.URL_LOGIN)!, parameters: parameters)
                .responseString { response in
                                        
                    var json = JSON(data: response.result.value!.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers, error: nil)
                    
                    
                    if (json["access"].string == "denied") {
                        let alert = UIAlertController(title: "Ops!", message: "Felaktig email eller lösenord", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        
                        UserDefaults.standard.set(self.emailTextField.text, forKey: Vars.USERDEFAULT_EMAIL)
                        UserDefaults.standard.set(self.passwordTextField.text, forKey: Vars.USERDEFAULT_PASSWORD)

                        
                        self.dismiss(animated: false, completion: nil)
                    }
                    
            }
        }
        
        
    }
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    

}
