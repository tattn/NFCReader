//
//  Edy.swift
//  
//
//  Created by Tatsuya Tanaka on 2019/08/19.
//

import Foundation
import CoreNFC

public struct Edy: FeliCaTag {
    public let rawValue: NFCFeliCaTag
    public let histories: [History]

    public static let services: [FeliCaService.Type] = [History.self]

    init(tag: NFCFeliCaTag, historyData: [Data]) throws {
        rawValue = tag
        histories = try historyData.map(History.init)
    }

    public static func read(_ tag: NFCFeliCaTag, completion: @escaping (Result<Self, TagErrors>) -> Void) {
        services.readWithoutEncryption(with: tag) { result in
            switch result {
            case .success(let dataList):
                do {
                    let edy = try Edy(
                        tag: tag,
                        historyData: dataList[0])
                    completion(.success(edy))
                } catch let error {
                    completion(.failure(error as? TagErrors ?? .decodeFailure(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
