//
//  ForgotPasswordViewController.swift
//  Gropare
//
//  Created by Danish Munir on 08/10/2020.
//

import UIKit

class ForgotPasswordViewController: UIViewController {
    @IBOutlet weak var phoneNumberField: UITextField!
    let http = HTTPService()
    var arrListing = [OTPResult_Datum]()
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
    
    
    
    @IBAction  func verifyBtnTapped() {
       servertHitCode()
    }
    
    
    
    func servertHitCode(){
        let dict = ["user_phone":phoneNumberField.text!]
        http.requestWithPost(parameters: dict, Url: Endpoints.forget_password) { (response, error) in
            if response != nil{
                DispatchQueue.main.async { [self] in
                    let jsonData = response?.toJSONString1().data(using: .utf8)
                    let decoder = JSONDecoder()
                    let obj = try! decoder.decode(OTPResult.self, from: jsonData!)
                    if obj.status == "1"{
                        if let arrayofBanner = obj.data{
                            _ = arrayofBanner.map{
                                self.arrListing.append($0)
                            }
                        }
                        let story = UIStoryboard(name: "Main", bundle: nil)
                        let vc = story.instantiateViewController(identifier: "EnterCodeViewController") as! EnterCodeViewController
                        vc.OTP = arrListing[0].otpValue
                        vc.number = arrListing[0].userPhone
                        self.navigationController?.pushViewController(vc, animated: true)

                    }
                    
                }
            }
        }
    }

}
