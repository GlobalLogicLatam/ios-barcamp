//
//  UIViewController+Error.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 10/14/16.
//  Copyright © 2016 Global Logic. All rights reserved.
//

import Foundation
import UIKit


extension UIViewController {
    
    func showError(title: String = NSLocalizedString("error_message_title", comment: ""), msg: String) {
        let alert = UIAlertController.init(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:nil))
        self.present(alert, animated: true, completion: nil)
    }
}
