//
//  BlockTests.swift
//  
//
//  Created by Tatsuya Tanaka on 2019/08/16.
//

import Foundation
import XCTest
@testable import NFCReader

final class BlockTests: XCTestCase {
    func testTwo() {
        let block = Block.two(blockNumber: 64, serviceCodeIndex: 0b1010)
        switch block.length {
        case .two(let blockNumber):
            XCTAssertEqual(blockNumber, 63)
        case .three:
            XCTFail()
        }
        XCTAssertTrue(block.length.isTwo)
        XCTAssertEqual(block.accessMode, 0)
        XCTAssertEqual(block.serviceCodeIndex, 0b1010)
        XCTAssertEqual(block.blockNumbers, [64])
        XCTAssertEqual(block.data, Data([138, 64]))
    }

    static var allTests = [
        ("testTwo", testTwo),
    ]
}
