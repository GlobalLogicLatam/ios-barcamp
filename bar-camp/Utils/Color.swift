//
//  Colors.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 10/7/16.
//  Copyright © 2016 Global Logic. All rights reserved.
//

import Foundation
import GLCommons
import UIKit

enum Color{

    enum white: UInt32, ColorHexConvertible {
        var hexValue: UInt32 { return self.rawValue }
        /// TabBar hightkighted text
        case light = 0xffffff55
        case `default` = 0xffffffff
    }

    
    enum black: UInt32, ColorHexConvertible {
        var hexValue: UInt32 { return self.rawValue }
        /// Talk texts like speaker, description, etc
        case `light` = 0x3c3c3cff
        /// Talk title
        case `default` = 0x1f1f1fff // talk titles
    }
    
    enum red: UInt32, ColorHexConvertible {
        var hexValue: UInt32 { return self.rawValue }
        /// Navigation Bar
        /// Red button
        case `default` = 0xde342dff
        /// Red button selected state
        case `dark` = 0xab171aff //buttton selected
        
    }
    
    enum gray: UInt32, ColorHexConvertible {
        var hexValue: UInt32 { return self.rawValue }
        /// UITextfield plaholder
        case `default` = 0x8f8f8fff

        /// Talk times title
        case `dark` = 0x646363ff
        
    }

    enum blue: UInt32, ColorHexConvertible {
        var hexValue: UInt32 { return self.rawValue }
        /// Break time
        case `default` = 0x4c7ea9ff
        
    }

    enum yellow: UInt32, ColorHexConvertible {
        var hexValue: UInt32 { return self.rawValue }
        /// Delayed
        case `default` = 0xffa800ff
        
    }

    enum green: UInt32, ColorHexConvertible {
        var hexValue: UInt32 { return self.rawValue }
        /// On time action button
        case `default` = 0x239d6bff
        
    }
    
    
}

