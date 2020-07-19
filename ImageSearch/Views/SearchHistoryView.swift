//
//  SearchHistoryView.swift
//  ImageSearch
//
//  Created by USER on 2020/07/13.
//  Copyright © 2020 jeongminPark. All rights reserved.
//

import UIKit
import SnapKit

protocol SearchHistoryViewDelegate {
    func search(with keyword: String)
}

class SearchHistoryView: UIView, View {
    var viewModel = SearchHistoryViewModel()
    var observer: Observer?
    var delegate: SearchHistoryViewDelegate?
    
    var tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        
        bindViewModel()
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func willAppear() {
        viewModel.fetchHistory()
    }
    
    func searchButtonClicked(with keyword: String) {
        viewModel.insertOrUpdate(with: keyword)
    }
    
    func bindViewModel() {
        observer = Observer()
        observer?.observe(viewModel, target: \.isChanged) { [weak self] viewModel, change in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        let cell = UINib(nibName: "HistoryTableViewCell", bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: "HistoryTableViewCell")
    }
    
}

extension SearchHistoryView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as? HistoryTableViewCell else {
            return UITableViewCell()
        }
        let data = viewModel.dataForRow(at: indexPath)
        
        if let keyword = data.keyword {
            cell.setKeywordLabel(text: keyword)
        }
        if let date = data.date {
            cell.setSearchDateLabel(text: date)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = viewModel.dataForRow(at: indexPath)
        if let keyword = data.keyword {
            delegate?.search(with: keyword)
        }
    }
}
