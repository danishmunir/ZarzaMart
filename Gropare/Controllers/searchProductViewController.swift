//
//  searchProductViewController.swift
//  Gropare
//
//  Created by Muhammad Imran on 17/10/2020.
//

import UIKit
import CoreData
import SDWebImage
class searchProductViewController: UIViewController {

    var Index = Int()
    var arrCart = [CartItem]()
    @IBOutlet weak var imgView: UIImageView!
    var arrListing = [productVarients_Data]()
    @IBOutlet weak var kg: UILabel!
    var searchedproductId = Int()
    var cartArray : [databaseCart] = []
    let http = HTTPService()
    var fromSearchView : Bool =  false
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var cancelPrice: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var subBtn: UIButton!
    @IBOutlet weak var countBtn: UIButton!
    var selectedIndex = Int()
    var productsArray = [Products_Data]()
    var btnTitile = Int()
    //MARK:- CoreData
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate //Singlton instance
    var context:NSManagedObjectContext!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "LandingPopularMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "LandingPopularMenuTableViewCell")
        serverHitforVarientforSearch(productId: searchedproductId)
    }
    func checkBtnHideORNot() {
        let count =  searchItemInCart(vId: (arrListing[0].varientID)!)
        if count != 0 {
            price.text = "\(Double((arrListing[0].price!)) * Double(count))"
            countBtn.setTitle(String(count), for: .normal)
            countBtn.backgroundColor = .white
            addBtn.isHidden = false
            subBtn.isHidden = false
        } else {
            price.text = "\(arrListing[0].price ?? 0)"
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
        let name = arrListing[0].datumDescription!
        let vid = arrListing[0].varientID!
        saveData(productName: name, variendID: vid)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
             let btnTitile = Int((countBtn.titleLabel?.text)!)!
             let vid =  arrListing[0].varientID
            let sid = arrListing[0].storeID
            addItemsServerHit(qty: btnTitile, varient_id: vid!, store_id: sid!)
            let count = searchItemInCart(vId: vid!)
            countBtn.setTitle("\(count)", for: .normal)
        }
    }
    @IBAction func countBtnTapped(_ sender: Any) {
        let name = arrListing[0].datumDescription!
        let vid = arrListing[0].varientID!
        saveData(productName: name, variendID: vid)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            if countBtn.titleLabel?.text! == "+"{
                 btnTitile = Int("1")!
             
            }
            else{
                 btnTitile = Int((countBtn.titleLabel?.text)!)!
            
            }
            
            let count = searchItemInCart(vId: vid)
            countBtn.setTitle(String(count), for: .normal)
            addBtn.isHidden = false
            subBtn.isHidden = false
             
             let vid =  arrListing[0].varientID!
            let sid = arrListing[0].storeID!
            
            addItemsServerHit(qty: btnTitile, varient_id: vid, store_id: sid)
        }
        
    }
    @IBAction func subBtnTapped(_ sender: Any) {
        deleteFeed(id: (arrListing[0].varientID!))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            let vid =  arrListing[0].varientID!
            let sid = arrListing[0].storeID!
        if countBtn.titleLabel?.text! != "1"{
            addItemsServerHit(qty: btnTitile, varient_id: vid, store_id: sid)
            let count = searchItemInCart(vId: vid)
            countBtn.setTitle("\(count)", for: .normal)
            }
            else {
                addItemsServerHit(qty: 0, varient_id: vid, store_id: sid)
                countBtn.setTitle("+", for: .normal)
                addBtn.isHidden = true
                subBtn.isHidden = true
            }
        }

    }
    
    
    func setAllData() {
        kg.text = "\(arrListing[0].quantity) \(arrListing[0].unit!)"
            price.text = "\(arrListing[0].price!)"
            cancelPrice.text = "\(arrListing[0].mrp!)"
            nameLabel.text = arrListing[0].datumDescription
            descriptionLabel.text = arrListing[0].datumDescription!
            let imageUrl = URL(string : Endpoints.ImgBaseUrl +  UnwarppingValue(value: arrListing[0].varientImage))
            imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            imgView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: ""))
    }
    
}

extension searchProductViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrListing.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        Index = indexPath.row
        let popularCell = tableView.dequeueReusableCell(withIdentifier: "LandingPopularMenuTableViewCell", for: indexPath) as! LandingPopularMenuTableViewCell
        
        popularCell.addButton.tag = indexPath.row
        popularCell.countButton.tag = indexPath.row
        popularCell.subtractButton.tag = indexPath.row
        let index = arrListing[indexPath.row]
        let count = searchItemInCart(vId: arrListing[indexPath.row].varientID!)
        if count != 0{
            popularCell.priceLbl.text = "\(Double(arrListing[indexPath.row].price!) * Double(count))"
            popularCell.countButton.setTitle(String(count), for: .normal)
            popularCell.countButton.backgroundColor = .white
            popularCell.addButton.isHidden = false
            popularCell.subtractButton.isHidden = false
        }
        else{
            popularCell.priceLbl.text = "\(arrListing[indexPath.row].price ?? 0)"
            popularCell.countButton.setTitle("+", for: .normal)
            popularCell.countButton.backgroundColor = UIColor(named: "Greenish")
            popularCell.addButton.isHidden = true
            popularCell.subtractButton.isHidden = true
        }
        

        
        
        //MARK:-  Add or Decrease Numbers in cart
        
        popularCell.tapBlock = { [self] in
          
            saveData(productName: arrListing[indexPath.row].datumDescription!, variendID: arrListing[indexPath.row].varientID!)
            DispatchQueue.main.async {
                tableView.reloadData()

            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                addItemsServerHit(qty: Int((popularCell.countButton.titleLabel?.text)!)! , varient_id: arrListing[indexPath.row].varientID!, store_id: arrListing[indexPath.row].storeID!)
            }
            
            
        }
        popularCell.addNumber = { [self] in
            saveData(productName: arrListing[indexPath.row].datumDescription!, variendID: arrListing[indexPath.row].varientID!)
            DispatchQueue.main.async {
                tableView.reloadData()
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                addItemsServerHit(qty: Int((popularCell.countButton.titleLabel?.text)!)! , varient_id: arrListing[indexPath.row].varientID!, store_id: arrListing[indexPath.row].storeID!)
            }
            
        }
        popularCell.decreaseNumber = { [self] in
            deleteFeed(id: arrListing[indexPath.row].varientID!)
            DispatchQueue.main.async {
                tableView.reloadData()
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if popularCell.countButton.titleLabel?.text! != "+"{
                    addItemsServerHit(qty: Int((popularCell.countButton.titleLabel?.text)!)! , varient_id: arrListing[indexPath.row].varientID!, store_id: arrListing[indexPath.row].storeID!)
                }
                else {
                    addItemsServerHit(qty: 0 , varient_id: arrListing[indexPath.row].varientID!, store_id: arrListing[indexPath.row].storeID!)
                }
            }
        }
        popularCell.varientconfigureCell(products: index)
        return popularCell
        
    }
    
    
}

//MARK: Core Data Save,Fetch And Search
extension searchProductViewController {
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
                countBtn.titleLabel?.text = "\(count)"
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
extension searchProductViewController {
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
    
    func serverHitforVarientforSearch(productId : Int){
        let dict = ["product_id": productId ,"lat":"12.74","lng":"74.90"] as [String : Any]
        http.requestWithPost(parameters: dict, Url: Endpoints.varient) { [self] (response, error) in
            DispatchQueue.main.async { [self] in
                let jsonData = response?.toJSONString1().data(using: .utf8)
                let decoder = JSONDecoder()
                let obj = try! decoder.decode(ProductVarient.self, from: jsonData!)
                if obj.status == "1"{
                    if let arrayofBanner = obj.data{
                        _ = arrayofBanner.map{
                            self.arrListing.append($0)
                        }
                    }
                    setAllData()
                    checkBtnHideORNot()
                    DispatchQueue.main.async {
                        tableView.reloadData()
                    }
                }
                else{
                    print(obj.message)
                }
            }
        }
    }
}
