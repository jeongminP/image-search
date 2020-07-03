//
//  ViewController.swift
//  ImageSearch
//
//  Created by 박정민 on 2020/07/01.
//  Copyright © 2020 jeongminPark. All rights reserved.
//

import UIKit
import SnapKit

final class SearchViewController: UIViewController {
    // constants
    private let clientID: String = "11z3u4TeXjtVowtCYWVp"
    private let clientKEY: String = "iImsXl10PT"
    private let maxStartValue = 1000
    private let numOfDisplaysInPage = 20
    
    // Data management
    private let jsonDecoder = JSONDecoder()
    private let dataManager = DataManager.shared
    
    // Network property
    private var hasNext: Bool = true
    private var page: Int = 0
    private var currentQuery: String?
    private var items: [ImageInfo] = []
    
    // UI components
    private let searchController = UISearchController(searchResultsController: nil)
    private var imageCollectionView: UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Image Search"
        view.backgroundColor = UIColor.white
        
        setupSearchVC()
        setupCollectionView()
        setupRefreshControl()
    }
    
    // MARK: - setup
    private func setupSearchVC() {
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "검색어를 입력하세요"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func setupCollectionView() {
        imageCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        guard let imageCollectionView = imageCollectionView else { return }
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.prefetchDataSource = self
        
        imageCollectionView.backgroundColor = UIColor.white
        view.addSubview(imageCollectionView)
        
        let nibName = UINib(nibName: "ImageCollectionViewCell", bundle: nil)
        imageCollectionView.register(nibName, forCellWithReuseIdentifier: "ImageCollectionViewCell")
        
        imageCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(1)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(10)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-10)
        }
    }
    
    private func setupRefreshControl() {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        refresh.attributedTitle = NSAttributedString(string: "새로고침")
        
        if #available(iOS 10.0, *) {
            imageCollectionView?.refreshControl = refresh
        } else {
            imageCollectionView?.addSubview(refresh)
        }
    }
    
    @objc
    private func refresh(_ refresh: UIRefreshControl) {
        refresh.endRefreshing()
        imageCollectionView?.reloadData()
    }
    
    // MARK: - Network Request
    private func requestAPIToNaver(queryValue: String, startValue: Int = 1) {
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
    
    private func makeRequestURL(queryValue: String, startValue: Int = 1) -> URLRequest {
        let query: String  = "https://openapi.naver.com/v1/search/image.json?query=\(queryValue)&start=\(startValue)&display=\(numOfDisplaysInPage)&sort=sim"
        let encodedQuery: String = query.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        let queryURL: URL = URL(string: encodedQuery)!
        
        var requestURL = URLRequest(url: queryURL)
        requestURL.addValue(clientID, forHTTPHeaderField: "X-Naver-Client-Id")
        requestURL.addValue(clientKEY, forHTTPHeaderField: "X-Naver-Client-Secret")
        
        return requestURL
    }
    
    private func urlTaskDone() {    // TODO: - 이미지 다운로드 및 캐싱 구현
        DispatchQueue.main.async {
            self.imageCollectionView?.reloadData()
        }
    }
}

// MARK: - searchViewController
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let queryValue: String = searchController.searchBar.text,
            !queryValue.isEmpty else {
                return
        }
        // scroll to top
        if items.count > 0 {
            imageCollectionView?.scrollToItem(at: IndexPath(item: 0, section: 0),
                                              at: .top, animated: false)
            view.layoutIfNeeded()
        }
        
        clearQueryData(newQuery: queryValue)
        requestAPIToNaver(queryValue: queryValue)
    }
    
    private func clearQueryData(newQuery: String) {
        currentQuery = newQuery
        items = []
        hasNext = true
        page = 0
    }
}

// MARK: - collectionView
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 2 - 5
        return CGSize(width: width, height: width)
    }
}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
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
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if let thumbnailLink = item.thumbnail,
            let imageURL = URL(string: thumbnailLink),
            let imageData = try? Data(contentsOf: imageURL),
            let thumbnailImage = UIImage(data: imageData) {
            cell.setThumbnailImageView(image: thumbnailImage)
        }
        
        if let title = item.title?.replacingOccurrences(of: "&quot;", with: "\'") {
            cell.setTitleLabel(title: title)
        }
        
        return cell
    }
    
}
