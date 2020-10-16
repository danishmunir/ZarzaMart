//
//  LandingViewController.swift
//  Gropare
//
//  Created by Danish Munir on 09/10/2020.
//

import UIKit
import SDWebImage
import CoreLocation
import CoreData

class LandingViewController: UIViewController {
    //MARK:- Outlests
    @IBOutlet weak var mainTblView: UITableView!
    @IBOutlet weak var bannerCollectionView: UICollectionView!
    @IBOutlet weak var catagoryCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var locationLabelTop: UILabel!
    @IBOutlet weak var cartItemsCountTopImg: UIImageView!
    @IBOutlet weak var cartItemsCountTopLabel: UILabel!
    
    
    
    var countTap: Int = 1
    //@IBOutlet weak var popularMenuTableView: UITableView!
    
    //MARK:- Variables
    var listarrCart = [CartItems_Datum]()
    var arrCart = [CartItem]()
    var myPickerView: UIPickerView! = UIPickerView()
    let backgroung = UIView()
    let http = HTTPService()
    var arrBanner = [Banner_Data]()
    var arrListing = [Products_Data]()
    var arrCatagory = [TopCategory_Data]()
    var arrTabListing = ["TOP SELLING","RECENT","DEALS OF THE DAY","WHAT'S NEW"]
    let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.systemUltraThinMaterialLight)
    var blurEffectView = UIVisualEffectView()
    var selectedValue : Int = 0
    var Index = Int()
    var selectRow: Int?
    var varientID = Int()
    var qtyValue = Int()
    var cartArray : [databaseCart] = []
    
    
    //MARK:- CoreLoction Declaration
    let locationManager = CLLocationManager()
    var geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    
    
    
    //MARK:- CoreData
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate //Singlton instance
    var context:NSManagedObjectContext!
    
    //MARK:- LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()
        //saveData(productName: "Potato", variendID: 2, value: 2)
        getCurrentLocation()
        myPickerView.delegate = self
        bannerCollectionView.register(UINib(nibName: "LandingBannerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LandingBannerCollectionViewCell")
        catagoryCollectionView.register(UINib(nibName: "LandingCatagoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LandingCatagoryCollectionViewCell")
        mainTblView.register(UINib(nibName: "LandingPopularMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "LandingPopularMenuTableViewCell")
        ProductsList(string: Endpoints.productList)
        catagoryList()
        searchBar.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(topLAbelTaped(_:)))
        locationLabelTop.addGestureRecognizer(tap)
        
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden  = true
        bannerList()
        DispatchQueue.main.async {
            self.mainTblView.reloadData()
        }
        cartList()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden  = false
    }
    
    @objc func topLAbelTaped(_ sender: UITapGestureRecognizer) {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc : LocationViewController = story.instantiateViewController(identifier: "LocationViewController") as! LocationViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }

    //MARK: - Actions
    @IBAction func sortTableviewPrducts(_ sender: UIButton) {
        Pikcer()
    }
    @IBAction func profileButton(_ sender: UIButton) {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(identifier: "ProfileTableViewController") as! ProfileTableViewController
        navigationController?.pushViewController(vc, animated: true)
        
    }
    @IBAction func cartButtonTapped(_ sender: UIButton) {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(identifier: "CartViewController") as! CartViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func viewAllCatagory(_ sender: UIButton) {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc : ViewAllCatagoryViewController = story.instantiateViewController(identifier: "ViewAllCatagoryViewController") as! ViewAllCatagoryViewController
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func viewAllProducts(_ sender: UIButton) {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc : ViewAllProductsViewController = story.instantiateViewController(identifier: "ViewAllProductsViewController") as! ViewAllProductsViewController
        vc.selected = selectedValue
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK:- Table view dataSource
extension LandingViewController: UITableViewDelegate, UITableViewDataSource {
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
            popularCell.priceLbl.text = "\(arrListing[indexPath.row].price! * Double(count))"
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
          
            saveData(productName: arrListing[indexPath.row].productName!, variendID: arrListing[indexPath.row].varientID!)
            DispatchQueue.main.async {
                tableView.reloadData()
                cartList()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                addItemsServerHit(qty: Int((popularCell.countButton.titleLabel?.text)!)! , varient_id: arrListing[indexPath.row].varientID!, store_id: arrListing[indexPath.row].storeID!)
            }
            
            
        }
        popularCell.addNumber = { [self] in
            saveData(productName: arrListing[indexPath.row].productName!, variendID: arrListing[indexPath.row].varientID!)
            DispatchQueue.main.async {
                tableView.reloadData()
                cartList()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                addItemsServerHit(qty: Int((popularCell.countButton.titleLabel?.text)!)! , varient_id: arrListing[indexPath.row].varientID!, store_id: arrListing[indexPath.row].storeID!)
            }
            
        }
        popularCell.decreaseNumber = { [self] in
            deleteFeed(id: arrListing[indexPath.row].varientID!)
            DispatchQueue.main.async {
                tableView.reloadData()
                cartList()
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
        popularCell.configureCell(products: index)
        return popularCell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(identifier: "ProductViewController") as! ProductViewController
        vc.productsArray = arrListing
        vc.selectedIndex = indexPath.row
        vc.products = arrListing[indexPath.row]
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
//MARK:- CollectionView dataSource
extension LandingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case bannerCollectionView:
            return arrBanner.count
        case catagoryCollectionView:
            return arrCatagory.count
            
        default:
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView {
        case bannerCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LandingBannerCollectionViewCell", for: indexPath) as! LandingBannerCollectionViewCell
            let imageUrl = URL(string : Endpoints.ImgBaseUrl +  UnwarppingValue(value: arrBanner[indexPath.row].bannerImage))
            cell.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imgView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: ""))
            return cell
        case catagoryCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LandingCatagoryCollectionViewCell", for: indexPath) as! LandingCatagoryCollectionViewCell
            
            cell.configureCell(catagory: arrCatagory[indexPath.row])
            return cell
        default:
            return UICollectionViewCell()
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case bannerCollectionView:
            let width = (self.bannerCollectionView.frame.width - 10)
            let height = (self.bannerCollectionView.frame.height - 10)
            return CGSize(width: width, height: height)
        case catagoryCollectionView:
            let width = 40
            let height = 500
            return CGSize(width: width, height: height)
        default:
            return CGSize(width: 0, height: 0)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == catagoryCollectionView {
            let story = UIStoryboard(name: "Main", bundle: nil)
            let vc = story.instantiateViewController(identifier: "SubCatagoryProductViewController") as! SubCatagoryProductViewController
            vc.catID = arrCatagory[indexPath.row].catID
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

//MARK:- PickerView dataSource

extension LandingViewController : UIPickerViewDataSource, UIPickerViewDelegate{
    func Pikcer() {
        DispatchQueue.main.async  { [self] in
            blurEffectView = UIVisualEffectView(effect: blurEffect)
            self.view.addSubview(blurEffectView)
            
            blurEffectView.translatesAutoresizingMaskIntoConstraints = false
            blurEffectView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1).isActive = true
            blurEffectView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1).isActive = true
            view.addSubview(blurEffectView)
            //backgroung.backgroundColor = .black
            blurEffectView.contentView.addSubview(myPickerView)
            myPickerView.translatesAutoresizingMaskIntoConstraints = false
            myPickerView.centerXAnchor.constraint(equalTo: self.blurEffectView.centerXAnchor).isActive = true
            myPickerView.centerYAnchor.constraint(equalTo: self.blurEffectView.centerYAnchor).isActive = true
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        pickerView.backgroundColor = .white
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrTabListing.count
    }
    
    // MARK: UIPickerViewDataSource methods
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {   return arrTabListing[row] }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent  component: Int) {
        let selected = arrTabListing[row] as String
        
        switch selected {
        
        case "RECENT":
            self.selectedValue = 1
            arrListing.removeAll()
            ProductsList(string: Endpoints.recentselling)
            mainTblView.reloadData()
            break
        case "TOP SELLING":
            self.selectedValue = 0
            arrListing.removeAll()
            ProductsList(string: Endpoints.productList)
            mainTblView.reloadData()
            break
        case "DEALS OF THE DAY":
            self.selectedValue = 2
            arrListing.removeAll()
            ProductsList(string: Endpoints.dealproduct)
            mainTblView.reloadData()
        case "WHAT'S NEW":
            self.selectedValue = 3
            arrListing.removeAll()
            ProductsList(string: Endpoints.whatsnew)
            mainTblView.reloadData()
            
        default:
            break
        }
        
        blurEffectView.removeFromSuperview()
        myPickerView.removeFromSuperview()
        
    }
}


//MARK:- Service Images Download
extension LandingViewController {
    func bannerList() {
        http.getRequest(urlString: Endpoints.bannerList) { [self] (response) in
            let jsonData = response?.toJSONString2().data(using: .utf8)
            let decoder = JSONDecoder()
            let obj = try! decoder.decode(Banner.self, from: jsonData!)
            if obj.status == "1"{
                if let arrayofBanner = obj.data{
                    _ =  arrayofBanner.map{
                        self.arrBanner.append($0)
                    }
                    
                }
                bannerCollectionView.reloadData()
            }
            else{
                //print(obj.message)
            }
        }
    }
    
    
}


extension LandingViewController {
    func ProductsList(string : String) {
        let dict = ["lat":"12.70","lng":"74.94", "city":"Manjeshwar"]
        
        http.requestWithPost(parameters: dict, Url: string) { [self] (response, error) in
            DispatchQueue.main.async { [self] in
                let jsonData = response?.toJSONString1().data(using: .utf8)
                let decoder = JSONDecoder()
                let obj = try! decoder.decode(Products.self, from: jsonData!)
                if obj.status == "1"{
                    if let arrayofBanner = obj.data{
                        _ = arrayofBanner.map{
                            self.arrListing.append($0)
                        }
                    }
                    mainTblView.reloadData()
                }
                else{
                    print(obj.message)
                }
            }
        }
    }
    
    func catagoryList() {
        let dict = ["lat":"12.70","lng":"74.94", "city":"Manjeshwar"]
        
        http.requestWithPost(parameters: dict, Url: Endpoints.topCategory) { [self] (response, error) in
            DispatchQueue.main.async { [self] in
                let jsonData = response?.toJSONString1().data(using: .utf8)
                let decoder = JSONDecoder()
                let obj = try! decoder.decode(TopCategory.self, from: jsonData!)
                if obj.status == "1"{
                    if let arrayofBanner = obj.data{
                        _ = arrayofBanner.map{
                            self.arrCatagory.append($0)
                        }
                    }
                    catagoryCollectionView.reloadData()
                }
                else{
                    print(obj.message)
                }
            }
        }
        
        
    }
}
//MARK:- CORE LOCATION
extension LandingViewController: CLLocationManagerDelegate {
    
    func getCurrentLocation() {
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else {
            return
        }
        print( "location = \(locValue.latitude) \(locValue.longitude)")
        getAddressFromLatLon(Latitude: locValue.latitude, Longitude: locValue.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error location")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func getAddressFromLatLon(Latitude: Double, Longitude: Double) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = Latitude
        center.longitude = Longitude
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        print("Location is", loc)
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
                                    {(placemarks, error) in
                                        if (error != nil)
                                        {
                                            print("reverse geodcode fail: \(error!.localizedDescription)")
                                        }
                                        else{
                                            //MARK: Error Crash
                                            let pm = placemarks! as [CLPlacemark]
                                            
                                            if pm.count > 0 {
                                                let pm = placemarks![0]
                                                var addressString : String = ""
                                                
                                                if pm.subLocality != nil {
                                                    addressString = addressString + pm.subLocality! + ", "
                                                }
                                                if pm.thoroughfare != nil {
                                                    addressString = addressString + pm.thoroughfare! + ", "
                                                }
                                                if pm.locality != nil {
                                                    addressString = addressString + pm.locality! + ", "
                                                }
                                                if pm.country != nil {
                                                    addressString = addressString + pm.country! + ", "
                                                }
                                                if pm.postalCode != nil {
                                                    addressString = addressString + pm.postalCode! + " "
                                                }
                                                self.locationLabelTop.text = "\(addressString)"
                                                
                                                print(addressString)
                                            }
                                        }
                                       
                                        
                                    })
    }
    
    
    
    func locationSetUp() {
        
        
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.startUpdatingLocation()
        
        locationManager.startMonitoringSignificantLocationChanges()
        
        // Here you can check whether you have allowed the permission or not.
        
        if CLLocationManager.locationServicesEnabled()
        {
            switch(CLLocationManager.authorizationStatus())
            {
            
            case .authorizedAlways, .authorizedWhenInUse:
                
                print("Authorize.")
                
                break
                
            case .notDetermined:
                
                print("Not determined.")
                
                break
                
            case .restricted:
                
                print("Restricted.")
                
                break
                
            case .denied:
                
                print("Denied.")
            @unknown default:
                print("ok")
            }
        }
    }
}


extension LandingViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(identifier: "SearchViewController") as! SearchViewController
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

//MARK: Core Data Save,Fetch And Search
extension LandingViewController {
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
extension LandingViewController {
    func addItemsServerHit(qty : Int , varient_id : Int , store_id : Int) {
        addCart(qty: qty, varient_id: varient_id  , store_id: store_id) { [self] (response, error) in
            if response != nil{
                if let arrayofBanner = response?.cartItems{
                    _ = arrayofBanner.map{
                        arrCart.append($0)
                    }
                    mainTblView.reloadData()
                }
            }
            else{
                //error
            }
        }
    }
    
   
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
                                self.listarrCart.append($0)
                            }
                        }
                        if cartItemsCountTopImg.isHidden{
                            cartItemsCountTopImg.isHidden = false
                            cartItemsCountTopLabel.isHidden = false
                            cartItemsCountTopLabel.text = String(listarrCart.count)
                        }
                        else {
                            cartItemsCountTopLabel.text = String(listarrCart.count)
                        }
                       
                    }
                    else{
                        print(obj.message)
                    }
                }
            }
        }


}


struct databaseCart {
    var productName : String?
    var value : Int?
    var varientId : Int?
}
