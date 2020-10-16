//
//  RewardRechargeViewController.swift
//  Gropare
//
//  Created by Danish Munir on 14/10/2020.
//

import UIKit
import Razorpay



class RewardRechargeViewController: UIViewController, RazorpayPaymentCompletionProtocol {
    
    @IBOutlet weak var amountTF: UITextField!
    
    var razorpay: RazorpayCheckout!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        razorpay = RazorpayCheckout.initWithKey("rzp_live_t035qo7CXDi9Pp", andDelegate: self)
    }
    
    
    @IBAction func recharBtnTapped(_ sender: Any) {
        if amountTF.text != ""{
            showPaymentForm()
        }
        
    }
    
}


extension RewardRechargeViewController {
    func showPaymentForm(){
        let options: [String:Any] = [
            "amount": Int(amountTF.text!)! * 100, //This is in currency subunits. 100 = 100 paise= INR 1.
            "currency": "INR",//We support more that 92 international currencies.
            "description": "Zarza Mart",
            "image": "http://admin.zarzamart.com/images/app_logo/08-09-2020/zAZRA-lOGO-FOR-APP-01.png",
            "name": UserDefaults.standard.string(forKey: "user_name")!,
            "prefill": [
                "contact": UserDefaults.standard.string(forKey: "user_phone"),
                "email": UserDefaults.standard.string(forKey: "user_email")
            ],
            "theme": [
                "color": "#A91F4E"
            ]
        ]
        razorpay.open(options)
    }
    func onPaymentError(_ code: Int32, description str: String) {
        let alertController = UIAlertController(title: "FAILURE", message: str, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.view.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    func onPaymentSuccess(_ payment_id: String) {
        let alertController = UIAlertController(title: "SUCCESS", message: payment_id, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.view.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
}
