//
//  Publisher+WeakAssign.swift
//  Converter
//
//  Created by Marsel Tzatzo on 9/4/22.
//

import Combine

extension Publisher where Failure == Never {
    func weakAssign<T: AnyObject>(
        to keyPath: ReferenceWritableKeyPath<T, Output>,
        on object: T
    ) -> AnyCancellable {
        sink { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }
}
