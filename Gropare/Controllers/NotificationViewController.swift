//
//  NotificationViewController.swift
//  Gropare
//
//  Created by Danish Munir on 13/10/2020.
//

import UIKit

class NotificationViewController: UIViewController {
    
    let http = HTTPService()
    var arrNotify = [Notifications_Datum]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getNotificationsData()
        tableView.register(UINib(nibName: "NotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "NotificationTableViewCell")
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 60
    }
    
    
}

extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrNotify.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as! NotificationTableViewCell
        cell.HeaderLAbel.text = arrNotify[indexPath.row].notiTitle
        cell.descriptionLAbel.text = arrNotify[indexPath.row].notiMessage
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}


extension NotificationViewController {
    
    
    func getNotificationsData() {
        let dict = ["user_id": UserDefaults.standard.string(forKey: "user_id")]
        http.requestWithPost(parameters: dict, Url: Endpoints.notifyData) { (response, error) in
            
            guard let jsonData = response?.toJSONString1().data(using: .utf8) else { return }
            let decoder = JSONDecoder()
            let obj = try! decoder.decode(Notifications.self, from: jsonData)
            if obj.status == "1" {
                if let arrayofBanner = obj.data{
                    _ = arrayofBanner.map{
                        self.arrNotify.append($0)
                    }
                }
                dump(obj)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
            else{
                print(obj.message)
            }
        }
    }
    
    
}
