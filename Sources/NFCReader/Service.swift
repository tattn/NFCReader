//
//  Service.swift
//  
//
//  Created by Tatsuya Tanaka on 2019/08/15.
//

import Foundation
import CoreNFC

public protocol Service {
    static var serviceCode: Data { get }
    static func blockList(serviceCodeIndex: Int) -> [Block]
    static func blockList(numberOfBlocks: Int, serviceCodeIndex: Int) -> [Block]
    static var numberOfData: Int { get }
    static var blocksPerData: Int { get }

    init(data: Data) throws
}

public extension Service {
    /// Block list
    /// - Parameter serviceCodeIndex: index of service code
    static func blockList(serviceCodeIndex: Int) -> [Block] {
        blockList(numberOfBlocks: numberOfBlocks, serviceCodeIndex: serviceCodeIndex)
    }

    static var blocksPerData: Int { 1 }
    static var numberOfBlocks: Int { numberOfData * blocksPerData }

    static func validate(data: Data) throws {
        guard data.count == 16 * blocksPerData else {
            throw NSError.create(message: "expected data size is \(16 * blocksPerData), but its size is \(data.count).")
        }
    }
}

extension Array where Element == Service.Type {
    func requestService(with tag: NFCFeliCaTag, completion: @escaping (Result<Int, TagErrors>) -> Void) {
        let serviceCodes = map { $0.serviceCode }
        tag.requestService(nodeCodeList: serviceCodes) { nodes, error in
            if let error = error {
                completion(.failure(.requestFailure(error)))
                return
            }

            let serviceIndex = nodes.map({ $0 != Data([0xff, 0xff]) }).firstIndex(of: true)

            if let serviceIndex = serviceIndex {
                completion(.success(serviceIndex))
            } else {
                completion(.failure(.serviceNotFound))
            }
        }
    }

    func readWithoutEncryption(with tag: NFCFeliCaTag, completion: @escaping (Result<[[Data]], TagErrors>) -> Void) {
        let serviceCodes = map { $0.serviceCode }
        let blockList = enumerated().map {
            $0.element.blockList(serviceCodeIndex: $0.offset).dataList
        }
        let flattenBlockList = blockList.reduce([], +)

        requestService(with: tag) { result in
            if case .failure(let error) = result {
                completion(.failure(error))
                return
            }
            tag.readWithoutEncryption(
                serviceCodeList: serviceCodes,
                blockList: flattenBlockList) { status1, status2, dataList, error in
                    if let error = error {
                        completion(.failure(.readFailure(error)))
                        return
                    }

                    let splitedDataList: [[Data]] = self
                        .map { $0.numberOfBlocks }
                        .reduce(into: []) { (result, size) in
                            let offset = result.count
                            result.append(Array<Data>(dataList[offset..<(offset+size)]))
                    }
                    completion(.success(splitedDataList))
            }
        }
    }
}
