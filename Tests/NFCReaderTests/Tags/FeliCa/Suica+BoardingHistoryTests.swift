//
//  Suica+BoardingHistoryTests.swift
//  
//
//  Created by Tatsuya Tanaka on 2019/08/12.
//

import Foundation

import XCTest
@testable import NFCReader

final class SuicaBoardingHistoryTests: XCTestCase {
    typealias History = Suica.BoardingHistory

    static var dummyTrainData: Data {
        Data([22, 1, 0, 2, 39, 6, 0x30, 0x39, 0xD4, 0x31, 238, 26, 0, 4, 0xD2, 0])
    }

    func testDecodeTrainData() throws {
        let history = try History(data: Self.dummyTrainData)
        XCTAssertEqual(history.rawData.count, 16)
        XCTAssertEqual(history.machineType, History.MachineType.ticketGate)
        XCTAssertFalse(history.isPaymentWithCashAndIC)
        XCTAssertEqual(history.usageType, History.UsageType.exitTicketGate)
        XCTAssertEqual(history.paymentType, History.PaymentType.normal)
        XCTAssertEqual(history.entranceOrExitType, History.EntranceOrExitType.entranceOrExit)
        XCTAssertEqual(history.year, 19)
        XCTAssertEqual(history.month, 8)
        XCTAssertEqual(history.day, 6)
        XCTAssertEqual(history.code1, 12345)
        XCTAssertEqual(history.code2, 54321)
        XCTAssertEqual(history.balance, 6_894)
        XCTAssertEqual(history.unknown, 0)
        XCTAssertEqual(history.sequentialNumber, 1234)
        XCTAssertEqual(history.areaCode, 0)
        XCTAssertEqual(history.kind, History.Kind.publicOrPrivate)
        switch history.detail {
        case .train(let train):
            XCTAssertEqual(train.entranceCode, history.code1)
            XCTAssertEqual(train.exitCode, history.code2)
        default:
            XCTFail()
        }
    }

    func testDecodeShoppingData() throws {
        let data = Data([200, 70, 0, 0, 39, 6, 112, 35, 37, 17, 138, 26, 0, 4, 0xD2, 0])
        let history = try History(data: data)
        XCTAssertEqual(history.rawData.count, 16)
        XCTAssertEqual(history.machineType, History.MachineType.shopping2)
        XCTAssertFalse(history.isPaymentWithCashAndIC)
        XCTAssertEqual(history.usageType, History.UsageType.shopping)
        XCTAssertEqual(history.paymentType, History.PaymentType.normal)
        XCTAssertEqual(history.entranceOrExitType, History.EntranceOrExitType.special)
        XCTAssertEqual(history.year, 19)
        XCTAssertEqual(history.month, 8)
        XCTAssertEqual(history.day, 6)
        XCTAssertEqual(history.code1, 28707)
        XCTAssertEqual(history.code2, 9489)
        XCTAssertEqual(history.balance, 6_794)
        XCTAssertEqual(history.unknown, 0)
        XCTAssertEqual(history.sequentialNumber, 1234)
        XCTAssertEqual(history.areaCode, 0)
        XCTAssertEqual(history.kind, History.Kind.shopping)
        switch history.detail {
        case .shopping(let shopping):
            XCTAssertEqual(shopping.hour, 14)
            XCTAssertEqual(shopping.minute, 1)
            XCTAssertEqual(shopping.second, 3)
            XCTAssertEqual(shopping.paymentDeviceId, history.code2)
        default:
            XCTFail()
        }

    }

    static var allTests = [
        ("testDecodeTrainData", testDecodeTrainData),
        ("testDecodeShoppingData", testDecodeShoppingData),
    ]
}
