//
//  Waon+HistoryTests.swift
//  
//
//  Created by Tatsuya Tanaka on 2019/08/17.
//

import Foundation

import XCTest
@testable import NFCReader

final class WaonHistoryTests: XCTestCase {
    typealias History = Waon.History

    static var dummyHistoryData: Data {
        Data([2, 0, 11, 22, 33, 44, 55, 66, 77, 88, 99, 111, 32, 5, 98, 0, 23, 4, 116, 13, 153, 0, 5, 0, 144, 216, 0, 0, 0, 0, 0, 0])
    }

    func testDecodeData() throws {
        let history = try History(data: Self.dummyHistoryData)
        XCTAssertEqual(history.rawData.count, 32)
//        XCTAssertEqual(history.deviceNumber, Data([]))
        XCTAssertEqual(history.sequentialNumber, 1378)
//        XCTAssertEqual(history.unknown, Data([]))
        XCTAssertEqual(history.transactionType, History.TransactionType.pay)
        XCTAssertEqual(history.year, 14)
        XCTAssertEqual(history.month, 8)
        XCTAssertEqual(history.day, 3)
        XCTAssertEqual(history.hour, 12)
        XCTAssertEqual(history.minute, 50)
        XCTAssertEqual(history.balance, 40)
        XCTAssertEqual(history.withdrawal, 4635)
        XCTAssertEqual(history.storedValue, 0)
    }

    static var allTests = [
        ("testDecodeData", testDecodeData),
    ]
}
