//
//  SubCatagoryProductViewController.swift
//  Gropare
//
//  Created by Danish Munir on 13/10/2020.
//

import UIKit
import CoreData


class SubCatagoryProductViewController: UIViewController {
    var catID : Int?
    @IBOutlet weak var tableView: UITableView!
    var http = HTTPService()
    var arrCart = [CartItem]()
    var cartArray : [databaseCart] = []
    var subCatagoryProducts = [CatagoryProducts_Datum]()
    
    //MARK:- CoreData
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate //Singlton instance
    var context:NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "LandingPopularMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "LandingPopularMenuTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        catagoryGetData()
    }

  
}

extension SubCatagoryProductViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subCatagoryProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "LandingPopularMenuTableViewCell", for: indexPath) as! LandingPopularMenuTableViewCell
//        cell.countButton.addTarget(self, action: #selector(countBtnTapped(sender:)), for: .touchUpInside)
        let cell = tableView.dequeueReusableCell(withIdentifier: "LandingPopularMenuTableViewCell", for: indexPath) as! LandingPopularMenuTableViewCell
       
        cell.addButton.tag = indexPath.row
        cell.countButton.tag = indexPath.row
        cell.subtractButton.tag = indexPath.row
        let index = subCatagoryProducts[indexPath.row]
        let count = searchItemInCart(vId: subCatagoryProducts[indexPath.row].varientID!)
        if count != 0{
            cell.priceLbl.text = "\(Double(subCatagoryProducts[indexPath.row].price!) * Double(count))"
            cell.countButton.setTitle(String(count), for: .normal)
            cell.countButton.backgroundColor = .white
            cell.addButton.isHidden = false
            cell.subtractButton.isHidden = false
        }
        else{
            cell.priceLbl.text = "\(subCatagoryProducts[indexPath.row].price ?? 0)"
            cell.countButton.setTitle("+", for: .normal)
            cell.countButton.backgroundColor = UIColor(named: "Greenish")
            cell.addButton.isHidden = true
            cell.subtractButton.isHidden = true
        }
        

        
        
        //MARK:-  Add or Decrease Numbers in cart
        
        cell.tapBlock = { [self] in
          
            saveData(productName: subCatagoryProducts[indexPath.row].productName!, variendID: subCatagoryProducts[indexPath.row].varientID!)
            DispatchQueue.main.async {
                tableView.reloadData()
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                addItemsServerHit(qty: Int((cell.countButton.titleLabel?.text)!)! , varient_id: subCatagoryProducts[indexPath.row].varientID!, store_id: subCatagoryProducts[indexPath.row].storeID!)
            }
            
            
        }
        cell.addNumber = { [self] in
            saveData(productName: subCatagoryProducts[indexPath.row].productName!, variendID: subCatagoryProducts[indexPath.row].varientID!)
            DispatchQueue.main.async {
                tableView.reloadData()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                addItemsServerHit(qty: Int((cell.countButton.titleLabel?.text)!)! , varient_id: subCatagoryProducts[indexPath.row].varientID!, store_id: subCatagoryProducts[indexPath.row].storeID!)
            }
            
        }
        cell.decreaseNumber = { [self] in
            deleteFeed(id: subCatagoryProducts[indexPath.row].varientID!)
            DispatchQueue.main.async {
                tableView.reloadData()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if cell.countButton.titleLabel?.text! != "+"{
                    addItemsServerHit(qty: Int((cell.countButton.titleLabel?.text)!)! , varient_id: subCatagoryProducts[indexPath.row].varientID!, store_id: subCatagoryProducts[indexPath.row].storeID!)
                }
                else {
                    addItemsServerHit(qty: 0 , varient_id: subCatagoryProducts[indexPath.row].varientID!, store_id: subCatagoryProducts[indexPath.row].storeID!)
                }
            }
        }
//        cell.configureCell(products: arrListing[indexPath.row])
        cell.configureCellByCatagoryProducts(products: subCatagoryProducts[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(identifier: "SubSubCatagoryViewController") as! SubSubCatagoryViewController
        vc.subCatagoryProducts = subCatagoryProducts
        vc.selectedIndex = indexPath.row
        vc.products = subCatagoryProducts[indexPath.row]
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}


extension SubCatagoryProductViewController {

    func catagoryGetData() {
        let dict = ["cat_id": catID, "lat":"12.70","lng":"74.94", "city":"Manjeshwar"] as [String : Any]
        http.requestWithPost(parameters: dict, Url: Endpoints.catagoryProducts) { (response, error) in
            let jsonData = response?.toJSONString1().data(using: .utf8)
            let decoder = JSONDecoder()
            do {
            let obj = try decoder.decode(CatagoryProducts.self, from: jsonData!)
            if obj.status == "1" {
                if let arrayofBanner = obj.data{
                    _ = arrayofBanner.map{
                        self.subCatagoryProducts.append($0)
                    }
                }
                dump(obj)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
            else{
                print(obj.message as Any)
            }
        }catch{
            print("check error")
        }
        }
    }
}

//MARK: Core Data Save,Fetch And Search
extension SubCatagoryProductViewController {
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
extension SubCatagoryProductViewController {
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
