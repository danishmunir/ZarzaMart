//
//  WalletViewController.swift
//  Gropare
//
//  Created by Danish Munir on 14/10/2020.
//

import UIKit

class WalletViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    @IBAction func rechargeWalletTapped(_ sender: Any) {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(identifier: "RewardRechargeViewController") as! RewardRechargeViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

}
