//
//  HelperViewController.swift
//  Gropare
//
//  Created by Danish Munir on 07/10/2020.
//


import UIKit

class HelperViewController: UIViewController {
    let obj =   HTTPService()
    var indicator =  UIActivityIndicatorView()
    let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async { [self] in
            loadindIndicator()
        }
        
        
        let parameters: [String: Any] = ["user_email": "immmi@gmail.com","user_password": "1234566","user_name": "12345","user_phone":"9633048339","device_id" : "testingsimulater"]
        let dict = ["user_password":"123456","user_phone":"9633048331","device_id":"testingsimulater"]
        
        
        //MARK:  Register Api
        
        obj.requestWithPost(parameters: parameters, Url: Endpoints.resgister_ios) { (response, error) in
            if response != nil{
                
                DispatchQueue.main.async {
                    self.dismissAlert()
                }
                let jsonData = response!.toJSONString1().data(using: .utf8)!
                let decoder = JSONDecoder()
                let obj = try! decoder.decode(Register.self, from: jsonData)
                dump(obj)
                if obj.status == "0"{
                    print(obj.message)
                }
                else{
                    if obj.data?.isVerified == 0{
                        print("User not Variefied")
                    }
                    else{
                        
                    }
                }
            }
            else{
                
            }
        }
        
        
        //MARK: Login APi
        
        obj.requestWithPost(parameters: dict , Url: Endpoints.login) { (response, error) in
            if response != nil{
                let jsonData = response!.toJSONString1().data(using: .utf8)!
                let decoder = JSONDecoder()
                let obj = try! decoder.decode(LoginResponse.self, from: jsonData)
                if let obj1 = obj.data{
                    for d in obj1
                    {
                        
                    }
                }
                
                if obj.status == "0"
                {
                    DispatchQueue.main.async {
                        self.dismissAlert()
                    }
                    print(obj.message)
                }
                else{
                    DispatchQueue.main.async {
                        self.dismissAlert()
                    }
                    dump(obj)
                }
                
            }
            else{
                DispatchQueue.main.async {
                    self.dismissAlert()
                }
                
            }
            
        }
        
    }
    
    func loadindIndicator(){
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 25, height: 25))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    
    internal func dismissAlert() {
        if let vc = self.presentedViewController, vc is UIAlertController {
            dismiss(animated: false, completion: nil)
            
        }
    }
}
