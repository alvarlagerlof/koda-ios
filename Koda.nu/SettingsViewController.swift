//
//  SettingsViewController.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 12/10/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import UIKit
import Alamofire

class SettingsViewController: UITableViewController {
    
    
    let prefs = UserDefaults.standard
    
    
    @IBOutlet var table: UITableView!
    
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var nickNameButton: UIButton!
    
    @IBOutlet weak var notificationsSwitch: UISwitch!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fristStartBool = prefs.bool(forKey: Vars.USERDEFAULT_FIRST_START)
        
        if (!fristStartBool) {
            prefs.set(true, forKey: Vars.USERDEFAULT_FIRST_START)
            prefs.set(true, forKey: Vars.USERDEFAULT_NOTIFICATIONS)
        }
        
        
        // Set nickname
        if let nick = prefs.string(forKey: Vars.USERDEFAULT_NICK_NAME) {
            nickNameTextField.text = nick
        }
        
        
        // Set notifications switch
        if (!prefs.bool(forKey: Vars.USERDEFAULT_NOTIFICATIONS)) {
            notificationsSwitch.setOn(false, animated: false)
        }
        
        
        // Tap to dismiss keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            nickNameTextField.isUserInteractionEnabled = true
            nickNameTextField.becomeFirstResponder()
        case 1:
            if (notificationsSwitch.isOn) {
                notificationsSwitch.setOn(false, animated: true)
            } else {
                notificationsSwitch.setOn(true, animated: true)
            }
        case 2:
            for cookie in HTTPCookieStorage.shared.cookies! {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
            UserDefaults.standard.synchronize()
            URLCache.shared.removeAllCachedResponses()
            
            self.performSegue(withIdentifier: "showLogin", sender: self)
        default:
            print("None of the sections above")
        }
        
    }
    
    
    // Nick name save and start edit
    // when button pressed
    @IBAction func nickNameEditButtonAction(_ sender: AnyObject) {
        if (nickNameButton.titleLabel?.text == "Ändra") {
            nickNameTextField.isUserInteractionEnabled = true
            nickNameTextField.becomeFirstResponder()
        } else {
            view.endEditing(true)
            updateNickName(nickNameTextField.text!)
        }
    }
    
    
    // Update the nickname button
    @IBAction func nickNameEditBegan(_ sender: AnyObject) {
        nickNameButton.setTitle("Spara", for: UIControlState())
    }
    
    
    @IBAction func nickNameEditEnded(_ sender: AnyObject) {
        nickNameButton.setTitle("Ändra", for: UIControlState())
    }
    
    
    
    // On notfications switch value changed
    @IBAction func notificationsSwitchValueChanged(_ sender: AnyObject) {
        prefs.set(notificationsSwitch.isOn, forKey: Vars.USERDEFAULT_NOTIFICATIONS)
    }
    
    
    // Log out
    @IBAction func logOut(_ sender: AnyObject) {
        for cookie in HTTPCookieStorage.shared.cookies! {
            HTTPCookieStorage.shared.deleteCookie(cookie)
        }
        UserDefaults.standard.synchronize()
        URLCache.shared.removeAllCachedResponses()
        
        self.performSegue(withIdentifier: "showLogin", sender: self)
    }
    
    
    
    
    // Dissmiss keyboard on scroll and tap outside
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
        updateNickName(nickNameTextField.text!)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
        updateNickName(nickNameTextField.text!)
    }
    
    
    
    // Send new nickname to server
    func updateNickName(_ nickName: String) {
        prefs.set(nickNameTextField.text, forKey: Vars.USERDEFAULT_NICK_NAME)
        
        let url = "https://koda.nu/labbet"
        
        let parameters = [
            "nick": "" + nickNameTextField.text! + ""
        ]
        
        Alamofire.request(URL(string: url)!, parameters: parameters)
            .responseString { response in
                //print(response.result.value ?? "No response")
        }

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
