//
//  UITextField+Error.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 10/6/16.
//  Copyright © 2016 Global Logic. All rights reserved.
//

import Foundation
import UIKit


extension UITextField {
    
    /**
     Add an error label to current text field
     
     - parameter text: The error text
     */
    func addError(_ text: String) {
        
        if let view = viewWithTag(76001) as? UILabel {
            view.text = text
            return
        }
        
        let frame = self.frame
        let label = UILabel(frame: CGRect.init(x: 0, y: frame.height - 30, width: frame.size.width, height: 10))
        label.textColor = UIColor.red
        label.text = text
        label.textAlignment = NSTextAlignment.right
        label.tag = 76001
        label.font = UIFont.boldSystemFont(ofSize: 10)
        addSubview(label)
    }
    
    /**
     Remove a error label previously created
     */
    func removeError() {
        
        if let label = viewWithTag(76001) {
            label.removeFromSuperview()
        }
    }
    
    
}


