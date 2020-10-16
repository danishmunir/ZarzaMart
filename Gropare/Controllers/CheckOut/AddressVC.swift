
import UIKit
import IBAnimatable

class AddressVC: UIViewController {
    
    @IBOutlet weak var txtFieldPinincode: AnimatableTextField!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var txtFieldHouseNo: AnimatableTextField!
    @IBOutlet weak var txtFieldCity: AnimatableTextField!
    @IBOutlet weak var txtFieldState: AnimatableTextField!
    @IBOutlet weak var txtFieldArea: AnimatableTextField!
    @IBOutlet weak var txtFieldLandMark: AnimatableTextField!
    @IBOutlet weak var txtFieldName: AnimatableTextField!
    @IBOutlet weak var txtFieldNumber: AnimatableTextField!
    @IBOutlet weak var txtFieldAlterNumber: AnimatableTextField!
    @IBOutlet weak var btnArea: UIButton!
    @IBOutlet weak var btnCity: UIButton!
    @IBOutlet weak var btnSave: AnimatableButton!
    
    let indicator = UIActivityIndicatorView()
    var arrCityName = [City_Data]()
    var arrCity = [String]()
    var cityName = String()
    var cityId = Int()
    var arrSocietyName = [Society_Data]()
    var arrSociety = [String]()
    var societyName = String()
    var editAddress: Address_List?
    var isAddAddress = false
    let http = HTTPService()
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.color = .gray
        self.serverHitCity()
        self.editListing()
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    func loadIndicator() {
        DispatchQueue.main.async { [self] in
            indicator.startAnimating()
            self.view.addSubview(indicator)
            self.indicator.center = self.view.center
        }
       
    }
    func finishIndicator() {
        DispatchQueue.main.async { [self] in
            indicator.stopAnimating()
            indicator.removeFromSuperview()
        }
        
    }
    
    @objc func hideKeyboard(){
       
        self.view.endEditing(true)
        
    }
    
    //MARK:- IBAction
    @available(iOS 13.0, *)
    @IBAction func btnCity(_ sender: UIButton) {
        RPicker.selectOption(dataArray: arrCity, didSelectValue: {(selectedValue,selectedIndex) in
            self.cityId = self.arrCityName[selectedIndex].cityID ?? 0
            self.cityName = self.arrCityName[selectedIndex].cityName ?? ""
            self.txtFieldCity.text = self.arrCityName[selectedIndex].cityName ?? ""
            //self.serverHitForSociety()
            
        })
    }
    
    @available(iOS 13.0, *)
    @IBAction func areaAction(_ sender: Any) {
//            RPicker.selectOption(dataArray: arrSociety, didSelectValue: {(selectedValue,selectedIndex) in
//                self.societyName = self.arrSocietyName[selectedIndex].societyName ?? ""
//                self.txtFieldArea.text = self.arrSocietyName[selectedIndex].societyName ?? ""
//            })
    
    }
    
    @IBAction func saveAction(_ sender: Any) {
        if txtFieldPinincode.text != "" && txtFieldHouseNo.text != "" && txtFieldCity.text != "" && txtFieldState.text != "" && txtFieldArea.text != "" && txtFieldLandMark.text != "" && txtFieldName.text != "" && txtFieldNumber.text != "" && txtFieldAlterNumber.text != "" {
            if isAddAddress {
                self.serverHitForAddress()
            } else {
                self.serverHitForEditAddress()
            }
        }
       
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func editListing() {
        self.txtFieldPinincode.text = editAddress?.pincode
        self.txtFieldHouseNo.text = editAddress?.houseNo
        self.txtFieldCity.text = editAddress?.city
        self.txtFieldState.text = editAddress?.state
        self.txtFieldArea.text = editAddress?.society
        self.txtFieldLandMark.text = editAddress?.landmark
        self.txtFieldName.text = editAddress?.receiverName
        self.txtFieldNumber.text = editAddress?.receiverPhone
        self.txtFieldAlterNumber.text = editAddress?.receiverPhone
        if isAddAddress == false {
            self.btnSave.setTitle("Update", for: .normal)
        }
    }
}



//MARK:- Api
extension AddressVC {
    // CityApi
    func serverHitCity(){
        http.getRequest(urlString: Endpoints.city) { (responseData) in
            let jsonData = responseData?.toJSONString2().data(using: .utf8)!
            let decoder = JSONDecoder()
            let obj = try! decoder.decode(City.self, from: jsonData!)
            if obj.status == "1" {
                if let city = obj.data{
                    _ = city.map{
                        self.arrCity.append($0.cityName!)
                        self.arrCityName.append($0)
                    }
                }
            }

        }
    }
    
    //SocietyApi
    func serverHitForSociety(){
        loadIndicator()
        let dict = ["city_id": String(cityId)]
        http.requestWithPost(parameters: dict, Url: Endpoints.society) { [self] (responseData, error) in
            let jsonData = responseData?.toJSONString1().data(using: .utf8)!
            let decoder = JSONDecoder()
            let obj = try! decoder.decode(Society.self, from: jsonData!)
            if obj.status == "1" {
                if let city = obj.data{
                    _ = city.map{
                        self.arrSociety.append($0.societyName!)
                        self.arrSocietyName.append($0)
                    }
                }
                finishIndicator()
            }
            else{
                finishIndicator()
            }

        }
    }
    
    // Add Address Api
    func serverHitForAddress() {
        let dict = ["pin":txtFieldPinincode.text!, "city_name":txtFieldCity.text!, "state": txtFieldState.text!, "society_name":txtFieldArea.text!, "receiver_name":txtFieldName.text!, "receiver_phone":txtFieldNumber.text!, "house_no":txtFieldHouseNo.text!, "landmark":txtFieldLandMark.text!, "user_id": UserDefaults.standard.string(forKey: "user_id")!,"lat":"12.74","lng":"74.90"] as [String : Any]
        
        http.requestWithPost(parameters: dict, Url: Endpoints.add_address) { (responseData, erro) in
            let jsonData = responseData?.toJSONString1().data(using: .utf8)!
            let decoder = JSONDecoder()
            let obj = try! decoder.decode(Address.self, from: jsonData!)
            if obj.status == "1" {
                DispatchQueue.main.async { [self] in
                    let alert = UIAlertController(title: "Successful", message: "Adress Successful Added", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                           UIAlertAction in
                        self.navigationController?.popViewController(animated: true)
                       }
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            
                
            } else {
                print("error")
            }
        }
    }
    
    // Edit Api
    func serverHitForEditAddress() {
        let addressId = editAddress?.addressID
        let dict = ["pin":txtFieldPinincode.text!, "city_name":txtFieldCity.text!, "state": txtFieldState.text!, "society_name":txtFieldArea.text!, "receiver_name":txtFieldName.text!, "receiver_phone":txtFieldNumber.text!, "house_no":txtFieldHouseNo.text!, "landmark":txtFieldLandMark.text!, "user_id": fetchString(key: "userID"),"address_id": addressId!,"lat":"12.74","lng":"74.90"] as [String : Any]
        
        http.requestWithPost(parameters: dict, Url: Endpoints.add_address) { (responseData, erro) in
            let jsonData = responseData?.toJSONString1().data(using: .utf8)!
            let decoder = JSONDecoder()
            let obj = try! decoder.decode(Address.self, from: jsonData!)
            if obj.status == "1" {
                print("error")
            } else {
                print("error")
            }
        }
    }
    
}

