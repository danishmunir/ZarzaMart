//
//  UIImageView.swift
//  Gropare
//
//  Created by Danish Munir on 09/10/2020.
//

import Foundation
import UIKit

extension UIImageView {

   func setRounded() {
    let radius = self.frame.width / 2
      self.layer.cornerRadius = radius
      self.layer.masksToBounds = true
   }
}
