//
//  WebImageDownloader.swift
//  ImageSearch
//
//  Created by 박정민 on 2020/07/05.
//  Copyright © 2020 jeongminPark. All rights reserved.
//

import Foundation
import UIKit

class WebImageDownloader {
    static let shared = WebImageDownloader()
    let imageCache = NSCache<NSString, UIImage>()
    
    func downloadImage(with url: URL, completionHandler: @escaping (UIImage?, Error?) -> ()) {
        let cacheKeyForImage = url.absoluteString as NSString
        if let cachedImage = imageCache.object(forKey: cacheKeyForImage) {
            completionHandler(cachedImage, nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data,
                let image = UIImage(data: data) {
                self.imageCache.setObject(image, forKey: cacheKeyForImage)
                completionHandler(image, error)
                
            } else {
                completionHandler(nil, error)
            }
        }.resume()
    }
}
