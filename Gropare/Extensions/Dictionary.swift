//
//  Dictionary.swift
//  Gropare
//
//  Created by Danish Munir on 07/10/2020.
//

import Foundation

public extension Dictionary{
    
    func toJSONString1() -> String{
        if JSONSerialization.isValidJSONObject(self) {
            do{
                let data = try JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions(rawValue: 0))
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            }catch {
                print("error")
            }
        }
        return ""
    }
  
}

public extension NSDictionary{
    
    func toJSONString2() -> String{
        if JSONSerialization.isValidJSONObject(self) {
            do{
                let data = try JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions(rawValue: 0))
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            }catch {
                print("error")
            }
        }
        return ""
    }
  
}
