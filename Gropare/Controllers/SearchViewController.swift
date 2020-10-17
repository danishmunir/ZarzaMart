//
//  SearchViewController.swift
//  Gropare
//
//  Created by Danish Munir on 13/10/2020.
//

import UIKit

class SearchViewController: UIViewController {
    var arrListing = [Search_Varient]()
    let http = HTTPService()
    var arrSearch = [Search_Datum]()
    @IBOutlet weak var tableView: UITableView!
    let activity = UIActivityIndicatorView()
    
    let searchController = UISearchController()
    
    override func viewDidLoad() {
        activity.color = .gray
        activity.startAnimating()
        activity.center = view.center
        super.viewDidLoad()
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self
 
    }

}


extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSearch.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = arrSearch[indexPath.row].productName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(identifier: "searchProductViewController") as! searchProductViewController
        vc.fromSearchView = true
        vc.searchedproductId =  arrSearch[indexPath.row].productID!
        navigationController?.pushViewController(vc, animated: true)
    }
    
}


extension SearchViewController: UISearchBarDelegate {
 
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchKeyword = searchBar.text{
        SearchList(keyword : searchKeyword)
        }
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        if let searchKeyword = searchBar.text{
//        SearchList(keyword : searchKeyword)
//        }
    }
}

extension SearchViewController {
    func SearchList(keyword  : String) {
        arrSearch.removeAll()
        let dict = ["keyword":keyword,"lat":"12.70","lng":"74.94", "city":"Manjeshwar"]
        
        http.requestWithPost(parameters: dict, Url: Endpoints.searchData) { [self] (response, error) in
            DispatchQueue.main.async { [self] in
                let jsonData = response?.toJSONString1().data(using: .utf8)
                let decoder = JSONDecoder()
                do{
                let obj = try decoder.decode(Search.self, from: jsonData!)
                if obj.status == "1"{
                    if let arrayofBanner = obj.data{
                        _ = arrayofBanner.map{
                            self.arrSearch.append($0)
                        }
                    }
                    tableView.reloadData()
                    activity.stopAnimating()
                }
                else{
                    print(obj.message as Any)
                }
            }
                catch{
                    
                }
            }
            
        }
    }
}
