//
//  UINavigationController+StatusBarColor.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 11/13/16.
//  Copyright © 2016 Global Logic. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {

    func setStatusBarColor(_ color: UIColor) {
        //The status bar color show a translucent color which is different to default red color. Disabling translucent
        //lead to weird behaviour on view controllers. Also We use this hack to overrides the twitter navigation controller.
        
        //http://stackoverflow.com/questions/30341224/ios-custom-status-bar-background-color-not-displaying
        //http://stackoverflow.com/questions/21180173/unable-to-change-the-status-bar-background-color-color-on-ios-7
        let statusBarColorView = UIView(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20))
        statusBarColorView.backgroundColor = color
        self.tabBarController?.view.addSubview(statusBarColorView)
    }
    
}
