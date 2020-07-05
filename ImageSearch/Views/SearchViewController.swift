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
    private let searchViewModel = SearchViewModel()
    
    // UI components
    private let searchController = UISearchController(searchResultsController: nil)
    private var imageCollectionView: UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Image Search"
        view.backgroundColor = UIColor.white
        
        bindViewModel()
        setupSearchVC()
        setupCollectionView()
        setupRefreshControl()
    }
    
    // MARK: - setup
    private func bindViewModel() {
        searchViewModel.items.bind({ (helloText) in
            DispatchQueue.main.async {
                self.imageCollectionView?.reloadData()
            }
        })
    }
    
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
}

// MARK: - searchViewController
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // scroll to top
        if searchViewModel.numOfItems > 0 {
            imageCollectionView?.scrollToItem(at: IndexPath(item: 0, section: 0),
                                              at: .top, animated: false)
            view.layoutIfNeeded()
        }
        
        if let queryValue: String = searchController.searchBar.text,
            !queryValue.isEmpty {
            searchViewModel.searchButtonClicked(with: queryValue)
        }
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
            lastIndex > searchViewModel.numOfItems - 4 else {
                return
        }
        
        searchViewModel.prfetchItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchViewModel.numOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        searchViewModel.loadThumbnailImage(at: indexPath.item) { image in
            cell.setThumbnailImageView(image: image)
        }
        
        if let title = searchViewModel.titleText(at: indexPath.item) {
            cell.setTitleLabel(title: title)
        }
        
        return cell
    }
}
