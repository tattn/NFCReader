//
//  Optional+.swift
//  
//
//  Created by Tatsuya Tanaka on 2019/08/12.
//

import Foundation

extension Optional {
    func orThrow(_ error: Error) throws -> Wrapped {
        if let value = self {
            return value
        } else {
            throw error
        }
    }
}
