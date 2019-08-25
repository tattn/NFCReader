//
//  Reader.swift
//  
//
//  Created by Tatsuya Tanaka on 2019/08/10.
//

import Foundation
import CoreNFC

open class Reader<T: Tag>: NSObject {
    public typealias DidBecomeActive = (Reader) -> Void
    public typealias DidDetect = (Reader, Result<T, Errors>) -> Void

    open private(set) var session: NFCTagReaderSession?
    open var configuration: ReaderConfiguration

    var didBecomeActive: DidBecomeActive?
    var didDetect: DidDetect?
    var isReadyToRestart = false

    public required init(configuration: ReaderConfiguration = .init()) {
        self.configuration = configuration
    }

    /// Start reading a NFC tag.
    /// - Parameter didBecomeActive: Gets called when the reader has started reading
    /// - Parameter didDetect: Gets called when the reader detects NFC tag(s) or occurs some errors
    open func read(didBecomeActive: DidBecomeActive? = nil,
                   didDetect: @escaping DidDetect) {
        guard NFCTagReaderSession.readingAvailable,
            let session = NFCTagReaderSession(pollingOption: T.pollingOption, delegate: self) else {
                didDetect(self, .failure(.notSupported))
                return
        }
        read(session: session, didBecomeActive: didBecomeActive, didDetect: didDetect)
    }

    // for unit tests
    func read(session: NFCTagReaderSession,
              didBecomeActive: DidBecomeActive?,
              didDetect: @escaping DidDetect) {
        self.session = session
        self.didBecomeActive = didBecomeActive
        self.didDetect = didDetect

        configuration.message.alert.map { session.alertMessage = $0 }
        session.begin()
    }

    /// After calling, the reader restarts reading tags. This method can get called in `didDetect` only.
    open func restartReading() {
        isReadyToRestart = true
        session?.restartPolling()
    }

    /// Stops reading and displays an error message to the user.
    /// - Parameter errorMessage: Error message
    open func invalidate(errorMessage: String? = nil) {
        session?._invalidate(errorMessage: errorMessage)
        clean()
    }

    /// Shows message to the user.
    /// - Parameter message: Message that shows the user.
    open func setMessage(_ message: String) {
        session?.alertMessage = message
    }

    func clean() {
        session = nil
        didBecomeActive = nil
        didDetect = nil
        isReadyToRestart = false
    }

    var sessionConnect = NFCTagReaderSession.connect

    public enum Errors: Error {
        /// NFC tag reading is not supported or its configuration of the app is not corrected.
        case notSupported
        /// Occurs some errors while the reader is reading.
        case scanFailure(NFCReaderError)
        /// Detected a tag, but the reader failed to connect the tag.
        case tagConnectionFailure(NFCReaderError)
        /// Failed to decode the tag.
        case readTagFailure(Error)
    }
}

extension Reader: NFCTagReaderSessionDelegate {
    public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        didBecomeActive?(self)
    }

    public func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        didDetect?(self, .failure(.scanFailure(NFCReaderError(error: error))))
    }

    public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard tags.count == 1, let tag = tags.first else {
            configuration.message.foundMultipleTags.map { session.alertMessage = $0 }
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5,
                                              execute: session.restartPolling)
            return
        }

        sessionConnect(session)(tag) { [weak self] error in
            guard let self = self else { return }

            func invalidateAutomatically() {
                if !self.isReadyToRestart {
                    self.invalidate()
                }
                self.isReadyToRestart = false
            }

            if let error = error {
                self.didDetect?(self, .failure(.tagConnectionFailure(NFCReaderError(error: error))))
                invalidateAutomatically()
                return
            }

            T.__read(tag) { result in
                self.didDetect?(self, result.mapError(Errors.readTagFailure))
                invalidateAutomatically()
            }
        }
    }
}

