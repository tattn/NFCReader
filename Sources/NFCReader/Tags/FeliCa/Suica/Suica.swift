//
//  Suica.swift
//
//
//  Created by Tatsuya Tanaka on 2019/08/10.
//

import Foundation
import CoreNFC

/// IC for transit. Suica, Pasmo, Kitaca, ICOCA, TOICA、manaca、PiTaPa、nimoca、SUGOCA、はやかけん
public struct Suica: Tag {
    public let rawValue: NFCFeliCaTag
    public let cardInformation: CardInformation
    public let boardingHistories: [BoardingHistory]

    public static let allServices: [Service.Type] = [CardInformation.self, BoardingHistory.self]

    init(tag: NFCFeliCaTag, cardInformationData: Data, boardingHistoryData: [Data]) throws {
        rawValue = tag
        cardInformation = try CardInformation(data: cardInformationData)
        boardingHistories = try boardingHistoryData.map(BoardingHistory.init)
    }

    public static func read(_ tag: NFCFeliCaTag, completion: @escaping (Result<Suica, TagErrors>) -> Void) {
        allServices.readWithoutEncryption(with: tag) { result in
            switch result {
            case .success(let dataList):
                do {
                    let suica = try Suica(
                        tag: tag,
                        cardInformationData: dataList[0][0],
                        boardingHistoryData: dataList[1])
                    completion(.success(suica))
                } catch let error {
                    completion(.failure(error as? TagErrors ?? .decodeFailure(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
