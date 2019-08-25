//
//  Edy+HistoryTests.swift
//  
//
//  Created by Tatsuya Tanaka on 2019/08/19.
//

import Foundation

import XCTest
@testable import NFCReader

final class EdyHistoryTests: XCTestCase {
    typealias History = Edy.History

    static var dummyHistoryData: Data {
        Data([0x20, 1, 2, 3, 0b00111000, 0b00010100, 0b00110000, 0b00111001, 0, 0, 1, 2, 0, 0, 1, 2])
    }

    func testDecodeData() throws {
        let history = try History(data: Self.dummyHistoryData)
        XCTAssertEqual(history.rawData.count, 16)
        XCTAssertEqual(history.transactionType, History.TransactionType.pay)
        XCTAssertEqual(history.sequentialNumber, 66051)
        XCTAssertEqual(history.year, 19)
        XCTAssertEqual(history.month, 8)
        XCTAssertEqual(history.day, 27)
        XCTAssertEqual(history.hour, 3)
        XCTAssertEqual(history.minute, 25)
        XCTAssertEqual(history.second, 45)
        XCTAssertEqual(history.amount, 258)
        XCTAssertEqual(history.balance, 258)
    }

    static var allTests = [
        ("testDecodeData", testDecodeData),
    ]
}
