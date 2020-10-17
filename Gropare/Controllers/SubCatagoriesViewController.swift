//
//  SubCatagoriesViewController.swift
//  Gropare
//
//  Created by Danish Munir on 12/10/2020.
//

import UIKit

class SubCatagoriesViewController: UIViewController {

    
    var arrSubCatagory = [ExpendCategory_Data]()
    var subcat = [String]()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.separatorStyle = .none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
}

extension SubCatagoriesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSubCatagory.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = arrSubCatagory[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(identifier: "SubCatagoryProductViewController") as! SubCatagoryProductViewController
        vc.catID = arrSubCatagory[indexPath.row].catID
        navigationController?.pushViewController(vc, animated: true)
    }
 
}
