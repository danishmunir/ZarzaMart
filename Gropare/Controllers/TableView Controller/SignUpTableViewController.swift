//
//  SignUpTableViewController.swift
//  Gropare
//
//  Created by Danish Munir on 07/10/2020.
//

import UIKit
import MaterialComponents.MaterialSnackbar

class SignUpTableViewController: UITableViewController {
    //0968289823313
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var mobileNoTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    
    let snackManager = MDCSnackbarManager()
    let snackBarMessage = MDCSnackbarMessage()
    let http = HTTPService()
    var indicator =  UIActivityIndicatorView()
    let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signUpBtn.layer.cornerRadius = 5
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func forgotPasswordBtnTapped(_ sender: Any) {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(identifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func signUpBtntapped(_ sender: Any) {
        
        
        let userName = userNameTF.text ?? ""
        let mobileNo = mobileNoTF.text ?? ""
        let email = emailTF.text ?? ""
        let password = passwordTF.text ?? ""
        
        if userName != "" && mobileNo != "" && email != "" && password != ""{
            http.requestWithPost(parameters: ["user_email": email, "user_password": password, "user_name": userName, "user_phone": mobileNo , "device_id" : "iphone 8"], Url: Endpoints.resgister_ios) { [self] (response, error) in
                dump(response)
                if response != nil {
                    
                    DispatchQueue.main.async {
                        self.dismissAlert()
                    }
                    let jsonData = response!.toJSONString1().data(using: .utf8)!
                    let decoder = JSONDecoder()
                    let obj = try! decoder.decode(Register.self, from: jsonData)
                    
                    if obj.status == "0"{
                        snackBarMessage(snackManager: snackManager, snackBarMessage: snackBarMessage, title: "\(obj.message ?? "")")
                    }
                    else{
                        print(obj)
                        snackBarMessage(snackManager: snackManager, snackBarMessage: snackBarMessage, title: "Contact Registered Successfully.")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            let story = UIStoryboard(name: "Main", bundle: nil)
                            let vc = story.instantiateViewController(identifier: "OTPVerificationTableViewController") as! OTPVerificationTableViewController
                            vc.phoneNumberSt = obj.data?.userPhone
                            navigationController?.pushViewController(vc, animated: true)
                        }
                        
                    }
                } else {
                    snackBarMessage(snackManager: snackManager, snackBarMessage: snackBarMessage, title: "\("Check  Phone Number" ?? "")")
                }
            }
        } else {
            snackBarMessage(snackManager: snackManager, snackBarMessage: snackBarMessage, title: "Fill all the blanks.")
        }
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



extension SignUpTableViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}
