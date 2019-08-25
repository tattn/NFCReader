//
//  Mock.swift
//  
//
//  Created by Tatsuya Tanaka on 2019/08/13.
//

import Foundation
import CoreNFC

class MockFeliCaTag: NSObject, NFCFeliCaTag {
    var currentSystemCode: Data
    var currentIDm: Data
    init(currentSystemCode: Data, currentIDm: Data) {
        self.currentSystemCode = currentSystemCode
        self.currentIDm = currentIDm
    }
    required init(coder aDecoder: NSCoder) { fatalError() }
    func polling(systemCode: Data, requestCode: PollingRequestCode, timeSlot: PollingTimeSlot, completionHandler: @escaping (Data, Data, Error?) -> Void) {}
    func requestService(nodeCodeList: [Data], completionHandler: @escaping ([Data], Error?) -> Void) {}
    func requestResponse(completionHandler: @escaping (Int, Error?) -> Void) {}
    func readWithoutEncryption(serviceCodeList: [Data], blockList: [Data], completionHandler: @escaping (Int, Int, [Data], Error?) -> Void) {}
    func writeWithoutEncryption(serviceCodeList: [Data], blockList: [Data], blockData: [Data], completionHandler: @escaping (Int, Int, Error?) -> Void) {}
    func requestSystemCode(completionHandler: @escaping ([Data], Error?) -> Void) {}
    func requestServiceV2(nodeCodeList: [Data], completionHandler: @escaping (Int, Int, EncryptionId, [Data], [Data], Error?) -> Void) {}
    func requestSpecificationVersion(completionHandler: @escaping (Int, Int, Data, Data, Error?) -> Void) {}
    func resetMode(completionHandler: @escaping (Int, Int, Error?) -> Void) {}
    func sendFeliCaCommand(commandPacket: Data, completionHandler: @escaping (Data, Error?) -> Void) {}
}

class MockTagReaderSession: NFCTagReaderSession {
    enum MockDelegateResult {
        case didDetect([NFCTag])
        case didInvalidateWithError(Error)
    }
    var mockDelegateResult: MockDelegateResult!
    weak var mockDelegate: NFCTagReaderSessionDelegate?

    private var isRestartPolling = false

    override func begin() {
        if !isRestartPolling {
            mockDelegate?.tagReaderSessionDidBecomeActive(self)
        }
        switch mockDelegateResult! {
        case .didDetect(let tags):
            mockDelegate?.tagReaderSession(self, didDetect: tags)
        case .didInvalidateWithError(let error):
            mockDelegate?.tagReaderSession(self, didInvalidateWithError: error)
        }
    }
    var didInvalidate: ((String) -> Void)?
    override func invalidate() {
        isRestartPolling = false
        didInvalidate?("")
    }
    override func invalidate(errorMessage: String) {
        isRestartPolling = false
        didInvalidate?(errorMessage)
    }

    var didRestartPolling: (() -> Void)?
    override func restartPolling() {
        isRestartPolling = true
        didRestartPolling?()
        begin()
    }
}

class MockReaderSession: NSObject, NFCReaderSessionProtocol {
    var isReady: Bool = false
    var alertMessage: String = ""
    func begin() {}
    func invalidate() {}
    func invalidate(errorMessage: String) {}
}

extension MockFeliCaTag: NFCNDEFTag {
    func queryNDEFStatus(completionHandler: @escaping (NFCNDEFStatus, Int, Error?) -> Void) {}
    func readNDEF(completionHandler: @escaping (NFCNDEFMessage?, Error?) -> Void) {}
    func writeNDEF(_ ndefMessage: NFCNDEFMessage, completionHandler: @escaping (Error?) -> Void) {}
    func writeLock(completionHandler: @escaping (Error?) -> Void) {}
}

extension MockFeliCaTag: __NFCTag {
    var type: __NFCTagType { .feliCa }
    weak var session: NFCReaderSessionProtocol? { MockReaderSession() }
    var isAvailable: Bool { true }
    func asNFCISO15693Tag() -> NFCISO15693Tag? { nil }
    func asNFCISO7816Tag() -> NFCISO7816Tag? { nil }
    func asNFCFeliCaTag() -> NFCFeliCaTag? { nil }
    func asNFCMiFareTag() -> NFCMiFareTag? { nil }
}

extension MockFeliCaTag: NSCoding {
    static var supportsSecureCoding: Bool { true }
    func copy(with zone: NSZone? = nil) -> Any { self }
    func encode(with coder: NSCoder) {}
}
