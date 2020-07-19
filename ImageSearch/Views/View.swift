//
//  View.swift
//  ImageSearch
//
//  Created by USER on 2020/07/08.
//  Copyright © 2020 jeongminPark. All rights reserved.
//

import Foundation

protocol View {
    associatedtype ViewModelType
    var viewModel: ViewModelType { get set }
    var observer: Observer? { get set }
    func bindViewModel()
}
