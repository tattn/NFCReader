//
//  Error+.swift
//  
//
//  Created by Tatsuya Tanaka on 2019/08/15.
//

import Foundation

extension NSError {
    static func create(code: Int = 0, message: String) -> NSError {
        NSError(domain: "com.github.tattn.Suica", code: code, userInfo: [
            NSLocalizedDescriptionKey: message
        ])
    }
}
