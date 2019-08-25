import XCTest
import CoreNFC
@testable import NFCReader

final class TagTests: XCTestCase {
    func testFeliCaSystemCodeAndIdm() throws {
        struct TestTag: Tag {
            var rawValue: NFCFeliCaTag
            static var allServices: [Service.Type] = []
            static func read(_ tag: NFCFeliCaTag, completion: @escaping (Result<Self, TagErrors>) -> Void) {}
        }

        let tag = MockFeliCaTag(currentSystemCode: Data([111, 121, 222]), currentIDm: Data([222, 121, 111]))
        let testTag = TestTag(rawValue: tag)
        XCTAssertEqual(testTag.systemCode, "6f79de")
        XCTAssertEqual(testTag.idm, "de796f")
    }

    static var allTests = [
        ("testFeliCaSystemCodeAndIdm", testFeliCaSystemCodeAndIdm),
    ]
}
