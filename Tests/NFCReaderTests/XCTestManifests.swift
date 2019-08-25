import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(TagTests.allTests),
        testCase(FixedWidthIntegerTests.allTests),
        testCase(ReaderTests.allTests),
        testCase(BlockTests.allTests),
        testCase(SuicaBoardingHistoryTests.allTests),
        testCase(SuicaCardInformationTests.allTests),
        testCase(NanacoHistoryTests.allTests),
        testCase(WaonHistoryTests.allTests),
        testCase(ServiceTests.allTests),
        testCase(MultipleTagsTests.allTests),
        testCase(FeliCaTagTests.allTests),
    ]
}
#endif
