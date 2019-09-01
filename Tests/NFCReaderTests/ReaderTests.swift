//
//  ReaderTests.swift
//  
//
//  Created by Tatsuya Tanaka on 2019/08/13.
//

import Foundation
import CoreNFC
import XCTest
@testable import NFCReader

final class ReaderTests: XCTestCase {
    private typealias MockReader = Reader<MockTag>

    func testInitProperty() {
        let reader = MockReader(configuration: .init())
        XCTAssertNil(reader.session)
        XCTAssertNil(reader.configuration.message.alert)
        XCTAssertNil(reader.configuration.message.foundMultipleTags)
        XCTAssertNil(reader.didBecomeActive)
        XCTAssertNil(reader.didDetect)
        XCTAssertFalse(reader.isReadyToRestart)
    }

    func testFoundMultipleTags() {
        var configuration = ReaderConfiguration()
        configuration.message.foundMultipleTags = "foundMultipleTags"
        let mockTag = MockFeliCaTag(currentSystemCode: .init(), currentIDm: .init())

        let (reader, session) = mockReader(configuration: configuration,
                                           result: .didDetect([.feliCa(mockTag), .feliCa(mockTag)]))

        let expect = expectation(description: "foundMultipleTags")
        var count = 0

        session.didRestartPolling = expect.fulfill

        reader.read(session: session, didBecomeActive: { _ in
            count += 1
        }, didDetect: { _, _ in
            count += 2
        })

        wait(for: [expect], timeout: 1.0)
        XCTAssertEqual(count, 1)
        XCTAssertEqual(reader.session?.alertMessage, "foundMultipleTags")
    }

    func testInvalidateAutomatically() {
        let (reader, session) = mockReader()

        var value: MockTag!
        var count = 0

        session.didInvalidate = { _ in
            count += 4
        }

        reader.read(session: session, didBecomeActive: { _ in
            count += 1
        }, didDetect: { _, result in
            count += 2
            value = try! result.get()
        })

        XCTAssertEqual(count, 7)
        XCTAssertEqual(value.rawValue, 1)
        XCTAssertNil(reader.session)
        XCTAssertNil(reader.didBecomeActive)
        XCTAssertNil(reader.didDetect)
    }

    func testRestartReading() {
        let (reader, session) = mockReader()

        var restartCount = 0
        var detectCount = 0

        session.didRestartPolling = {
            restartCount += 1
        }

        reader.read(session: session, didBecomeActive: { _ in
        }, didDetect: { _, result in
            detectCount += 1
            if detectCount < 5 {
                reader.restartReading()
            }
        })

        XCTAssertEqual(restartCount, 4)
        XCTAssertEqual(detectCount, 5)
        XCTAssertFalse(reader.isReadyToRestart)
        XCTAssertNil(reader.session)
        XCTAssertNil(reader.didBecomeActive)
        XCTAssertNil(reader.didDetect)
    }

    private func mockReader(configuration: ReaderConfiguration = .init(),
                            result: MockTagReaderSession.MockDelegateResult? = nil
    ) -> (MockReader, MockTagReaderSession) {
        let reader = MockReader(configuration: configuration)
        reader.sessionConnect = { session in { _, completion in completion(nil) } }

        let session = MockTagReaderSession(pollingOption: .iso18092, delegate: reader)!
        session.mockDelegate = reader
        session.mockDelegateResult = result ?? {
            let mockFeliCaTag = MockFeliCaTag(currentSystemCode: .init(), currentIDm: .init())
            let mockTag = NFCTag.feliCa(mockFeliCaTag)
            return .didDetect([mockTag])
        }()
        return (reader, session)
    }

    static var allTests = [
        ("testInitProperty", testInitProperty),
        ("testFoundMultipleTags", testFoundMultipleTags),
        ("testInvalidateAutomatically", testInvalidateAutomatically),
        ("testRestartReading", testRestartReading),
    ]
}

private struct MockTag: Tag {
    static var pollingOption: NFCTagReaderSession.PollingOption = .iso18092
    static var allServices: [FeliCaService.Type] = []

    var rawValue: Int = 1
    static func read(_ tag: ConcreteTag, completion: @escaping (Result<MockTag, TagErrors>) -> Void) {}
    static func __read(_ tag: NFCTag, completion: @escaping (Result<MockTag, TagErrors>) -> Void) {
        completion(.success(MockTag()))
    }
}
