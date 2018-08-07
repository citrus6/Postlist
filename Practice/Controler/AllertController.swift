//
//  AllertController.swift
//  Practice
//
//  Created by Victor Yanuchkov on 06/07/2018.
//  Copyright © 2018 Victor Yanuchkov. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController{
    func validateAlert(title: String, message: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Default action"), style: .default, handler: nil))
        
        return alert
    }
}

