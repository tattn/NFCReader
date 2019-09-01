//
//  Waon.swift
//  
//
//  Created by Tatsuya Tanaka on 2019/08/17.
//

import Foundation
import CoreNFC

public struct Waon: FeliCaTag {
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
                    let fixedDataList = dataList[0].eachSlice(2).map(Array.init).map {
                        $0[0] + $0[1]
                    }
                    let waon = try Waon(
                        tag: tag,
                        historyData: fixedDataList)
                    completion(.success(waon))
                } catch let error {
                    completion(.failure(error as? TagErrors ?? .decodeFailure(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

private extension Array {
    func eachSlice(_ n: Int) -> [ArraySlice<Element>] {
        stride(from: 0, through: count - 1, by: n)
            .map { self[($0..<$0+n).clamped(to: indices)] }
    }
}
