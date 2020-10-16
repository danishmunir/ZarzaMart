//
//  UIView.swift
//  Gropare
//
//  Created by Danish Munir on 16/10/2020.
//

import Foundation
import UIKit


extension UIView {
    public func roundCorner() {
        let height = self.bounds.height
        self.layer.cornerRadius = height/2
        self.clipsToBounds = true
    }
}
