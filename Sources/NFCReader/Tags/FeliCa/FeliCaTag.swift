//
//  FeliCaTag.swift
//  
//
//  Created by Tatsuya Tanaka on 2019/09/01.
//

import Foundation
import CoreNFC

public protocol FeliCaTag: Tag {
    static var services: [FeliCaService.Type] { get }
}
