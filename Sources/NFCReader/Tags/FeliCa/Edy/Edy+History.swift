//
//  Edy+History.swift
//  
//
//  Created by Tatsuya Tanaka on 2019/08/19.
//

import Foundation

public extension Edy {
    struct History: Service {
        /// Service code [lower byte, upper byte] (little-endian)
        public static let serviceCode = Data([0x17, 0x0F])

        /// Block list
        /// - Parameter numberOfBlocks: number of blocks (1-3)
        /// - Parameter serviceCodeIndex: index of service code
        public static func blockList(numberOfBlocks: Int, serviceCodeIndex: Int = 0) -> [Block] {
            (0..<UInt8(numberOfBlocks)).map { Block.two(blockNumber: $0, serviceCodeIndex: UInt8(serviceCodeIndex)) }
        }

        public static var numberOfData = 6

        /// Raw binary data
        public let rawData: Data

        /// Transaction type
        public let transactionType: TransactionType // [0]

        /// Sequential number
        public let sequentialNumber: UInt32 // [1-3]

        /// Year (based on 2000)
        public let year: UInt8 // [4-7]

        /// Month
        public let month: UInt8 // [4-7]

        /// Day
        public let day: UInt8 // [4-7]

        /// Hour
        public let hour: UInt8 // [4-7]

        /// Minute
        public let minute: UInt8 // [4-7]

        /// Second
        public let second: UInt8 // [4-7]

        /// Amount of change
        public let amount: UInt32 // [8-11]

        /// Balance
        public let balance: UInt32 // [12-15]

        public init(data: Data) throws {
            try Self.validate(data: data)
            rawData = data
            transactionType = try TransactionType(rawValue: data[0]).orThrow(TagErrors.dataInconsistency)
            sequentialNumber = UInt32(bytes: data[1...3])

            let dateBits = UInt32(bytes: data[4...7])
            let elapsedDays = dateBits >> 17
            let elapsedSeconds = dateBits & 0b1_1111_1111_1111_1111

            var baseDay = DateComponents(year: 2000, month: 1, day: 1)
            baseDay.day! += Int(elapsedDays)

            let calendar = Calendar(identifier: .gregorian)
            let date = try calendar.date(from: baseDay).orThrow(TagErrors.dataInconsistency)
            let component = calendar.dateComponents([.year, .month, .day], from: date)

            year = try UInt8(component.year.orThrow(TagErrors.dataInconsistency) - 2000)
            month = try UInt8(component.month.orThrow(TagErrors.dataInconsistency))
            day = try UInt8(component.day.orThrow(TagErrors.dataInconsistency))

            let uint32Hour = elapsedSeconds / 60 / 60
            let uint32Minute = (elapsedSeconds - uint32Hour * 60 * 60) / 60
            let uint32Second = elapsedSeconds - uint32Hour * 60 * 60 - uint32Minute * 60

            hour = UInt8(uint32Hour)
            minute = UInt8(uint32Minute)
            second = UInt8(uint32Second)

            amount = UInt32(bytes: data[8...11])
            balance = UInt32(bytes: data[12...15])
        }
    }
}

public extension Edy.History {
    enum TransactionType: UInt8 {
        /// Pay
        case pay = 0x20
        /// Add value
        case addValue = 0x02
        /// Edy gift
        case edyGift = 0x04
    }
}
