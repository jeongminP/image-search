//
//  DiskCache.swift
//  ImageSearch
//
//  Created by USER on 2020/07/20.
//  Copyright © 2020 jeongminPark. All rights reserved.
//

import Foundation

final class DiskCache {
    private static var directoryURLs: [URL] = []
    
    private let fileManager = FileManager.default
    private let cacheDirName: String
    private(set) var cacheDirURL: URL?
    private var queue: DispatchQueue?
    
    init(cacheDirectoryName: String) {
        self.cacheDirName = cacheDirectoryName
        queue = DispatchQueue(label: "com.jeongminPark.ImageSearch.\(cacheDirName)", attributes: .concurrent)
        createDirectory()
    }
    
    static func clear() {
        directoryURLs.forEach {
            do {
                try FileManager.default.removeItem(at: $0)
            } catch let error as NSError {
                print("Error removing files in directory (\($0.path)): \(error.localizedDescription)")
            }
        }
    }
    
    func store(_ data: Data, forKey key: String) {
        guard let fileURL = fileURL(forKey: key) else {
            return
        }
        queue?.async {
            do {
                try data.write(to: fileURL, options: .atomic)
            } catch let error as NSError {
                print("Error Writing File : \(error.localizedDescription)")
            }
        }
    }
    
    func value(forKey key: String, completion: @escaping (Data?) -> Void) {
        guard isCached(forKey: key),
            let fileURL = fileURL(forKey: key) else {
                completion(nil)
                return
        }
        queue?.async {
            do {
                let data = try Data(contentsOf: fileURL)
                completion(data)
                return
            } catch let error as NSError {
                print("Error Reading File : \(error.localizedDescription)")
            }
        }
    }
    
    func isCached(forKey key: String) -> Bool {
        guard let fileURL = fileURL(forKey: key) else {
            return false
        }
        let isCached = queue?.sync {
            return FileManager.default.fileExists(atPath: fileURL.path)
        }
        return isCached ?? false
    }
    
    private func createDirectory() {
        queue?.async { [weak self] in
            guard let self = self,
                let dirURL = self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                return
            }
            self.cacheDirURL = dirURL.appendingPathComponent(self.cacheDirName)
            guard let cacheDirURL = self.cacheDirURL else {
                return
            }
            if self.fileManager.fileExists(atPath: cacheDirURL.path) {
                DiskCache.directoryURLs.append(cacheDirURL)
                return
            }
            
            do {
                try self.fileManager.createDirectory(atPath: cacheDirURL.path, withIntermediateDirectories: false, attributes: nil)
                DiskCache.directoryURLs.append(cacheDirURL)
            } catch let error as NSError {
                print("Error creating directory: \(error.localizedDescription)")
            }
        }
    }
    
    private func fileURL(forKey key: String) -> URL? {
        return cacheDirURL?.appendingPathComponent(key)
    }
}
