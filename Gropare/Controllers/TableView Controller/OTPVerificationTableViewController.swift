//
//  OTPVerificationTableViewController.swift
//  Gropare
//
//  Created by Danish Munir on 07/10/2020.
//

import UIKit

class OTPVerificationTableViewController: UITableViewController {
    @IBOutlet weak var verifyBtn: UIButton!
    
    var phoneNumber: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        verifyBtn.layer.cornerRadius = 5
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
   
    @IBAction func backBtnTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}


extension OTPVerificationTableViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .zero
    }
}
