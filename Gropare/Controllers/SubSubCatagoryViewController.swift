//
//  SubSubCatagoryViewController.swift
//  Gropare
//
//  Created by Danish Munir on 16/10/2020.
//

import UIKit
import CoreData
import SDWebImage

class SubSubCatagoryViewController: UIViewController {
    
    var arrCart = [CartItem]()
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var kg: UILabel!
    var products: CatagoryProducts_Datum?
    var cartArray : [databaseCart] = []
    
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var cancelPrice: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var subBtn: UIButton!
    @IBOutlet weak var countBtn: UIButton!
    var selectedIndex = Int()
    var subCatagoryProducts = [CatagoryProducts_Datum]()
    //MARK:- CoreData
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate //Singlton instance
    var context:NSManagedObjectContext!
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductTableViewCell")
        setAllData()
        checkBtnHideORNot()
    }
    
    func checkBtnHideORNot() {
        let count =  searchItemInCart(vId: (products?.varientID)!)
        if count != 0 {
            price.text = "\(Double((products?.price!)!) * Double(count))"
            countBtn.setTitle(String(count), for: .normal)
            countBtn.backgroundColor = .white
            addBtn.isHidden = false
            subBtn.isHidden = false
        } else {
            price.text = "\(products?.price ?? 0)"
            countBtn.setTitle("+", for: .normal)
            countBtn.backgroundColor = UIColor(named: "Greenish")
            addBtn.isHidden = true
            subBtn.isHidden = true
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.reloadData()
    }
    
    @IBAction func addBtnTapped(_ sender: UIButton) {
       
    }
    @IBAction func countBtnTapped(_ sender: Any) {
        
    }
    @IBAction func subBtnTapped(_ sender: Any) {
        deleteFeed(id: (products?.varientID!)!)
        
    }
    
    
    func setAllData() {
        if let products = products {
            kg.text = "\(products.quantity!) \(products.unit)"
            price.text = "\(products.price!)"
            cancelPrice.text = "\(products.mrp!)"
            nameLabel.text = products.productName!
            descriptionLabel.text = products.datumDescription!
            let imageUrl = URL(string : Endpoints.ImgBaseUrl +  UnwarppingValue(value: products.productImage))
            imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            imgView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: ""))
        }
        
        
        
    }

}

extension SubSubCatagoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subCatagoryProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell", for: indexPath) as! ProductTableViewCell
        
        return cell
    }
    
    
}

//MARK: Core Data Save,Fetch And Search
extension SubSubCatagoryViewController {
    func saveData1(productName : String , variendID : Int)
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
extension SubSubCatagoryViewController {
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

