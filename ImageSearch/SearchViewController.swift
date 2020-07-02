//
//  ViewController.swift
//  ImageSearch
//
//  Created by 박정민 on 2020/07/01.
//  Copyright © 2020 jeongminPark. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    private let clientID: String = "11z3u4TeXjtVowtCYWVp"
    private let clientKEY: String = "iImsXl10PT"
    private let maxStartValue = 1000
    private let numOfDisplaysInPage = 20
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    let jsonDecoder = JSONDecoder()
    let dataManager = DataManager.shared
    
    private var hasNext: Bool = true
    private var page: Int = 0
    private var currentQuery: String?
    var items: [ImageInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let collectionView = imageCollectionView else { return }
        
//        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        
        let nibName = UINib(nibName: "ImageCollectionViewCell", bundle: nil)
        collectionView.register(nibName, forCellWithReuseIdentifier: "ImageCollectionViewCell")
    }
    @IBAction func touchUpSearchUpButton(_ sender: Any) {
        guard let queryValue: String = searchTextField.text,
            !queryValue.isEmpty else {
                return
        }
        currentQuery = queryValue
        items = []
        page = 0
        requestAPIToNaver(queryValue: queryValue)
    }
    
    func urlTaskDone() {    // 이미지 다운로드 및 캐싱 여기서 호출해야 할듯.
        DispatchQueue.main.async {
            self.imageCollectionView.reloadData()
        }
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
            self.dataManager.searchResult = searchInfo
            self.items.append(contentsOf: searchInfo.items)
            self.urlTaskDone()
        }
        task.resume()
    }
    
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 2 - 5
        return CGSize(width: width, height: width)
    }
}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        print(indexPaths.last?.item)
        guard let lastIndex = indexPaths.last?.item,
            lastIndex > items.count - 4,
            hasNext == true,
            let queryValue = currentQuery else {
                return
        }
        
        page += 1
        requestAPIToNaver(queryValue: queryValue, startValue: page * numOfDisplaysInPage + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.item]
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell,
            let thumbnailLink = item.thumbnail,
            let imageURL = URL(string: thumbnailLink) else {
                return UICollectionViewCell()
        }
        
        do {
            let imageData = try Data(contentsOf: imageURL)
            let posterImage = UIImage(data: imageData)
            cell.thumbnailImageView.image = posterImage
        } catch { }
        
        let title = item.title?.replacingOccurrences(of: "&quot;", with: "\'")
        cell.titleLabel.text = title
        
        return cell
    }
    
}
