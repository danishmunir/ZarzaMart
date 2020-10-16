//
//  ForgotPasswordViewController.swift
//  Gropare
//
//  Created by Danish Munir on 08/10/2020.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        let slideTap = UISwipeGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        slideTap.direction = .down
        
        view.addGestureRecognizer(slideTap)
        
    }
    

    @IBAction override func BackBtnTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
        
    }
    
    @IBAction  func verifyBtnTapped() {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(identifier: "EnterCodeViewController") as! EnterCodeViewController
        navigationController?.pushViewController(vc, animated: true)
    }

}
