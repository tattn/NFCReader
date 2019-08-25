//
//  Nanaco+History.swift
//  
//
//  Created by Tatsuya Tanaka on 2019/08/17.
//

import Foundation

public extension Nanaco {
    struct History: Service {
        /// Service code [lower byte, upper byte] (little-endian)
        public static let serviceCode = Data([0x4F, 0x56])

        /// Block list
        /// - Parameter numberOfBlocks: number of blocks (1-5)
        /// - Parameter serviceCodeIndex: index of service code
        public static func blockList(numberOfBlocks: Int, serviceCodeIndex: Int = 0) -> [Block] {
            (0..<UInt8(numberOfBlocks)).map { Block.two(blockNumber: $0, serviceCodeIndex: UInt8(serviceCodeIndex)) }
        }

        public static var numberOfData = 5

        /// Raw binary data
        public let rawData: Data

        /// Transaction type
        public let transactionType: TransactionType // [0]

        /// Amount of change
        public let amount: UInt32 // [1-4]

        /// Balance
        public let balance: UInt32 // [5-8]

        /// Year (based on 2000)
        public let year: UInt16 // [9-10(2)] (11bit)

        /// Month
        public let month: UInt8 // [10(3)-10(6)] (4bit)

        /// Day
        public let day: UInt8 // [10(7)-11(3)] (5bit)

        /// Hour
        public let hour: UInt8 // [11(4)-12(1)] (6bit)

        /// Minute
        public let minute: UInt8 // [12(2)-12(7)] (6bit)

        /// Sequential number
        public let sequentialNumber: UInt16 // [13-14]


        public init(data: Data) throws {
            try Self.validate(data: data)
            rawData = data
            transactionType = try TransactionType(rawValue: data[0]).orThrow(TagErrors.dataInconsistency)
            amount = UInt32(bytes: data[1...4])
            balance = UInt32(bytes: data[5...8])
            let date = UInt32(bytes: data[9...12])
            year = UInt16((date >> 21) & 0b11111111111)
            month = UInt8((date >> 17) & 0b1111)
            day = UInt8((date >> 12) & 0b11111)
            hour = UInt8((date >> 6) & 0b111111)
            minute = UInt8(date & 0b111111)
            sequentialNumber = UInt16(bytes: data[13...14])
        }
    }
}

public extension Nanaco.History {
    enum TransactionType: UInt8 {
        case transfer = 0x35
        case pay = 0x47
        case addValue = 0x6F
        case addValue2 = 0x70
        case addValueByPoint = 0x83
    }
}
