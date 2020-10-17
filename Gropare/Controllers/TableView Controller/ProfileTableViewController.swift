//
//  ProfileTableViewController.swift
//  Gropare
//
//  Created by Danish Munir on 08/10/2020.
//

import UIKit
import MaterialComponents.MaterialSnackbar


class ProfileTableViewController: UITableViewController {
    let http = HTTPService()
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var emailSwitch: UISwitch!
    @IBOutlet weak var smsSwitch: UISwitch!
    @IBOutlet weak var inAppSwitch: UISwitch!
    
    let snackManager = MDCSnackbarManager()
    let snackBarMessage = MDCSnackbarMessage()
    var emailSwitchInt = Int()
    var inAppSwitchInt = Int()
    var smsSwitchInt = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myProfile()
        serverhitNotifications()
    }
    
    let semaphore = DispatchSemaphore(value: 0)
    @IBAction func saveBtnTapped(_ sender: Any) {
        
        setValues()
        serverhitUpdateNotifications()
        
    }
    @IBAction func continueBtnTapped(_ sender: Any) {
        if isempty(){
            serverHiteditProfile()
        }else{
            print("Some thing went wrong")
        }
    }
    
    
}

extension ProfileTableViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .zero
    }
}

extension ProfileTableViewController {
    func myProfile() {
        let dict =  ["user_id":UserDefaults.standard.string(forKey: "user_id")]
        http.requestWithPost(parameters: dict as [String : Any], Url: Endpoints.profileURL) { [self] (response, error) in
            DispatchQueue.main.async { [self] in
                let jsonData = response?.toJSONString1().data(using: .utf8)
                let decoder = JSONDecoder()
                do {
                    let obj = try decoder.decode(Register.self, from: jsonData!)
                    if let objData = obj.data{
                        nameTF.text = objData.userName
                        emailTF.text = objData.userEmail
                        phoneTF.text = objData.userPhone
                    }
                    else{
                        print(error?.localizedDescription as Any)
                    }
                }
                catch {
                    print(error.localizedDescription)
                }
                
            }
        }
    }
    
    
    
    func serverHiteditProfile() {
        let dict = ["user_email": emailTF.text! ,"user_name": nameTF.text!,"user_phone": phoneTF.text!,"user_id": UserDefaults.standard.string(forKey: "user_id")!] as [String : Any]
        
        http.requestWithPost(parameters: dict as [String : Any], Url: Endpoints.profilEdit) { [self] (response, error) in
            DispatchQueue.main.async { [self] in
                let jsonData = response?.toJSONString1().data(using: .utf8)
                let decoder = JSONDecoder()
                do {
                    let obj = try decoder.decode(Register.self, from: jsonData!)
                    if let objData = obj.data{
                        
                        nameTF.text = objData.userName
                        emailTF.text = objData.userEmail
                        phoneTF.text = objData.userPhone
                        snackBarMessage(snackManager: snackManager, snackBarMessage: snackBarMessage, title: "Profile Updated")
                    }
                    else{
                        print(error?.localizedDescription as Any)
                    }
                }
                catch {
                    print(error.localizedDescription)
                }
                
            }
        }
    }
    func serverhitNotifications() {
        let dict =  ["user_id":UserDefaults.standard.string(forKey: "user_id")]
        http.requestWithPost(parameters: dict as [String : Any], Url: Endpoints.notifyby) { [self] (response, error) in
            DispatchQueue.main.async {
                let jsonData = response?.toJSONString1().data(using: .utf8)
                let decoder = JSONDecoder()
                do {
                    let obj = try decoder.decode(Notification.self, from: jsonData!)
                    if let objData = obj.data{
                        if objData.sms  == 1
                        {
                            smsSwitch.isOn = true
                        }
                        else{
                            smsSwitch.isOn = false
                        }
                        if objData.email  == 1
                        {
                            emailSwitch.isOn = true
                        }
                        else{
                            emailSwitch.isOn = false
                        }
                        if objData.app  == 1
                        {
                            inAppSwitch.isOn = true
                        }
                        else{
                            inAppSwitch.isOn = false
                        }
                    }
                    else{
                        print(error?.localizedDescription as Any)
                    }
                }
                catch {
                    print(error.localizedDescription)
                }
                
            }
        }
    }
    
    func serverhitUpdateNotifications() {
        
        let dict =  ["user_id": UserDefaults.standard.string(forKey: "user_id")!, "sms" : smsSwitchInt , "app" : inAppSwitchInt , "email" : 0] as [String : Any]
        http.requestWithPost(parameters: dict as [String : Any], Url: Endpoints.updateNotify) { (response, error) in
            DispatchQueue.main.async { [self] in
                let jsonData = response?.toJSONString1().data(using: .utf8)
                let decoder = JSONDecoder()
                do {
                    let obj = try decoder.decode(updateNotifications.self, from: jsonData!)
                    if let objData = obj.data{
                        if objData == 1 {
                            print(obj.message!)
                            snackBarMessage(snackManager: snackManager, snackBarMessage: snackBarMessage, title: "Profile Updated")
                            
                        } else {
                            print(obj.message!)
                        }
                    }
                    else{
                        print(error?.localizedDescription as Any)
                    }
                }
                catch {
                    print(error.localizedDescription)
                }
                
            }
        }
    }
    func isempty() -> Bool{
        if ((emailTF.text?.isEmpty) != nil)
        {
            return false
        }
        else if  ((phoneTF.text?.isEmpty) != nil) {
            return false
            
        }
        else if ((nameTF.text?.isEmpty) != nil){
            return false
        }
        else{
            return true
        }
        
    }
    
    func setValues(){
        semaphore.signal()
        if smsSwitch.isOn{
            smsSwitchInt = 1
        }
        else{
            smsSwitchInt = 0
        }
        if inAppSwitch.isOn{
            inAppSwitchInt = 1
        }else{
            inAppSwitchInt = 0
        }
        if emailSwitch.isOn{
            emailSwitchInt = 1
        }else{
            emailSwitchInt = 0
        }
        semaphore.wait()
        
    }
    
}
