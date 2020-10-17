//
//  CartViewController.swift
//  Gropare
//
//  Created by Danish Munir on 13/10/2020.
//

import UIKit
import CoreData

class CartViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noOfItemsLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    var cartArray : [databaseCart] = []
    var arrCartNew = [CartItem]()
    
    //MARK:- CoreData
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate //Singlton instance
    var context:NSManagedObjectContext!
    
    var arrCart = [CartItems_Datum]()
    var http = HTTPService()
    let activity = UIActivityIndicatorView()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activity.color = .gray
        activity.startAnimating()
        activity.center = view.center
        tableView.register(UINib(nibName: "LandingPopularMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "LandingPopularMenuTableViewCell")
        cartList()
    }
    
    
    @IBAction func continueBtnTapped(_ sender: Any) {
        let story = UIStoryboard(name: "Checkout", bundle: nil)
        let vc = story.instantiateViewController(identifier: "OrderSummaryViewController") as! OrderSummaryViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    

}

extension CartViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCart.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LandingPopularMenuTableViewCell", for: indexPath) as! LandingPopularMenuTableViewCell
        cell.configureCellByCart(products: arrCart[indexPath.row])
        cell.addButton.tag = indexPath.row
        cell.countButton.tag = indexPath.row
        cell.subtractButton.tag = indexPath.row
        let count = searchItemInCart(vId: arrCart[indexPath.row].varientID!)
        if count != 0{
            cell.priceLbl.text = "\(Double(arrCart[indexPath.row].price!) * Double(count))"
            cell.countButton.setTitle(String(count), for: .normal)
            cell.countButton.backgroundColor = .white
            cell.addButton.isHidden = false
            cell.subtractButton.isHidden = false
        }
        else{
            cell.priceLbl.text = "\(arrCart[indexPath.row].price ?? 0)"
            cell.countButton.setTitle("+", for: .normal)
            cell.countButton.backgroundColor = UIColor(named: "Greenish")
            cell.addButton.isHidden = true
            cell.subtractButton.isHidden = true
        }
        

        
        
        //MARK:-  Add or Decrease Numbers in cart
        
        cell.tapBlock = { [self] in
          
            saveData(productName: arrCart[indexPath.row].productName!, variendID: arrCart[indexPath.row].varientID!)
            DispatchQueue.main.async {
                tableView.reloadData()
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                addItemsServerHit(qty: Int((cell.countButton.titleLabel?.text)!)! , varient_id: arrCart[indexPath.row].varientID!, store_id: 2)
            }
            
            
        }
        cell.addNumber = { [self] in
            saveData(productName: arrCart[indexPath.row].productName!, variendID: arrCart[indexPath.row].varientID!)
            DispatchQueue.main.async {
                tableView.reloadData()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                addItemsServerHit(qty: Int((cell.countButton.titleLabel?.text)!)! , varient_id: arrCart[indexPath.row].varientID!, store_id: 2)
            }
            
        }
        cell.decreaseNumber = { [self] in
            deleteFeed(id: arrCart[indexPath.row].varientID!)
            DispatchQueue.main.async {
                tableView.reloadData()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if cell.countButton.titleLabel?.text! != "+"{
                    addItemsServerHit(qty: Int((cell.countButton.titleLabel?.text)!)! , varient_id: arrCart[indexPath.row].varientID!, store_id: 2)
                }
                else {
                    addItemsServerHit(qty: 0 , varient_id: arrCart[indexPath.row].varientID!, store_id: 2)
                    DispatchQueue.main.async {
                        arrCart.removeAll()
                        priceLabel.text = "Price is \(0)"
                        noOfItemsLabel.text = "no of items are : \(0)"

                        tableView.reloadData()
                    }
                   
                }
            }
        }

        return cell
    }
    
}


extension CartViewController {
    func cartList() {
        let dict = ["user_id": UserDefaults.standard.string(forKey: "user_id")]
        
        http.requestWithPost(parameters: dict as [String : Any], Url: Endpoints.showCartData) { [self] (response, error) in
            DispatchQueue.main.async { [self] in
                let jsonData = response?.toJSONString1().data(using: .utf8)
                let decoder = JSONDecoder()
                let obj = try! decoder.decode(CartItems.self, from: jsonData!)
                if obj.status == "1"{
                    if let arrayofBanner = obj.data{
                        _ = arrayofBanner.map{
                            self.arrCart.append($0)
                        }
                        
                        priceLabel.text = "Price is \(obj.totalPrice ?? 0)"
                        noOfItemsLabel.text = "no of items are : \(arrCart.count )"
                    }
                    DispatchQueue.main.async {
                        tableView.reloadData()
                    }
                    
                    activity.stopAnimating()
                }
                else{
                    print(obj.message)
                }
            }
        }
    }
}

//MARK: Core Data Save,Fetch And Search
extension CartViewController {
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
extension CartViewController {
    func addItemsServerHit(qty : Int , varient_id : Int , store_id : Int) {
        addCart(qty: qty, varient_id: varient_id  , store_id: store_id) { [self] (response, error) in
            if response != nil{
                if let arrayofBanner = response?.cartItems{
                    _ = arrayofBanner.map{
                        arrCartNew.append($0)
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
