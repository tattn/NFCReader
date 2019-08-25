//
//  Nanaco+HistoryTests.swift
//  
//
//  Created by Tatsuya Tanaka on 2019/08/17.
//

import Foundation

import XCTest
@testable import NFCReader

final class NanacoHistoryTests: XCTestCase {
    typealias History = Nanaco.History

    static var dummyHistoryData: Data {
        Data([71, 0, 0, 0, 200, 0, 0, 4, 247, 2, 113, 19, 210, 3, 21, 0])
    }

    func testDecodeData() throws {
        let history = try History(data: Self.dummyHistoryData)
        XCTAssertEqual(history.rawData.count, 16)
        XCTAssertEqual(history.transactionType, History.TransactionType.pay)
        XCTAssertEqual(history.amount, 200)
        XCTAssertEqual(history.balance, 1271)
        XCTAssertEqual(history.year, 19)
        XCTAssertEqual(history.month, 8)
        XCTAssertEqual(history.day, 17)
        XCTAssertEqual(history.hour, 15)
        XCTAssertEqual(history.minute, 18)
        XCTAssertEqual(history.sequentialNumber, 789)
    }

    static var allTests = [
        ("testDecodeData", testDecodeData),
    ]
}
