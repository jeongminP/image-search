//
//  Observer.swift
//  ImageSearch
//
//  Created by USER on 2020/07/07.
//  Copyright © 2020 jeongminPark. All rights reserved.
//

import Foundation

final class Observer {
    var kvo: [NSKeyValueObservation] = []
    
    func observe<S,T> (_ object: S, target keypath: KeyPath<S, T>, with handler: @escaping (S, NSKeyValueObservedChange<T>) -> Void) where S: NSObject, T: Any {
        kvo.append(object.observe(keypath, changeHandler: handler))
    }
    
    deinit {
        kvo.forEach {
            $0.invalidate()
        }
    }
}

