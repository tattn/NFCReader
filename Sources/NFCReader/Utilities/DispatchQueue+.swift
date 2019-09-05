//
//  DispatchQueue+.swift
//  
//
//  Created by Tatsuya Tanaka on 2019/09/05.
//

import Foundation

extension DispatchQueue {
    static func mainAsyncIfNeeded(execute work: @escaping @convention(block) () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }
}
