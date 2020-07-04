//
//  SearchViewModel.swift
//  ImageSearch
//
//  Created by 박정민 on 2020/07/03.
//  Copyright © 2020 jeongminPark. All rights reserved.
//

import Foundation

final class SearchViewModel {
    // constants
    private let clientID: String = "11z3u4TeXjtVowtCYWVp"
    private let clientKEY: String = "iImsXl10PT"
    private let maxStartValue = 1000
    private let numOfDisplaysInPage = 20
    
    private let jsonDecoder = JSONDecoder()
    
    // Network property
    private var hasNext: Bool = true
    private var page: Int = 0
    private var currentQuery: String?
    private(set) var items: Dynamic<[ImageInfo]> = Dynamic([ImageInfo]())
    
    // MARK: - Network Request
    func requestAPIToNaver(queryValue: String, startValue: Int = 1) {
        let requestURL = makeRequestURL(queryValue: queryValue, startValue: startValue)
        
        let task = URLSession.shared.dataTask(with: requestURL) { [weak self] data, response, error in
            guard let self = self,
                error == nil,
                let data = data,
                let searchInfo: SearchResult = try? self.jsonDecoder.decode(SearchResult.self, from: data) else {
                    print(error)
                    return
            }
            if let total = searchInfo.total,
                let start = searchInfo.start,
                total >= start + self.numOfDisplaysInPage {
                self.hasNext = true
            }
            self.items.value.append(contentsOf: searchInfo.items)
            self.urlTaskDone()
        }
        task.resume()
    }
    
    private func makeRequestURL(queryValue: String, startValue: Int = 1) -> URLRequest {
        let query: String  = "https://openapi.naver.com/v1/search/image.json?query=\(queryValue)&start=\(startValue)&display=\(numOfDisplaysInPage)&sort=sim"
        let encodedQuery: String = query.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        let queryURL: URL = URL(string: encodedQuery)!
        
        var requestURL = URLRequest(url: queryURL)
        requestURL.addValue(clientID, forHTTPHeaderField: "X-Naver-Client-Id")
        requestURL.addValue(clientKEY, forHTTPHeaderField: "X-Naver-Client-Secret")
        
        return requestURL
    }
    
    private func urlTaskDone() {
        // TODO: - 이미지 다운로드 및 캐싱 구현
    }
    
    // MARK: - search triggered
    func searchButtonClicked(with queryValue: String) {
        clearQueryData(newQuery: queryValue)
        requestAPIToNaver(queryValue: queryValue)
    }
    
    private func clearQueryData(newQuery: String) {
        currentQuery = newQuery
        items.value = []
        hasNext = true
        page = 0
    }
    
    // MARK: - collectionView
    func prfetchItems() {
        guard hasNext == true,
            let queryValue = currentQuery else {
                return
        }
        
        page += 1
        requestAPIToNaver(queryValue: queryValue, startValue: page * numOfDisplaysInPage + 1)
    }
    
    var numOfItems: Int {
        return items.value.count
    }
    
    func thumbnailImageData(at index: Int) -> Data? {
        let item = items.value[index]
        if let thumbnailLink = item.thumbnail,
            let imageURL = URL(string: thumbnailLink),
            let imageData = try? Data(contentsOf: imageURL) {
            
            return imageData
        }
        return nil
    }
    
    func titleText(at index: Int) -> String? {
        let item = items.value[index]
        let title = item.title?.replacingOccurrences(of: "&quot;", with: "\'")
        return title
    }
}
