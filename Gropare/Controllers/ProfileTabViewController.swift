//
//  ProfileTabViewController.swift
//  Gropare
//
//  Created by Danish Munir on 14/10/2020.
//

import UIKit

class ProfileTabViewController: UIViewController {

    @IBOutlet weak var iconsView: UIView!
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var listTblView: UITableView!
    @IBOutlet weak var cartStackView: UIStackView!
    @IBOutlet weak var walletStackView: UIStackView!
    @IBOutlet weak var rewardStackView: UIStackView!
    @IBOutlet weak var ordersStackView: UIStackView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    
    
    let http = HTTPService()
    
    var listImage = ["profile", "profileicon", "Terms", "share", "Logout"]
    var listTitle = ["My Profile", "About Us", "Terms and policy" , "Share with Friends", "Logout"]
    var arrMyProfile = [myProfile_DataClass]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLbl.text = UserDefaults.standard.string(forKey: "user_name")
        emailLbl.text = UserDefaults.standard.string(forKey: "user_email")
        listTblView.register(UINib(nibName: "ProfileTabListTableViewCell", bundle: nil), forCellReuseIdentifier: "ProfileTabListTableViewCell")
        iconsView.layer.cornerRadius = 10
        listView.layer.cornerRadius = 10
        setUPTaps()
      
    }
    
    func setUPTaps() {
        let cartTap = UITapGestureRecognizer(target: self, action: #selector(cartTapped))
        cartStackView.addGestureRecognizer(cartTap)
        let walletTap = UITapGestureRecognizer(target: self, action: #selector(walletTapped))
        walletStackView.addGestureRecognizer(walletTap)
        let rewardTap = UITapGestureRecognizer(target: self, action: #selector(rewardTapped))
        rewardStackView.addGestureRecognizer(rewardTap)
        let orderTap = UITapGestureRecognizer(target: self, action: #selector(orderTapped))
        ordersStackView.addGestureRecognizer(orderTap)
    }
    
    @objc func cartTapped() {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(identifier: "CartViewController") as! CartViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func walletTapped() {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(identifier: "WalletViewController") as! WalletViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func rewardTapped() {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc  = story.instantiateViewController(identifier: "RewardViewController") as! RewardViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func orderTapped() {
        let story = UIStoryboard(name: "Checkout", bundle: nil)
        let vc  = story.instantiateViewController(identifier: "OrderVC") as! OrderVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


extension ProfileTabViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTabListTableViewCell", for: indexPath) as! ProfileTabListTableViewCell
        cell.iconImageView.image = UIImage(named: "\(listImage[indexPath.row])")
        cell.Lbl.text = listTitle[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let story = UIStoryboard(name: "Main", bundle: nil)
            let vc = story.instantiateViewController(identifier: "ProfileTableViewController") as! ProfileTableViewController
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 1 {
            let story = UIStoryboard(name: "Main", bundle: nil)
            let vc = story.instantiateViewController(identifier: "AboutUsViewController") as! AboutUsViewController
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 2 {
            let story = UIStoryboard(name: "Main", bundle: nil)
            let vc = story.instantiateViewController(identifier: "TermsAndPolicyViewController") as! TermsAndPolicyViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if indexPath.row == 3 {
            let items = ["This app is my favorite itms-apps://itunes.apple.com/app/id1534372332"]
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            self.present(ac, animated: true)
        }
        else if indexPath.row == 4 {
            UserDefaults.standard.setValue(false, forKey: "activateLogin")
            let story = UIStoryboard(name: "Main", bundle: nil)
            let vc = story.instantiateViewController(identifier: "LoginTableViewController") as! LoginTableViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

