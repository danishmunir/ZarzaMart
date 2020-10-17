//
//  OTPVerificationTableViewController.swift
//  Gropare
//
//  Created by Danish Munir on 07/10/2020.
//

import UIKit
import KKPinCodeTextField
class OTPVerificationTableViewController: UITableViewController {
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var otpTF: KKPinCodeTextField!
    @IBOutlet weak var verifyBtn: UIButton!
    let http = HTTPService()
    var phoneNumberSt: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        verifyBtn.layer.cornerRadius = 5
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
        
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        phoneNumber.text = phoneNumberSt
        navigationController?.navigationBar.isHidden = true
    }
   
    @IBAction func backBtnTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func verifyOTP(_ sender: UIButton) {
        if let otp = otpTF.text
        { if let phonenumber = phoneNumberSt{
            serverHitOTP(otp: otp, phone: phonenumber)
        }
        }
    }
    
    func serverHitOTP(otp : String , phone : String) {
        let dict = ["otp":otp,"user_phone":phone]
        http.requestWithPost(parameters: dict, Url: Endpoints.verify_phone) { (responseData, error) in
            DispatchQueue.main.async {
               
                let jsonData = responseData?.toJSONString1().data(using: .utf8)!
                let decoder = JSONDecoder()
                let obj = try! decoder.decode(OTP.self, from: jsonData!)
                if obj.status == 1 {
                    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "LandingTabbarViewController") as! LandingTabbarViewController
                    self.navigationController?.pushViewController(viewController, animated: true)
                    
                } else {
                    print("error")
                }
            }
        }
    }
    
}


extension OTPVerificationTableViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .zero
    }
}
