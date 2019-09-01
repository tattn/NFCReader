//
//  FeliCa.swift
//  
//
//  Created by Tatsuya Tanaka on 2019/08/17.
//

import Foundation
import CoreNFC

public enum FeliCa: FeliCaTag {
    case edy(Edy)
    case nanaco(Nanaco)
    case suica(Suica)
    case waon(Waon)
    
    public static var servicesList: [[FeliCaService.Type]] {
        [Edy.services, Nanaco.services, Suica.services, Waon.services]
    }

    public static var services: [FeliCaService.Type] {
        servicesList.flatMap { $0 }
    }

    public var rawValue: NFCFeliCaTag {
        switch self {
        case .edy(let tag): return tag.rawValue
        case .nanaco(let tag): return tag.rawValue
        case .suica(let tag): return tag.rawValue
        case .waon(let tag): return tag.rawValue
        }
    }

    public static func read(_ tag: NFCFeliCaTag, completion: @escaping (Result<Self, TagErrors>) -> Void) {
        let services = servicesList.compactMap { $0.first }

        services.requestService(with: tag) { result in
            switch result {
            case .success(let serviceIndex):
                multiRead(tag, index: serviceIndex, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
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
