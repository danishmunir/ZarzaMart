//
//  Constants.swift
//  Gropare
//
//  Created by Danish Munir on 09/10/2020.
//

import Foundation
import UIKit

//Mark:- ScreenDimention
var SCREEN_WIDTH = UIScreen.main.bounds.width
var SCREEN_HEIGHT = UIScreen.main.bounds.height
let verticalCenter: CGFloat = UIScreen.main.bounds.size.height / 2.0
let horizontalCenter: CGFloat = UIScreen.main.bounds.size.width / 2.0

    //******************* Key exists or not in UserDefault ************************
    func isKeyExists(key:String) ->Bool {
        if (UserDefaults.standard.object(forKey: key) != nil) {
            return true
        }else {
            return false
        }
    }

    //******************* SAVE OBJECT DICTONARY IN USER DEFAULT *******************
    func saveObjectDict(key:String, objArray:[String:Any]){
        let data =  NSKeyedArchiver.archivedData(withRootObject: objArray);
        UserDefaults.standard.set(data, forKey: key)
        UserDefaults.standard.synchronize();
    }

    //******************* FETCH OBJECT DICTIONARY FROM USER DEFAULT *******************
    func fetchObjectDict(key:String)->[String:Any] {
        var objArray:[String:Any]=[String:Any]();
        if let data = UserDefaults.standard.object(forKey: key) as? NSData {
            objArray = (NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [String:Any])!
        }
        return objArray;
    }

    //******************* REMOVE NSUSER DEFAULT *******************
    func removeUserDefault(key:String) {
        UserDefaults.standard.removeObject(forKey: key);
    }

    //******************* SAVE STRING IN USER DEFAULT *******************
    func saveStringInDefault(value:Any,key:String) {
        UserDefaults.standard.setValue(value, forKey: key);
        UserDefaults.standard.synchronize();
    }

    //******************* FETCH STRING FROM USER DEFAULT *******************
    func fetchString(key:String)->AnyObject {
        if (UserDefaults.standard.object(forKey: key) != nil) {
            return UserDefaults.standard.value(forKey: key)! as AnyObject;
        }else {
            return "" as AnyObject;
        }
    }


func addCart(qty : Int , varient_id : Int , store_id : Int , completionalHandler: @escaping(AddCart? , Error?) -> Void) {
    let dict = ["user_id":UserDefaults.standard.string(forKey: "user_id")! , "qty": qty ,"varient_id": varient_id , "store_id" : store_id] as [String : Any]
    let http = HTTPService()
    http.requestWithPost(parameters: dict, Url: Endpoints.addCart) { (response, error) in
        DispatchQueue.main.async {
            let jsonData = response?.toJSONString1().data(using: .utf8)
            let decoder = JSONDecoder()
            let obj = try! decoder.decode(AddCart.self, from: jsonData!)
            if obj.status == "1"{
                completionalHandler(obj,nil)
            }
            else{
                completionalHandler(nil,error)
            }
        }
    }

}

