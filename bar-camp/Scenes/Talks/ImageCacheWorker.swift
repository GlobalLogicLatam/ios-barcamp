//
//  ImageCacheWorker.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 10/17/16.
//  Copyright © 2016 Global Logic. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

protocol ImageCacheProtocol {
    func isImageCache(forKey: String) -> Bool
    func getImage(forKey: String, success: @escaping (_ image: UIImage) -> Swift.Void)
    func cacheImage(key: String, image: UIImage, data: Data)
}

class ImageCacheWorker: ImageCacheProtocol {

    lazy var cache: ImageCache = {
        let _cache = ImageCache.default
        _cache.maxDiskCacheSize = UInt(50 * 1024 * 1024)
        _cache.maxCachePeriodInSecond = TimeInterval(60 * 60 * 24 * 3)

        return _cache
    }()
    
    func isImageCache(forKey: String) -> Bool {
        return self.cache.isImageCached(forKey: forKey).cached
    }
    
    func getImage(forKey: String, success: @escaping (_ image: UIImage) -> Swift.Void) {
        self.cache.retrieveImage(forKey: forKey, options: nil) { (image: Image?, type: CacheType) in
            if let img = image {
                success(img)
            }
            
            return
        }
    }
    
    func cacheImage(key: String, image: UIImage, data: Data) {
        self.cache.store(image, original: data, forKey: key, toDisk: true) {
            print("image stored")
        }
    }
}
