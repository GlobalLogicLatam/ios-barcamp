//
//  UIImageResize.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 10/28/16.
//  Copyright © 2016 Global Logic. All rights reserved.
//

import Foundation
import UIKit

//http://stackoverflow.com/questions/31314412/how-to-resize-image-in-swift

func ResizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
    let size = image.size
    
    let widthRatio  = targetSize.width  / image.size.width
    let heightRatio = targetSize.height / image.size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize.init(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize.init(width: size.width * widthRatio, height: size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
}

func Image(withColor: UIColor, size: CGSize) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
    let p = UIBezierPath.init(rect: CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
    withColor.setFill()
    p.fill()
    let img = UIGraphicsGetImageFromCurrentImageContext()
    
    return img
}
