//
//  UICustomizable.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 10/2/16.
//  Copyright © 2016 Global Logic. All rights reserved.
//

import Foundation


/// Types that conform `Customizable` can provide a representation of its ui state.
protocol Customizable {
    
    /// Setup the initial state
    func setupUI()
    
    /// Refresh the ui state
    func updateUI()
}
