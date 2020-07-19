//
//  ViewController.swift
//  ImageSearch
//
//  Created by 박정민 on 2020/07/01.
//  Copyright © 2020 jeongminPark. All rights reserved.
//

import UIKit
import SnapKit

final class SearchViewController: UIViewController, View {
    @objc dynamic var viewModel = SearchViewModel()
    var observer: Observer?
    
    // UI components
    private let searchController = UISearchController(searchResultsController: nil)
    private var imageCollectionView: UICollectionView?
    
    let historyView = SearchHistoryView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Image Search"
        view.backgroundColor = UIColor.white
        setupSettingButton()
        
        bindViewModel()
        setupSearchVC()
        setupCollectionView()
        setupRefreshControl()
        setupHistoryView()
    }
    
    // MARK: - setup
    func bindViewModel() {
        observer = Observer()
        observer?.observe(viewModel, target: \.isChanged) { [weak self] viewModel, change in
            guard let self = self,
                viewModel.isChanged else {
                return
            }

            DispatchQueue.main.async {
                self.imageCollectionView?.reloadData()
            }
        }
    }
    
    private func setupSettingButton() {
        let button = UIButton(type: .custom)
        setButtonImage(with: UIImage(named: "Ion_ios_settings"), of: button)
        button.addTarget(self, action: #selector(settingButtonClicked), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    private func setupHistoryView() {
        view.addSubview(historyView)
        historyView.delegate = self
        historyView.isHidden = true
        
        historyView.snp.makeConstraints{ make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(1)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
        }
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
    
    @objc private func settingButtonClicked() {
        let settingVC = SettingViewController()
        present(settingVC, animated: true, completion: nil)
    }
    
    private func setButtonImage(with image: UIImage?, of button: UIButton?) {
        guard let image = image, let button = button else { return }
        
        let templateImage = resizedImage(at: image, for: CGSize(width: 30, height: 30))
            .withRenderingMode(.alwaysTemplate)
        button.setImage(templateImage, for: .normal)
        button.tintColor = UIColor.darkGray
    }
    
    private func resizedImage(at image: UIImage, for size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

// MARK: - searchViewController
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        historyView.isHidden = true
        // scroll to top
        if viewModel.numOfItems > 0 {
            imageCollectionView?.scrollToItem(at: IndexPath(item: 0, section: 0),
                                              at: .top, animated: false)
            view.layoutIfNeeded()
        }
        
        if let queryValue: String = searchController.searchBar.text,
            !queryValue.isEmpty {
            historyView.searchButtonClicked(with: queryValue)
            viewModel.searchButtonClicked(with: queryValue)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        historyView.willAppear()
        historyView.isHidden = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        historyView.isHidden = true
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
            lastIndex > viewModel.numOfItems - 4 else {
                return
        }
        
        viewModel.prfetchItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        viewModel.loadThumbnailImage(at: indexPath.item) { image in
            cell.setThumbnailImageView(image: image)
        }
        
        if let title = viewModel.titleText(at: indexPath.item) {
            cell.setTitleLabel(title: title)
        }
        
        return cell
    }
}

extension SearchViewController: SearchHistoryViewDelegate {
    func search(with keyword: String) {
        searchController.searchBar.text = keyword
        searchBarSearchButtonClicked(searchController.searchBar)
        searchController.searchBar.resignFirstResponder()
    }
}
