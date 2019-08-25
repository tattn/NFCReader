//
//  FixedWidthInteger+.swift
//  
//
//  Created by Tatsuya Tanaka on 2019/08/11.
//

import Foundation

extension FixedWidthInteger {
    init(bytes: UInt8...) {
        self.init(bytes: bytes)
    }

    init<T: DataProtocol>(bytes: T) {
        let count = bytes.count - 1
        self = bytes.enumerated().reduce(into: 0) { (result, item) in
            result += Self(item.element) << (8 * (count - item.offset))
        }
    }
}
