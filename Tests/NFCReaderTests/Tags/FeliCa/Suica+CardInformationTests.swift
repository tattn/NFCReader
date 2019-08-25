//
//  Suica+CardInformationTests.swift
//  SuicaTests
//
//  Created by Tatsuya Tanaka on 2019/08/15.
//

import Foundation

import XCTest
@testable import NFCReader

final class SuicaCardInformationTests: XCTestCase {
    typealias CardInformation = Suica.CardInformation

    static var dummyCardInformationData: Data {
        Data([0, 0, 0, 0, 0, 0, 0, 0, 32, 0, 0, 14, 121, 0, 51, 101])
    }

    func testDecodeData() throws {
        let info = try CardInformation(data: Self.dummyCardInformationData)
        XCTAssertEqual(info.rawData.count, 16)
        XCTAssertEqual(info.lastPaymentArea, CardInformation.PaymentArea.kantoPrivateRailway)
        XCTAssertEqual(info.type, CardInformation.CardType.suica)
        XCTAssertEqual(info.balance, 30990)
        XCTAssertEqual(info.updateNumber, 13157)
    }

    static var allTests = [
        ("testDecodeData", testDecodeData),
    ]
}
