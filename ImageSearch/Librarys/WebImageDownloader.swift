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
    private let memCache = NSCache<NSString, UIImage>()
    private let diskCache = DiskCache(cacheDirectoryName: "imageCache")
    
    func downloadImage(with url: URL, completion: @escaping (UIImage?, Error?) -> ()) {
        guard let cacheKey = cacheKey(forURL: url) else {
            print("Error making cacheKey for url : \(url.path)")
            completion(nil, nil)
            return
        }
        
        DispatchQueue.global().async { [weak self] in
            if let cachedImage = self?.memCache.object(forKey: cacheKey as NSString) {
                completion(cachedImage, nil)
                print("memory cache")
                return
            }
            
            self?.diskCache.value(forKey: cacheKey) { [weak self] data in
                if let cachedData = data,
                    let image = UIImage(data: cachedData) {
                    self?.memCache.setObject(image, forKey: cacheKey as NSString)
                    completion(image, nil)
                    print("disk cache")
                    return
                }
                
                URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                    if let self = self,
                        let data = data,
                        let image = UIImage(data: data) {
                        self.memCache.setObject(image, forKey: cacheKey as NSString)
                        self.diskCache.store(data, forKey: cacheKey)
                        completion(image, error)
                        print("load from request")
                    } else {
                        completion(nil, error)
                    }
                }.resume()
            }
        }
    }
    
    private func cacheKey(forURL url: URL) -> String? {
        let urlString = url.absoluteString
        if let lastComponent = urlString.split(separator: "/").last,
            let fileName = lastComponent.split(separator: "?").first?
            .split(separator: "&").first {
            return String(fileName)
        }
        return nil
    }
}
