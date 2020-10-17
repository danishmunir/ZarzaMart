//
//  OrderSummaryViewController.swift
//  Gropare
//
//  Created by Danish Munir on 15/10/2020.
//


import UIKit
import FSCalendar
import SDWebImage
import MaterialComponents.MaterialSnackbar

class OrderSummaryViewController: UIViewController, UIGestureRecognizerDelegate{
    
    
    //MARK:- IBOutlets
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var calender: FSCalendar!
    @IBOutlet weak var lblTotalItem: UILabel!
    @IBOutlet weak var collectionViewItems: UICollectionView!
    @IBOutlet weak var lblTotalItemPrice: UILabel!
    @IBOutlet weak var tblVireTimeslot: UITableView!
    @IBOutlet weak var lblDeliveryPrice: UILabel!
    @IBOutlet weak var calenderCnstHght: NSLayoutConstraint!
    @IBOutlet weak var lblTotalPrice: UILabel!
    
    
    
    let http = HTTPService()
    let snackManager = MDCSnackbarManager()
    let snackBarMessage = MDCSnackbarMessage()
    var selectedShowAddressData = [Address_List]()
    var selectedDatesFormat = ""
    var arrTimeslot = [String]()
    var timeSlot = String()
    var selectedIndex = Int()
    var arrCartData = [ShowCart_Data]()
    var arrCart = [CartItems_Datum]()
    //MARK:- Calender Function
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calender, action: #selector(self.calender.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
        }()
    
    //MARK:- viewdidload
    override func viewDidLoad() {
        super.viewDidLoad()
        cartList()
        tblVireTimeslot.register(UINib(nibName: "TimeSlotTableViewCell", bundle: nil), forCellReuseIdentifier: "TimeSlotTableViewCell")
        self.calender.select(Date())
        self.view.addGestureRecognizer(self.scopeGesture)
        self.calender.scope = .week
        self.calender.setScope(.week, animated: true)
        self.calender.accessibilityIdentifier = "calendar"
         collectionViewItems.register(UINib(nibName: "BannerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BannerCollectionViewCell")
        collectionViewItems.delegate = self
        collectionViewItems.dataSource = self
        self.lblTotalItem.text = "Basket items ( \(arrCartData.count) )"
        selectedDatesFormat = calender.today.map({self.dateFormatter.string(from: $0)})!
        if selectedDatesFormat != "" {
            serverHitTimeSlotList()
        }

        serverHitDelivary()
        
        // Do any additional setup after loading the view.
    }
    
    deinit {
        print("\(#function)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        serverHitShowAddress()
    }
    
    // MARK:- IBACtion
    @IBAction func addAddressAction(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Checkout", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "SelectAddress") as! SelectAddress
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func continueAction(_ sender: Any) {
        serverHitForMakeanOrder()
    }
 
}

//MARK:- Calender
extension OrderSummaryViewController: FSCalendarDataSource, FSCalendarDelegate{
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calenderCnstHght.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        self.calender.today!
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("did select date \(self.dateFormatter.string(from: date))")
        let selectedDates = calendar.selectedDate.map({self.dateFormatter.string(from: $0)})
      //  selectedDates = calendar.today.map({self.dateFormatter.string(from: $0)})
        selectedDatesFormat = selectedDates!
        print("selected dates is \(selectedDates ?? "")")
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
        serverHitTimeSlotList()
        
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("\(self.dateFormatter.string(from: calendar.currentPage))")
    }
    
    
}

//MARK:- UITableView
extension OrderSummaryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTimeslot.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tblVireTimeslot.dequeueReusableCell(withIdentifier: "TimeSlotTableViewCell", for: indexPath) as? TimeSlotTableViewCell)!
        let value = arrTimeslot[indexPath.row]
        cell.lblTime.text = "\(value)"
        cell.btnCheckBox.addTarget(self, action: #selector(checkboxAction(sender:)), for: .touchUpInside)
        cell.btnCheckBox.tag = indexPath.row
        
        if selectedIndex == indexPath.row {
            cell.viewCircle.layer.borderWidth = 2
            cell.viewCircle.layer.borderColor = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1)
            cell.lblCircle.backgroundColor = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1)
        } else {
            cell.viewCircle.layer.borderWidth = 2
            cell.viewCircle.layer.borderColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
            cell.lblCircle.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        return cell
    }
    
    @objc func checkboxAction(sender : UIButton) {
        let cell = self.tblVireTimeslot.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! TimeSlotTableViewCell
        timeSlot = arrTimeslot[sender.tag]
        self.selectedIndex = sender.tag
        tblVireTimeslot.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
        
    }
}

extension OrderSummaryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrCart.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
       let cell = collectionViewItems.dequeueReusableCell(withReuseIdentifier: "BannerCollectionViewCell", for: indexPath) as! BannerCollectionViewCell
        let value = arrCart[indexPath.item]
        let imageUrl = URL(string : Endpoints.ImgBaseUrl +  UnwarppingValue(value: value.varientImage))
        cell.imgBanner.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.imgBanner.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: ""))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
        let width = (self.collectionViewItems.frame.height)
        let height = (self.collectionViewItems.frame.height - 10)
        return CGSize(width: width, height: height)
        
        }
    
}
    
  //MARK:- Api
extension OrderSummaryViewController {
    // TimeSlot
    func serverHitTimeSlotList(){
        arrTimeslot.removeAll()
        let dict = ["selected_date": selectedDatesFormat]
        
        
        http.requestWithPost(parameters: dict, Url: Endpoints.timeslot) { (responseData, error) in
            DispatchQueue.main.async { [self] in
                let jsonData = responseData?.toJSONString1().data(using: .utf8)!
                let decoder = JSONDecoder()
                let obj = try! decoder.decode(Timeslot.self, from: jsonData!)
                if obj.status == "1" {
                    if let arrFeed = obj.data {
                        _  =   arrFeed.map{
                            self.arrTimeslot.append($0)
                        }
                        self.timeSlot = self.arrTimeslot[0]
                        self.tblVireTimeslot.delegate = self
                        self.tblVireTimeslot.dataSource = self
                        self.tblVireTimeslot.reloadData()
                    }
                    
                } else {
                    snackBarMessage(snackManager: snackManager, snackBarMessage: snackBarMessage, title: "\(obj.message)")
                    
                }
            }
        }
        
    }
    
    // MinMax Api
    func serverHitMinmax(){
        
        http.getRequest(urlString: Endpoints.minmax) { (responseData) in
            let jsonData = responseData?.toJSONString2().data(using: .utf8)!
            let decoder = JSONDecoder()
            let obj = try! decoder.decode(Minmax.self, from: jsonData!)
            if obj.status == "1" {
               print("error")
            } else {
                print("error")
            }
        }
    }
    
    // Delivary Api
    func serverHitDelivary() {
        http.getRequest(urlString: Endpoints.delivery_info) { (responseData) in
            let jsonData = responseData?.toJSONString2().data(using: .utf8)!
            let decoder = JSONDecoder()
            let obj = try! decoder.decode(Delivery.self, from: jsonData!)
            if obj.status == "1" {
                self.lblDeliveryPrice.text = "Rs. \(UnwarppingValue(value: obj.data?.delCharge))"
            } else {
                
            }
        }
    }
    
    func serverHitShowAddress() {
        let dict = ["user_id": UserDefaults.standard.string(forKey: "user_id")!, "store_id": 2] as [String : Any]
        
        http.requestWithPost(parameters: dict, Url: Endpoints.show_address) { (responseData, error) in
            DispatchQueue.main.async {
                let jsonData = responseData?.toJSONString1().data(using: .utf8)!
                let decoder = JSONDecoder()
                let obj = try! decoder.decode(Address.self, from: jsonData!)
                if obj.status == "1" {
                for  i in obj.data! {
                    if i.selectStatus == 1 {
                        self.lblName.text = i.receiverName
                        self.lblAddress.text = "\(i.houseNo ?? "")," + "\(i.society ?? "")," + "\(i.city ?? "")," + "\(i.state ?? "")," + "\(i.pincode ?? "")"
                        self.lblNumber.text = "\(i.receiverPhone ?? "")"
                    }
                }
                } else {
                    print(error ?? "eeoe")
                }
        }

        }
}
    // Make on Order
        func serverHitForMakeanOrder(){
            // email, password, Auth-key
            let dict = ["time_slot": timeSlot,"user_id": UserDefaults.standard.string(forKey: "user_id")!, "delivery_date": selectedDatesFormat, "store_id": 2] as [String : Any]
            //"ddk_wallet_id":txtFldDDDKWalletID.text!,
            http.requestWithPost(parameters: dict, Url: Endpoints.ios_make_order) { (responseData, error) in
                DispatchQueue.main.async { [self] in
                    let jsonData = responseData?.toJSONString1().data(using: .utf8)!
                    let decoder = JSONDecoder()
                    do{
                        let obj = try decoder.decode(Make_On_Order.self, from: jsonData!)
                        if obj.status == "1"{
                            if let cartID = obj.data?.cartID {
                                saveStringInDefault(value: cartID, key: "cartID")
                            } else {
                                saveStringInDefault(value: "", key: "cartID")
                            }
                            
                            if let orderID = obj.data?.orderID {
                                saveStringInDefault(value: orderID, key: "orderID")
                            } else {
                                saveStringInDefault(value: "", key: "orderID")
                            }
                            let storyboard = UIStoryboard.init(name: "Checkout", bundle: nil)
                            let viewController = storyboard.instantiateViewController(withIdentifier: "CheckoutVC") as! CheckoutVC
                            self.navigationController?.pushViewController(viewController, animated: true)
                    }else{
                        print("error")
                    }
                    }
                        catch{
                            snackBarMessage(snackManager: snackManager, snackBarMessage: snackBarMessage, title: "Something went Wrong")
                        }

                    
                }

            }
           
        }
    
}



extension OrderSummaryViewController {
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
                        self.lblTotalPrice.text = "Rs.\(obj.totalPrice ?? 0)"
                        self.lblTotalItemPrice.text = "Rs.\(obj.totalPrice ?? 0)"
                    }
                    DispatchQueue.main.async {
                        collectionViewItems.reloadData()
                    }
                }
                else{
                    print(obj.message!)
                }
            }
        }
    }
}

//MARK:

