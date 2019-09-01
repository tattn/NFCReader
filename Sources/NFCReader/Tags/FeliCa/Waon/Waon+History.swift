//
//  Waon+History.swift
//  
//
//  Created by Tatsuya Tanaka on 2019/08/17.
//

import Foundation

public extension Waon {
    struct History: FeliCaService {
        /// Service code [lower byte, upper byte] (little-endian)
        public static let serviceCode = Data([0x0b, 0x68])

        /// Block list
        /// - Parameter numberOfBlocks: number of blocks (2-6)
        /// - Parameter serviceCodeIndex: index of service code
        public static func blockList(numberOfBlocks: Int, serviceCodeIndex: Int = 0) -> [Block] {
            (0..<UInt8(numberOfBlocks)).map { Block.two(blockNumber: $0, serviceCodeIndex: UInt8(serviceCodeIndex)) }
        }

        public static var numberOfData = 3
        public static var blocksPerData = 2

        /// Raw binary data
        public let rawData: Data

        /// Device number
        public let deviceNumber: Data // [0-12]

        /// Sequential number
        public let sequentialNumber: UInt16 // [13-14]

        let unknown: Data // [15-16]

        /// Transaction type
        public let transactionType: TransactionType // [17]

        /// Year (based on 2005)
        public let year: UInt8 // [18] (5bit)

        /// Month
        public let month: UInt8 // [18(5)-19(0)] (4bit)

        /// Day
        public let day: UInt8 // [19(1)-19(5)] (5bit)

        /// Hour
        public let hour: UInt8 // [19(6)-20(2)] (5bit)

        /// Minute
        public let minute: UInt8 // [20(3)-21(0)] (6bit)

        /// Balance
        public let balance: UInt32 // [21(1)-23(2)] (18bit)

        /// Withdrawal
        public let withdrawal: UInt32 // [23(3)-25(4)] (18bit)

        /// Amount of added value
        public let storedValue: UInt32 // [25(5)-27(6)] (17bit)
        

        public init(data: Data) throws {
            try Self.validate(data: data)
            rawData = data
            deviceNumber = data[0...12]
            sequentialNumber = UInt16(bytes: data[13...14])
            unknown = data[15...16]
            transactionType = try TransactionType(rawValue: data[17]).orThrow(TagErrors.dataInconsistency)
            year = data[18] >> 3 & 0b11111
            month = UInt8((UInt16(bytes: data[18...19]) >> 7) & 0b1111)
            day = (data[19] >> 2) & 0b11111
            hour = UInt8((UInt16(bytes: data[19...20]) >> 5) & 0b11111)
            minute = UInt8((UInt16(bytes: data[20...21]) >> 7) & 0b111111)
            balance = (UInt32(bytes: data[21...23]) >> 5) & 0b111111111111111111
            withdrawal = (UInt32(bytes: data[23...25]) >> 3) & 0b111111111111111111
            storedValue = (UInt32(bytes: data[25...27]) >> 2) & 0b11111111111111111
        }
    }
}

public extension Waon.History {
    enum TransactionType: UInt8 {
        /// Pay
        case pay = 0x04
        /// Add value to the card
        case addValue = 0x0c
        /// Add Value to the card
        case addValue2 = 0x10
    }
}
