//
//  SearchResult.swift
//  ImageSearch
//
//  Created by 박정민 on 2020/07/02.
//  Copyright © 2020 jeongminPark. All rights reserved.
//

import Foundation

//final class DataManager {   // DB 대용. 추후 삭제
//    static let shared: DataManager = DataManager()
//    var searchResult: SearchResult?
//}

struct SearchResult: Codable {
    let lastBuildData: String?
    let total: Int?
    let start: Int?
    let display: Int?
    let items: [ImageInfo]
}

struct ImageInfo: Codable, Equatable {
    let title: String?
    let link: String?
    let thumbnail: String?
    let sizeHeight: Int?
    let sizeWidth: Int?
}
