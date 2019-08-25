//
//  MultipleTags.swift
//  
//
//  Created by Tatsuya Tanaka on 2019/08/18.
//

import Foundation
import CoreNFC

public protocol MultipleTags: Tag {
    static var allTags: [__Tag.Type] { get }
    static var allServices: [Service.Type] { get }
    static func multiRead(_ tag: NFCFeliCaTag, index: Int, completion: @escaping (Result<Self, TagErrors>) -> Void)
}

public extension MultipleTags {
    static var allServices: [Service.Type] {
        allTags.map { $0.allServices }.flatMap { $0 }
    }

    static func read(_ tag: NFCFeliCaTag, completion: @escaping (Result<Self, TagErrors>) -> Void) {
        let services = allTags.compactMap { $0.allServices.first }

        services.requestService(with: tag) { result in
            switch result {
            case .success(let serviceIndex):
                multiRead(tag, index: serviceIndex, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
