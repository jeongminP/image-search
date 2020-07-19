//
//  ViewModel.swift
//  ImageSearch
//
//  Created by USER on 2020/07/07.
//  Copyright © 2020 jeongminPark. All rights reserved.
//

import Foundation

protocol ViewModel {
    associatedtype ModelType
    var model: ModelType { get set }
    var isChanged: Bool { get set }
}

