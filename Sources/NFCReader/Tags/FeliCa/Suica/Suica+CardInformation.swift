//
//  Suica+CardInformation.swift
//  
//
//  Created by Tatsuya Tanaka on 2019/08/15.
//

import Foundation

public extension Suica {
    struct CardInformation: FeliCaService {
        /// Service code [lower byte, upper byte] (little-endian)
        public static let serviceCode = Data([0x8b, 0x00])

        /// Block list
        /// - Parameter numberOfBlocks: number of blocks (1-1)
        /// - Parameter serviceCodeIndex: index of service code
        public static func blockList(numberOfBlocks: Int, serviceCodeIndex: Int = 0) -> [Block] {
            [Block.two(blockNumber: 0, serviceCodeIndex: UInt8(serviceCodeIndex))]
        }

        public static var numberOfData = 1
        
        /// Raw binary data
        public let rawData: Data

        let unknown: UInt64

        /// Last payment area
        public let lastPaymentArea: PaymentArea

        /// Card type
        public let type: CardType

        let unknown2: UInt16

        /// Balance
        public let balance: UInt16

        let unknown3: UInt8

        /// Automatic incremental number
        public let updateNumber: UInt16

        public init(data: Data) throws {
            try Self.validate(data: data)
            rawData = data

            unknown = UInt64(bytes: data[0..<8])

            lastPaymentArea = try PaymentArea(rawValue: data[8] & 0b00001111).orThrow(TagErrors.dataInconsistency)
            type = try CardType(rawValue: data[8] >> 4).orThrow(TagErrors.dataInconsistency)

            unknown2 = UInt16(bytes: data[9], data[10])
            balance = UInt16(bytes: data[12], data[11])
            unknown3 = data[13]
            updateNumber = UInt16(bytes: data[14], data[15])
        }
    }
}

public extension Suica.CardInformation {
    enum PaymentArea: UInt8 {
        /// [ja] 関東私鉄/バス
        case kantoPrivateRailway
        /// [ja] 中部私鉄/バス
        case chubuPrivateRailway
        /// [ja] 関西私鉄/バス
        case kansaiPrivateRailway
        /// [ja] その他私鉄/バス
        case other
    }

    enum CardType: UInt8 {
        /// [ja] EX-IC
        case exIC = 0
        /// [ja] Suica、PASMO、TOICA、manaca、PiTaPa、nimoca、SUGOCA、はやかけん
        case suica = 2
        /// [ja] ICOCA
        case icoca = 3
    }
}
