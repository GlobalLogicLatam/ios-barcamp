//
//  PasswordAlert.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 10/14/16.
//  Copyright © 2016 Global Logic. All rights reserved.
//

import Foundation
import UIKit

final class PasswordAlert {
    
    typealias compBlock = (String) -> Swift.Void

    lazy var alert: UIAlertController = { [weak self] in
        
        func setupTextField(textField: UITextField!) {
            textField.placeholder = NSLocalizedString("logic_password", comment: "")
            self?.passwordTF = textField
            self?.passwordTF.isSecureTextEntry = true
        }
        
        let alert = UIAlertController(title: NSLocalizedString("logic_enter_password", comment: ""), message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: setupTextField)
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler:nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("done", comment: ""), style: .default, handler:{ (UIAlertAction) in
            if let text = self?.passwordTF.text { self?.block(text) }
        }))
        
        return alert
    }()
    
    let block: compBlock
    var passwordTF: UITextField!
    
    init(_ block: @escaping compBlock) {
        self.block = block
    }
}
