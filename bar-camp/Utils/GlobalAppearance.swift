
//  GlobalAppearance.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 10/7/16.
//  Copyright © 2016 Global Logic. All rights reserved.
//

import Foundation
import UIKit


final class GlobalAppearance {

    
    class func setup() {
        setupNavigationBar()
        setupTabBar()
    }
    
    private class func setupNavigationBar() {
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().backgroundColor = UIColor(colorHex: Color.red.default)
        let bgColor = UIColor(colorHex: Color.red.default)
        let img = Image(withColor: bgColor, size: CGSize.init(width: 3, height: 3))
        let res = img?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .stretch)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
        UINavigationBar.appearance().setBackgroundImage(res, for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        UINavigationBar.appearance().isTranslucent = false
    
        
        var attr = [NSFontAttributeName: UIFont.systemFont(ofSize: 17), NSForegroundColorAttributeName: UIColor.white]
        if #available(iOS 8.2, *) {
            attr = [NSFontAttributeName:  UIFont.systemFont(ofSize: 17, weight:UIFontWeightMedium), NSForegroundColorAttributeName: UIColor.white]
        }
        UINavigationBar.appearance().titleTextAttributes = attr
    }
    
    private class func setupTabBar() {
    
        UITabBar.appearance().barTintColor = UIColor(colorHex: Color.red.default)
        UITabBar.appearance().tintColor = UIColor.white
        UITabBar.appearance().isTranslucent = false
        
        let selected = [
            NSForegroundColorAttributeName: UIColor(colorHex: Color.white.default),
            NSFontAttributeName: UIFont.systemFont(ofSize: 20)
        ]

        let normal = [
            NSForegroundColorAttributeName: UIColor(colorHex: Color.white.light),
            NSFontAttributeName: UIFont.systemFont(ofSize: 15)
        ]
        
        if #available(iOS 10.0, *) {
            UITabBar.appearance().unselectedItemTintColor = UIColor(colorHex: Color.white.light)
        }
        
        UITabBarItem.appearance().setTitleTextAttributes(selected, for: UIControlState.selected)
        UITabBarItem.appearance().setTitleTextAttributes(normal, for: UIControlState.normal)
        
    }    
}
