//
//  CommonClass.swift
//  Gropare
//
//  Created by Danish Munir on 12/10/2020.
//

import Foundation
import UIKit

var storID = String()
var tolalItemPrice = Int()
var paymentMetod = String()
var paymentStatus = String()
var wallet = String()


//Mark:- fetchString
var cartID = fetchString(key: "cartID")
var userphone = fetchString(key: "user_phone")
var useremail = fetchString(key: "user_email")
var username = fetchString(key: "user_name")
var userID = fetchString(key: "user_id")
var orderID = fetchString(key: "orderID")

func UnwarppingValue(value : Any?)->String{
    
    if let value1 = value{
        let value2 = String(describing: value1)
        if value2 == ""{
            return "N/A"
        }
        else{
            return String(describing: value1)
        }
    }
    else{
        return "N/A"
    }}
//MARK: Gradient function
func setGradientBackground(view1 : UIView, colorTop: UIColor, colorBottom: UIColor) {
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [colorBottom.cgColor, colorTop.cgColor]
    gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.4)
    gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.6)
  //  gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
  //  gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
    gradientLayer.locations = [0, 1]
    gradientLayer.frame = view1.bounds
    view1.layer.addSublayer(gradientLayer)
  //  view1.layer.insertSublayer(gradientLayer, at: 0)

}
