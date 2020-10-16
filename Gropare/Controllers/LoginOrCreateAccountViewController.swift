//
//  LoginViewController.swift
//  Gropare
//
//  Created by Danish Munir on 07/10/2020.
//

import UIKit

class LoginOrCreateAccountViewController: UIViewController {
    
   
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var createAccountBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginBtn.layer.cornerRadius = 5
        createAccountBtn.layer.cornerRadius = 5
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: IBActions
    @IBAction func LoginBtnTapped() {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(identifier: "LoginTableViewController") as! LoginTableViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func createBtnPresed() {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(identifier: "SignUpTableViewController") as! SignUpTableViewController
        navigationController?.pushViewController(vc, animated: true)
    }
}




