//
//  RewardViewController.swift
//  Gropare
//
//  Created by Danish Munir on 14/10/2020.
//

import UIKit

class RewardViewController: UIViewController {

    let http = HTTPService()
    @IBOutlet weak var rewardLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        serverHitForReward()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func redeemTapped(_ sender: Any) {
        serverHitForReward()
    }
    
}


extension RewardViewController {
    func serverHitForReward() {
        let dict =  ["user_id":UserDefaults.standard.string(forKey: "user_id")]
        http.requestWithPost(parameters: dict as [String : Any], Url: Endpoints.profileURL) { [self] (response, error) in
            DispatchQueue.main.async { [self] in
                let jsonData = response?.toJSONString1().data(using: .utf8)
                let decoder = JSONDecoder()
                do {
                    let obj = try decoder.decode(Register.self, from: jsonData!)
                    if let objData = obj.data{
                        rewardLabel.text = "\(objData.rewards!)"
                    }
                    else{
                        print(error?.localizedDescription as Any)
                    }
                }
                catch {
                    print(error.localizedDescription)
                }
                
            }
        }
    }
}
