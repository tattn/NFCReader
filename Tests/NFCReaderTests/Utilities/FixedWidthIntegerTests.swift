//
//  FixedWidthIntegerTests.swift
//  
//
//  Created by Tatsuya Tanaka on 2019/08/12.
//

import Foundation

import XCTest
@testable import NFCReader

final class FixedWidthIntegerTests: XCTestCase {
    func testInitFromByteArray() throws {
        XCTAssertEqual(UInt16(bytes: 0x35, 0x0B), 13579)
        XCTAssertEqual(Int(bytes: 0x07, 0x5B, 0xCD, 0x15), 123456789)
    }

    static var allTests = [
        ("testInitFromByteArray", testInitFromByteArray),
    ]
}
