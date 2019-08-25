//
//  Block.swift
//  
//
//  Created by Tatsuya Tanaka on 2019/08/15.
//

import Foundation

public struct Block {
    public let length: Length // 1bit
    public let accessMode: UInt8 // 3bit
    public let serviceCodeIndex: UInt8 // 4bit
    public var blockNumbers: [UInt8] {
        switch length {
        case .two(let number): return [number]
        case .three(let number): return [UInt8(number & 0xFF), UInt8(number >> 8)] // little-endian
        }
    }

    public var data: Data {
        var block0: UInt8 = (length.isTwo ? 1 : 0) << 7
        block0 += accessMode << 4
        block0 += serviceCodeIndex
        return Data([block0] + blockNumbers)
    }

    public static func two(blockNumber: UInt8, serviceCodeIndex: UInt8 = 0) -> Block {
        Block(length: .two(blockNumber: blockNumber), accessMode: 0, serviceCodeIndex: serviceCodeIndex)
    }

    public enum Length {
        case two(blockNumber: UInt8)
        case three(blockNumber: UInt16)
        var isTwo: Bool {
            switch self {
            case .two: return true
            case .three: return false
            }
        }
    }
}

public extension Array where Element == Block {
    var dataList: [Data] {
        map { $0.data }
    }
}
