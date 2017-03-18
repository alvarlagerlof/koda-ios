//
//  ForgotPassViewController.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 11/11/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ForgotPassViewController: UIViewController {

    @IBOutlet weak var imageBackground: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTextField(emailTextField)
        setUpButton(nextButton)
        
        
        imageBackground.kf.setImage(with: URL(string: Vars.URL_LOGIN_FORGOT_IMAGE))
        
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

    
    
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        
        if !Reachability.isConnectedToNetwork() {
            let alert = UIAlertController(title: "Ingen ansluting", message: "Gå in på inställingar och se till att WiFi eller mobildata är på", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            let url = Vars.URL_LOGIN_FORGOT
            
            let parameters = [
                "email": emailTextField.text! as String,
                "verification_reset": "7",
                "headless": "thisisheadless"
            ]
            
            Alamofire.request(URL(string: url)!, parameters: parameters)
                .responseString { response in
                    
                    
                    let json = JSON(data: response.result.value!.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers, error: nil)
                    
                    
                    let alert = UIAlertController(title: json["message"].string, message: nil, preferredStyle: UIAlertControllerStyle.alert)
                    
                    let okActionClose = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                    }
                    
                    if (json["success"].stringValue == "true") {
                        alert.addAction(okActionClose)
                    } else {
                        alert.addAction(okAction)
                    }
                    
                    
                    self.present(alert, animated: true, completion: nil)
            }
        }
        
        
    }
    
}
