//
//  ViewAllSearchProductsViewController.swift
//  Gropare
//
//  Created by Muhammad Imran on 16/10/2020.
//

import UIKit
import CoreData
class ViewAllSearchProductsViewController: UIViewController {

    
    var arrListing = [Search_Varient]()
    var selected  =  Int()
    var cartArray : [databaseCart] = []
    var arrCart = [CartItem]()
    @IBOutlet weak var tableView: UITableView!
    let activity = UIActivityIndicatorView()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate //Singlton instance
    var context:NSManagedObjectContext!
    
    let http = HTTPService()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "LandingPopularMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "LandingPopularMenuTableViewCell")
     
    }
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
}
extension ViewAllSearchProductsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrListing.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LandingPopularMenuTableViewCell", for: indexPath) as! LandingPopularMenuTableViewCell
        cell.addButton.tag = indexPath.row
        cell.countButton.tag = indexPath.row
        cell.subtractButton.tag = indexPath.row
        let index = arrListing[indexPath.row]
        let count = searchItemInCart(vId: arrListing[indexPath.row].varientID!)
        if count != 0{
            cell.priceLbl.text = "\(Double(arrListing[indexPath.row].price!) * Double(count))"
            cell.countButton.setTitle(String(count), for: .normal)
            cell.countButton.backgroundColor = .white
            cell.addButton.isHidden = false
            cell.subtractButton.isHidden = false
        }
        else{
            cell.priceLbl.text = "\(arrListing[indexPath.row].price ?? 0)"
            cell.countButton.setTitle("+", for: .normal)
            cell.countButton.backgroundColor = UIColor(named: "Greenish")
            cell.addButton.isHidden = true
            cell.subtractButton.isHidden = true
        }
        

        
        
        //MARK:-  Add or Decrease Numbers in cart
        
        cell.tapBlock = { [self] in
          
            saveData(productName: arrListing[indexPath.row].varientDescription!, variendID: arrListing[indexPath.row].varientID!)
            DispatchQueue.main.async {
                tableView.reloadData()
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                addItemsServerHit(qty: Int((cell.countButton.titleLabel?.text)!)! , varient_id: arrListing[indexPath.row].varientID!, store_id: arrListing[indexPath.row].storeID!)
            }
            
            
        }
        cell.addNumber = { [self] in
            saveData(productName: arrListing[indexPath.row].varientDescription!, variendID: arrListing[indexPath.row].varientID!)
            DispatchQueue.main.async {
                tableView.reloadData()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                addItemsServerHit(qty: Int((cell.countButton.titleLabel?.text)!)! , varient_id: arrListing[indexPath.row].varientID!, store_id: arrListing[indexPath.row].storeID!)
            }
            
        }
        cell.decreaseNumber = { [self] in
            deleteFeed(id: arrListing[indexPath.row].varientID!)
            DispatchQueue.main.async {
                tableView.reloadData()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if cell.countButton.titleLabel?.text! != "+"{
                    addItemsServerHit(qty: Int((cell.countButton.titleLabel?.text)!)! , varient_id: arrListing[indexPath.row].varientID!, store_id: arrListing[indexPath.row].storeID!)
                }
                else {
                    addItemsServerHit(qty: 0 , varient_id: arrListing[indexPath.row].varientID!, store_id: arrListing[indexPath.row].storeID!)
                }
            }
        }
        cell.Search_VarientConfigureCell(products: index)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(identifier: "ViewAllSearchProductsViewController") as! ViewAllSearchProductsViewController
        vc.arrListing = arrListing
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}


//MARK: Core Data Save,Fetch And Search
extension ViewAllSearchProductsViewController {
    func saveData(productName : String , variendID : Int)
    {
        context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Cart", in: context)
        let newItem = NSManagedObject(entity: entity!, insertInto: context)
        newItem.setValue(productName, forKey: "productName")
        newItem.setValue(1, forKey: "value")
        newItem.setValue(variendID, forKey: "varientId")
        print("Storing Data..")
        do {
            try context.save()
        } catch {
            print("Storing data Failed")
        }
        fetchData()
        
    }
    func fetchData()
    {
        
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Cart")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result {
                let pn = data.value(forKey: "productName") as! String
                let val = data.value(forKey: "value") as! Int
                let vId = data.value(forKey: "varientId") as! Int
                let db =  databaseCart(productName: pn, value: val, varientId: vId)
                
                cartArray.append(db)
                
            }
            dump(cartArray)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func searchItemInCart(vId: Int) -> Int
    {
        var count: Int = 0
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
        let searchString = vId
        //            request.predicate = NSPredicate(format: "varientId == %@", searchString)
        request.predicate   = NSPredicate(format: "varientId = %d", searchString)
        do {
            let result = try context.fetch(request)
            if result.count > 0 {
                for online in result {
                    let v = (online as AnyObject).value(forKey: "varientId") as? String
                    print(v as Any)
                }
                count = result.count
            } else {
                
            }
            
        } catch {
            print(error)
        }
        
        return count
    }
    func deleteFeed(id:Int)
    {
        var flag : Bool = false

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
        let searchString = id
        request.predicate   = NSPredicate(format: "varientId = %d", searchString)
        do {
            let result = try context.fetch(request)
            if result.count > 0 {
                for entity in result {
                    if !flag{
                        context.delete(entity as! NSManagedObject)
                    flag = true
                    }
                }
                try context.save()
                flag = false
            } else {
                
            }
            
        } catch {
            print(error)
        }
      
    }
}

//MARK: API Server Hit
extension ViewAllSearchProductsViewController {
    func addItemsServerHit(qty : Int , varient_id : Int , store_id : Int) {
        addCart(qty: qty, varient_id: varient_id  , store_id: store_id) { [self] (response, error) in
            if response != nil{
                if let arrayofBanner = response?.cartItems{
                    _ = arrayofBanner.map{
                        arrCart.append($0)
                    }
                    tableView.reloadData()
                }
            }
            else{
                //error
            }
        }
    }
}
