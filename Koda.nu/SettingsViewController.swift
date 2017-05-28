//
//  SettingsViewController.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 12/10/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import Firebase

class SettingsViewController: UITableViewController {
    
    
    let prefs = UserDefaults.standard
    
    
    @IBOutlet var table: UITableView!
    
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var nickNameButton: UIButton!
    
    @IBOutlet weak var notificationsSwitch: UISwitch!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Analytics.logEvent("settings_open", parameters: [:])

        
        /*
        // If notifications not set
        if isKeyPresentInUserDefaults(key: Vars.USERDEFAULT_NOTIFICATIONS) {
            prefs.set(true, forKey: Vars.USERDEFAULT_NOTIFICATIONS)
        }
        
        
        // Set notifications switch
        if (!prefs.bool(forKey: Vars.USERDEFAULT_NOTIFICATIONS)) {
            notificationsSwitch.setOn(false, animated: false)
        }
        */
        
        // Set nickname
        if let nick = prefs.string(forKey: Vars.USERDEFAULT_NICK_NAME) {
            nickNameTextField.text = nick
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
        
        UserDefaults.standard.set("", forKey: Vars.USERDEFAULT_EMAIL)
        UserDefaults.standard.set("", forKey: Vars.USERDEFAULT_PASSWORD)
        
        if Reachability.isConnectedToNetwork() {
            Alamofire.request(Vars.URL_LOGOUT).responseString { response in
                
                
                if response.result.isSuccess {
                    
                    let realm = try! Realm()
                    try! realm.write {
                        realm.deleteAll()
                    }
                    let storyboard = UIStoryboard(name: "Login", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "login")
                    controller.hidesBottomBarWhenPushed = false
                    ViewHelper().getRoot().present(controller, animated: true, completion: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                        self.navigationController?.tabBarController?.selectedIndex = 0
                        self.navigationController?.popViewController(animated: true)
                    })
                    
                } else {
                    let alert = UIAlertController(title: "Ops!", message: "Något gick fel", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        
        } else {
            let alert = UIAlertController(title: "Ops!", message: "Ingen internet-anslutning", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)

        }
        
        
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
    
    
    
    
    
    
    
    
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
