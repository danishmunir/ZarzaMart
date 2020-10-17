//
//  EnterCodeViewController.swift
//  Gropare
//
//  Created by Danish Munir on 08/10/2020.
//

import UIKit

class EnterCodeViewController: UIViewController {
    @IBOutlet weak var numberLbl: UILabel!
    @IBOutlet weak var OTPTF: UITextField!
    var number : String?
    var OTP : String?
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        numberLbl.text = number
    }
    @IBAction func BackBtnTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction  func verifyBtnTapped() {
        if OTPTF.text != ""{
            if OTPTF.text! == OTP!{
                let story = UIStoryboard(name: "Main", bundle: nil)
                let vc = story.instantiateViewController(identifier: "NewPasswordViewController") as! NewPasswordViewController
                vc.userPhonenumber = number
                navigationController?.pushViewController(vc, animated: true)
            }
            
        }
        
      
      
    }
}
