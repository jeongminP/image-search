//
//  SearchHistoryViewModel.swift
//  ImageSearch
//
//  Created by USER on 2020/07/14.
//  Copyright © 2020 jeongminPark. All rights reserved.
//

import Foundation

final class SearchHistoryViewModel: NSObject, ViewModel {
    let dbManager = HistoryDBManager.shared
    
    var model: [SearchHistoryModel] = [] {
        didSet(oldVal) {
            if oldVal != model {
                isChanged = true
            } else {
                isChanged = false
            }
        }
    }
    @objc dynamic var isChanged: Bool = false
    
    var numOfRows: Int { model.count }
    
    override init() {
        super.init()
        self.fetchHistory()
    }
    
    func fetchHistory() {
        let fetchedData = dbManager.read()
        if fetchedData.isEmpty != true {
            model = fetchedData
        }
    }
    
    func insertNewHistory(keyword: String) {
        let date = currentDateString()
        dbManager.insert(keyword: keyword, date: date)
        
        fetchHistory()
    }
    
    func updateHistory(of model: SearchHistoryModel) {
        let date = currentDateString()
        if let id = model.id,
            let keyword = model.keyword {
            let history = SearchHistoryModel(id: id, keyword: keyword, date: date)
            dbManager.update(history: history)
        }
    }
    
    private func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd hh:mm:ss"
        return formatter.string(from: Date())
    }
    
    func dataForRow(at indexPath: IndexPath) -> SearchHistoryModel {
        return model[indexPath.row]
    }
    
    func insertOrUpdate(with keyword: String) { // 쿼리문으로 검색하는 것으로 변경하기
        for data in model {
            if let prevKeyword = data.keyword,
                prevKeyword == keyword {
                updateHistory(of: data)
                return
            }
        }
        insertNewHistory(keyword: keyword)
    }
}
