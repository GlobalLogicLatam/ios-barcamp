//
//  UIButton+Gray.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 10/7/16.
//  Copyright © 2016 Global Logic. All rights reserved.
//

import Foundation
import UIKit


extension UIButton {

    func addRedStyle() {
        
        self.backgroundColor = UIColor.clear
        self.setBackgroundColor(UIColor(colorHex:Color.red.default), state: UIControlState.normal)
        self.setBackgroundColor(UIColor(colorHex: Color.red.dark), state: UIControlState.selected)
        self.setTitleColor(UIColor.white, for: UIControlState.normal)
        self.setTitleColor(UIColor.lightGray, for: UIControlState.highlighted)
        self.layer.borderColor = UIColor.clear.cgColor
        self.clipsToBounds = true
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 3
        self.titleLabel?.font = UIFont.systemFont(ofSize: 18)
    }
    
}
