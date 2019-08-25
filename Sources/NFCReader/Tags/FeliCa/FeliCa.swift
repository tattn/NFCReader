//
//  FeliCa.swift
//  
//
//  Created by Tatsuya Tanaka on 2019/08/17.
//

import Foundation
import CoreNFC

public enum FeliCa: MultipleTags {
    case edy(Edy)
    case nanaco(Nanaco)
    case suica(Suica)
    case waon(Waon)

    public static var allTags: [__Tag.Type] = [Edy.self, Nanaco.self, Suica.self, Waon.self]

    public var rawValue: NFCFeliCaTag {
        switch self {
        case .edy(let tag): return tag.rawValue
        case .nanaco(let tag): return tag.rawValue
        case .suica(let tag): return tag.rawValue
        case .waon(let tag): return tag.rawValue
        }
    }

    public static func multiRead(_ tag: NFCFeliCaTag, index: Int, completion: @escaping (Result<Self, TagErrors>) -> Void) {
        switch index {
        case 0:
            Edy.read(tag) { result in
                switch result {
                case .success(let tag):
                    completion(.success(.edy(tag)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        case 1:
            Nanaco.read(tag) { result in
                switch result {
                case .success(let tag):
                    completion(.success(.nanaco(tag)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        case 2:
            Suica.read(tag) { result in
                switch result {
                case .success(let tag):
                    completion(.success(.suica(tag)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        case 3:
            Waon.read(tag) { result in
                switch result {
                case .success(let tag):
                    completion(.success(.waon(tag)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        default:
            fatalError("unreachable")
        }
    }
}
