//
//  CoreNFC+.swift
//  
//
//  Created by Tatsuya Tanaka on 2019/08/11.
//

import Foundation
import CoreNFC

extension NFCTagReaderSession {
    func _invalidate(errorMessage: String?) {
        if let message = errorMessage {
            invalidate(errorMessage: message)
        } else {
            invalidate()
        }
    }
}

extension NFCReaderError {
    init(error: Error) {
        if let error = error as? NFCReaderError {
            self = error
        } else {
            self.init(_nsError: error as NSError)
        }
    }
}
