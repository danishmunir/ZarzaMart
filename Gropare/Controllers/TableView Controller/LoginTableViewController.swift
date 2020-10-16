//
//  LoginTableViewController.swift
//  Gropare
//
//  Created by Danish Munir on 07/10/2020.
//

import UIKit
import MaterialComponents.MaterialSnackbar



class LoginTableViewController: UITableViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    //MARK: - Variables
    var indicator =  UIActivityIndicatorView()
    let snackManager = MDCSnackbarManager()
    let snackBarMessage = MDCSnackbarMessage()
    let alert = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)
    
    let http = HTTPService()
    //9633048339 (registred Number)
    //123456   (password)
    
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loginBtn.layer.cornerRadius = 5
        onTapClick(target: self, #selector(dismissKeyboard))
        phoneTF.text = "9633048339"
        passwordTF.text = "123456"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    
    //MARK: - Actions
    @IBAction func backBtnTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func forgotPasswordBtnTapped(_ sender: Any) {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(identifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func loginBtntapped(_ sender: Any) {
        let phone = phoneTF.text ?? ""
        let password = passwordTF.text ?? ""
        
        if phone != "" {
            
            if password != "" {
                DispatchQueue.main.async { [self] in
                    loadindIndicator()
                }
                
                http.requestWithPost(parameters: ["user_phone": phone, "user_password": password], Url: Endpoints.login) { [self] (response, error) in
                    
                    if response != nil {
                        
                        DispatchQueue.main.async {
                            self.dismissAlert()
                        }
                        let jsonData = response!.toJSONString1().data(using: .utf8)!
                        let decoder = JSONDecoder()
                        let obj = try! decoder.decode(LoginResponse.self, from: jsonData)
                        
                        if obj.status == "0"{
                            //Login failed
                            print(obj.message)
                            snackBarMessage(snackManager: snackManager, snackBarMessage: snackBarMessage, title: "\(obj.message)")
                            
                        }
                        else{
                            DispatchQueue.main.async {
                                
                                if let obj  = obj.data{
                                    for array in obj{
                                        if let user_id  = array.userID{
                                            saveStringInDefault(value: user_id , key: "user_id")
                                        }
                                        if let user_name  = array.userName{
                                            saveStringInDefault(value: user_name , key: "user_name")
                                        }
                                        if let user_phone  = array.userPhone{
                                            saveStringInDefault(value: user_phone , key: "user_phone")
                                        }
                                        if let user_email  = array.userEmail{
                                            saveStringInDefault(value: user_email , key: "user_email")
                                        }
                                        if let device_id  = array.deviceID{
                                            saveStringInDefault(value: device_id , key: "device_id")
                                        }
                                        if let user_password  = array.userPassword{
                                            saveStringInDefault(value: user_password , key: "user_password")
                                        }
                                        if let otp_value  = array.otpValue{
                                            saveStringInDefault(value: otp_value , key: "otp_value")
                                        }
                                        if let status  = array.status{
                                            saveStringInDefault(value: status , key: "status")
                                        }
                                        if let wallet  = array.wallet{
                                            saveStringInDefault(value: wallet , key: "wallet")
                                        }
                                        if let rewards  = array.rewards{
                                            saveStringInDefault(value: rewards , key: "rewards")
                                        }
                                        if let is_verified  = array.isVerified{
                                            saveStringInDefault(value: is_verified , key: "is_verified")
                                        }
                                        if let block  = array.block{
                                            saveStringInDefault(value: block , key: "block")
                                        }
                                        if let reg_date  = array.regDate{
                                            saveStringInDefault(value: reg_date , key: "reg_date")
                                        }
                                    }
                                }
                                
                                
                                UserDefaults.standard.setValue(true, forKey: "activateLogin")
                                
                                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                let tabBarViewController = mainStoryboard.instantiateViewController(withIdentifier: "LandingTabbarViewController") as! LandingTabbarViewController
                                tabBarViewController.tabBar.barTintColor = .white
                                tabBarController?.tabBar.backgroundColor = .green
                                tabBarViewController.selectedIndex = 0
                                UIApplication.shared.keyWindow?.rootViewController = tabBarViewController
                                
                            }
                            
                            
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            snackBarMessage(snackManager: snackManager, snackBarMessage: snackBarMessage, title: "\(error?.localizedDescription ?? "")")
                        }
                        
                    }
                }
            }
            else{
                snackBarMessage(snackManager: snackManager, snackBarMessage: snackBarMessage, title: "Enter your Password")
            }
            
        }
        else{
            snackBarMessage(snackManager: snackManager, snackBarMessage: snackBarMessage, title: "Enter your phone Number")
        }
        
        
    }
    
    
    //MARK: - Functions
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    func loadindIndicator(){
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.large
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    
    internal func dismissAlert() {
        if let vc = self.presentedViewController, vc is UIAlertController {
            dismiss(animated: false, completion: nil)
            
        }
    }
    
    
}


//MARK: - TableView Functions
extension LoginTableViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
}

