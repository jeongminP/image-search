//
//  SettingSwitchCellViewModel.swift
//  ImageSearch
//
//  Created by USER on 2020/07/18.
//  Copyright © 2020 jeongminPark. All rights reserved.
//

import Foundation

final class SettingSwitchCellViewModel: NSObject, ViewModel {
    var model: SectionExposeInfo? {
        didSet(oldVal) {
            if oldVal != model {
                isChanged = true
            } else {
                isChanged = false
            }
        }
    }
    @objc dynamic var isChanged: Bool = false
    
    var sectionType: SectionType? {
        model?.section
    }
    
    var sectionName: String? {
        model?.section?.toLabelString()
    }
    
    var isExposing: Bool? {
        model?.isExposing
    }
}
