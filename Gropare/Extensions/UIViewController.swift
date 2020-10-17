//
//  UIViewController.swift
//  Gropare
//
//  Created by Danish Munir on 10/10/2020.
//

import Foundation
import UIKit
import MaterialComponents.MaterialSnackbar


extension UIViewController {
    func onTapClick(target: Any, _ selector: Selector) {
        let tap = UITapGestureRecognizer(target: target, action: selector)
        let swipeTap = UISwipeGestureRecognizer(target: target, action: selector)
        swipeTap.direction = .down
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(swipeTap)
    }
    
    func snackBarMessage(snackManager: MDCSnackbarManager, snackBarMessage: MDCSnackbarMessage, title : String) { snackBarMessage.text = title
        snackBarMessage.duration = 3
        MDCSnackbarMessageView.appearance().snackbarMessageViewBackgroundColor = UIColor(named: "Pinkish")
        snackManager.show(snackBarMessage)
    }
}
