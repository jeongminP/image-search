//
//  SettingViewModel.swift
//  ImageSearch
//
//  Created by USER on 2020/07/18.
//  Copyright © 2020 jeongminPark. All rights reserved.
//

import Foundation

enum SectionType: String, CaseIterable {
    case news = "news"
    case book = "book"
    case image = "Image"
    case blog = "blog"
    case cafearticle = "cafearticle"
    
    func toLabelString() -> String {
        switch self {
        case .news: return "뉴스"
        case .book: return "도서"
        case .image: return "이미지"
        case .blog: return "블로그"
        case .cafearticle: return "카페글"
        }
    }
    
    var userDefaultExposingKey: String {
        switch self {
        case .news: return "exposingNews"
        case .book: return "exposingBook"
        case .image: return "exposingImage"
        case .blog: return "exposingBlog"
        case .cafearticle: return "exposingCafe"
        }
    }
}

final class SettingViewModel: NSObject, ViewModel {
    var model = Dictionary<SectionType, Bool>() {
        didSet(oldVal) {
            if oldVal != model {
                isChanged = true
            } else {
                isChanged = false
            }
        }
    }
    @objc dynamic var isChanged: Bool = false
    let sections = SectionType.allCases
    
    override init() {
        super.init()
        sections.forEach {
            let isExposed = UserDefaults.standard.bool(forKey: $0.userDefaultExposingKey)
            model[$0] = isExposed
        }
    }
    
    var numOfRows: Int {
        sections.count
    }
    
    func dataForRow(at indexPath: IndexPath) -> SectionExposeInfo? {
        let index = indexPath.row
        guard index < sections.count else {
            return nil
        }
        let section = sections[index]
        let isExposing = model[section]
        return SectionExposeInfo(section: section, isExposing: isExposing)
    }
    
    func didTappedSwitch(of section: SectionType, with value: Bool) {
        model[section] = value
    }
    
    func applySetting() {
        sections.forEach {
            UserDefaults.standard.set(model[$0], forKey: $0.userDefaultExposingKey)
        }
    }
}
