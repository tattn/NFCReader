//
//  ReaderConfiguration.swift
//  
//
//  Created by Tatsuya Tanaka on 2019/08/10.
//

import Foundation
import CoreNFC

public struct ReaderConfiguration {
    public var message = Message()

    public init() {}
}

public extension ReaderConfiguration {
    struct Message {
        public var alert: String?
        public var foundMultipleTags: String?

        public init() {}
    }
}
