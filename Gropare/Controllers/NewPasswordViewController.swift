//
//  NewPasswordViewController.swift
//  Gropare
//
//  Created by Danish Munir on 08/10/2020.
//

import UIKit

class NewPasswordViewController: UIViewController {
    let http = HTTPService()
    var userPhonenumber : String?
    @IBOutlet weak var newPaswword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    

    
    @IBAction func BackBtnTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction  func submitNewPasswordBtntaped() {
        
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(identifier: "LoginTableViewController") as! LoginTableViewController
        navigationController?.pushViewController(vc, animated: true)
    }

    
    
   func serverHitForNewPassword(){
    let dict = ["user_password":newPaswword.text!,"user_phone": userPhonenumber!] as [String : Any]
    http.requestWithPost(parameters: dict, Url: Endpoints.change_password) { (response, error) in
        
        DispatchQueue.main.async {
           
            let jsonData = response?.toJSONString1().data(using: .utf8)!
            let decoder = JSONDecoder()
            let obj = try! decoder.decode(changePassword.self, from: jsonData!)
            if obj.status == "1" {
                DispatchQueue.main.async { [self] in
                    let alert = UIAlertController(title: "Successful", message: "Password changed Successfuly", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                           UIAlertAction in
                        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier: "LandingTabbarViewController") as! LandingTabbarViewController
                        self.navigationController?.pushViewController(viewController, animated: true)
                       }
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
                
                
            } else {
                print("error")
            }
        }

    }
    }
}
