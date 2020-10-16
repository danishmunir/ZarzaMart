//
//  NewPasswordViewController.swift
//  Gropare
//
//  Created by Danish Munir on 08/10/2020.
//

import UIKit

class NewPasswordViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction override func BackBtnTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction  func submitNewPasswordBtntaped() {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(identifier: "LoginTableViewController") as! LoginTableViewController
        navigationController?.pushViewController(vc, animated: true)
    }

}
