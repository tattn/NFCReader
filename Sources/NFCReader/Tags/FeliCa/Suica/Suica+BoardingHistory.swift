//
//  Suica+BoardingHistory.swift
//  
//
//  Created by Tatsuya Tanaka on 2019/08/11.
//

import Foundation

public extension Suica {
    struct BoardingHistory: FeliCaService {
        /// Service code [lower byte, upper byte] (little-endian)
        public static let serviceCode = Data([0x0f, 0x09])

        /// Block list
        /// - Parameter numberOfBlocks: number of blocks (1-20)
        /// - Parameter serviceCodeIndex: index of service code
        public static func blockList(numberOfBlocks: Int, serviceCodeIndex: Int = 0) -> [Block] {
            (0..<UInt8(numberOfBlocks)).map { Block.two(blockNumber: $0, serviceCodeIndex: UInt8(serviceCodeIndex)) }
        }

        public static var numberOfData = 10

        /// Raw binary data
        public let rawData: Data

        /// Machine type
        public let machineType: MachineType

        /// `true` if you paid by cash and IC. otherwise, `false`
        public let isPaymentWithCashAndIC: Bool

        /// Usage type
        public let usageType: UsageType

        /// Payment type
        public let paymentType: PaymentType

        /// Entrance or exit type
        public let entranceOrExitType: EntranceOrExitType

        /// Year of use
        public let year: UInt8 // 7bit
        /// Month of use
        public let month: UInt8 // 4bit
        /// Day of use
        public let day: UInt8 // 5bit

        /// Code for more information
        public let code1: UInt16
        /// Code for more information
        public let code2: UInt16

        /// Balance
        public let balance: UInt16

        let unknown: UInt8

        /// Sequential number related to history
        public let sequentialNumber: UInt16

        /// Area code
        public let areaCode: UInt8

        public let detail: Detail

        public var kind: Kind {
            usageType.isShopping ? .shopping
                : usageType.isBus ? .bus
                : code1 < 0x80 ? .jr : .publicOrPrivate
        }

        public init(data: Data) throws {
            try Self.validate(data: data)
            rawData = data
            machineType = try MachineType(rawValue: data[0]).orThrow(TagErrors.dataInconsistency)
            isPaymentWithCashAndIC = data[1] >> 7 == 1
            usageType = try UsageType(rawValue: data[1] & 0b01111111).orThrow(TagErrors.dataInconsistency)
            paymentType = try PaymentType(rawValue: data[2]).orThrow(TagErrors.dataInconsistency)
            entranceOrExitType = try EntranceOrExitType(rawValue: data[3]).orThrow(TagErrors.dataInconsistency)
            year = data[4] >> 1
            month = UInt8(UInt16(bytes: data[4], data[5]) >> 5 & 0b00001111)
            day = data[5] & 0b00011111
            code1 = UInt16(bytes: data[6], data[7])
            code2 = UInt16(bytes: data[8], data[9])
            balance = UInt16(bytes: data[11], data[10])
            unknown = data[12]
            sequentialNumber = UInt16(bytes: data[13], data[14])
            areaCode = data[15]

            if usageType == .buyTicket {
                detail = .trainTicket(.init(stationCode: code1, vendingMachineNumber: code2))
            } else if usageType.isShopping {
                detail = .shopping(.init(hour: UInt8(code1 >> 11),
                                         minute: UInt8(code1 >> 5 & 0b111111),
                                         second: UInt8(code1 & 0b11111),
                                         paymentDeviceId: code2))
            } else if usageType.isBus {
                detail = .bus(.init(businessCode: code1, stopCode: code2))
            } else {
                detail = .train(.init(entranceCode: code1, exitCode: code2))
            }
        }
    }
}

public extension Suica.BoardingHistory {
    enum Kind {
        /// [ja] JR
        case jr
        /// [ja] 公営・私鉄
        case publicOrPrivate
        /// [ja] バス
        case bus
        /// [ja] 物販
        case shopping
    }

    enum Detail {
        case train(Train)
        case trainTicket(TrainTicket)
        case bus(Bus)
        case shopping(Shopping)

        public struct Train {
            public let entranceCode: UInt16
            public let exitCode: UInt16
        }

        public struct TrainTicket {
            public let stationCode: UInt16
            public let vendingMachineNumber: UInt16
        }

        public struct Bus {
            public let businessCode: UInt16
            public let stopCode: UInt16
        }

        public struct Shopping {
            public let hour: UInt8
            public let minute: UInt8
            public let second: UInt8
            public let paymentDeviceId: UInt16
        }
    }

    enum MachineType: UInt8 {
        /// [ja] 精算機 (乗り越し)
        case adjustmentMachine = 0x03
        /// [ja] バス・路面
        case bus = 0x05
        /// [ja] 自動券売機
        case ticketVendingMachine = 0x07
        /// [ja] 自動券売機
        case ticketVendingMachine2 = 0x08
        /// [ja] 入金機
        case depositMachine = 0x09
        /// [ja] 自動券売機
        case ticketVendingMachine3 = 0x12
        /// [ja] 駅窓口
        case ticketOffice = 0x14
        /// [ja] 定期券発売機
        case commuterPassVendingMachine = 0x15
        /// [ja] 自動改札機
        case ticketGate = 0x16
        /// [ja] 簡易Suica改札機
        case simpleTicketGate = 0x17
        /// [ja] 駅窓口
        case ticketOffice2 = 0x18
        /// [ja] 窓口処理機
        case ticketOffice3 = 0x19
        /// [ja] 窓口処理機
        case ticketOffice4 = 0x1A
        /// [ja] カードリーダー
        case cardReader = 0x1B
        /// [ja] 精算機 (乗り越し)
        case adjustmentMachine2 = 0x1C
        /// [ja] 乗り換え用改札機
        case transferTicketGate = 0x1D
        /// [ja] 簡易入金機
        case simpleDepositMachine = 0x1F
        /// [ja] 窓口処理機
        case ticketOffice5 = 0x20
        /// [ja] 精算機3
        case adjustmentMachine3 = 0x21
        /// [ja] 窓口処理機
        case ticketOffice6 = 0x22
        /// [ja] 新幹線改札機
        case shinkansenTicketGate = 0x23
        /// [ja] 車内補充券発行機
        case supplementaryTicketMachine = 0x24
        /// [ja] 特典
        case gift = 0x46
        /// [ja] ポイント交換機
        case pointExchanger = 0x48
        /// [ja] 物販・タクシー
        case shopping = 0xC7
        /// [ja] 物販・タクシー
        case shopping2 = 0xC8
    }

    enum UsageType: UInt8 {
        /// [ja] 改札機出場
        case exitTicketGate = 0x01
        /// [ja] SFチャージ
        case sfCharge = 0x02
        /// [ja] 乗車券購入
        case buyTicket = 0x03
        /// [ja] 精算
        case adjustment = 0x04
        /// [ja] 精算
        case adjustment2 = 0x05
        /// [ja] 窓口出場
        case exitByTicketOffice = 0x06
        /// [ja] 新規
        case new = 0x07
        /// [ja] 返金
        case refund = 0x08
        /// [ja] バス
        case bus = 0x0C
        /// [ja] バス
        case bus2 = 0x0D
        /// [ja] バス
        case bus3 = 0x0F
        /// [ja] 再発行
        case reissue = 0x10
        /// [ja] 再発行
        case reissue2 = 0x11
        /// [ja] 自動改札機出場
        case exitTicketGate2 = 0x13
        /// [ja] オートチャージ
        case automaticAddValue = 0x14
        /// [ja] オートチャージ
        case automaticAddValue2 = 0x17
        /// [ja] バスの精算
        case bus4 = 0x19
        /// [ja] バスの精算
        case bus5 = 0x1A
        /// [ja] バスの精算
        case bus6 = 0x1B
        /// [ja] シャトルバス
        case shuttleBus = 0x1D
        /// [ja] チャージ
        case addValue = 0x1F
        /// [ja] 乗車券購入 (バス)
        case buyTicket2 = 0x23
        /// [ja] キャンセル
        case cancel = 0x33
        /// [ja] 物販
        case shopping = 0x46
        /// [ja] ポイントチャージ
        case addValueByPoint = 0x48
        /// [ja] SFチャージ
        case sfCharge2 = 0x49
        /// [ja] 物販での取消
        case cancelOrder = 0x4A

        public var isShopping: Bool {
            switch self {
            case .shopping, .addValueByPoint, .sfCharge, .sfCharge2, .cancelOrder: return true
            default: return false
            }
        }

        public var isBus: Bool {
            switch self {
            case .bus, .bus2, .bus3, .bus4, .bus5, .bus6, .shuttleBus, .addValue, .buyTicket2:  return true
            default: return false
            }
        }

        public var isTrain: Bool {
            return !isShopping && !isBus
        }
    }

    enum PaymentType: UInt8 {
        /// [ja] 通常決済
        case normal = 0x00
        /// [ja] VIEWカード
        case viewCard = 0x02
        /// [ja] PiTaPa
        case pitapa = 0x0B
        /// [ja] クレジットカード
        case creditCard = 0x0C
        /// [ja] PASMO
        case pasmo = 0x0D
        /// [ja] nimoca
        case nimoca = 0x13
         /// [ja] nimoca
        case nimoca2 = 0x1E
         /// [ja] モバイルSuicaアプリ
        case suicaApp = 0x3F
    }

    enum EntranceOrExitType: UInt8 {
        /// [ja] 通常出場および精算以外
        case special = 0x00
        /// [ja] 入場
        case entrance = 0x01
        /// [ja] 入場・出場
        case entranceOrExit = 0x02
        /// [ja] 定期入場・乗り越し精算出場
        case commuterPass = 0x03
        /// [ja] 定期券面前乗車入場・定期出場
        case commuterPass2 = 0x04
        /// [ja] 乗継割引
        case transitDiscount = 0x05
        /// [ja] 窓口出場
        case exitTicketOffice = 0x0E
        /// [ja] バス
        case bus = 0x0F
        /// [ja] 乗継割引
        case transitDiscount2 = 0x17
        /// [ja] 乗継割引
        case transitDiscount3 = 0x1D
        /// [ja] 乗継精算
        case transitAdjustment = 0x21
        /// [ja] 券面外乗降
        case extraFare = 0x22
    }
}
