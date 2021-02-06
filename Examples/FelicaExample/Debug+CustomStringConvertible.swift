//
//  Debug+CustomStringConvertible.swift
//  FeliCaExample
//
//  Created by Tatsuya Tanaka on 2019/08/19.
//  Copyright © 2019 Tatsuya Tanaka. All rights reserved.
//

import Foundation
import NFCReader

extension Suica.BoardingHistory.Detail: CustomStringConvertible {
    public var description: String {
        switch self {
        case .train(let train):
            return "[Train] Entrance: \(train.entranceCode), Exit: \(train.exitCode)"
        case .trainTicket(let ticket):
            return "[Buy a ticket] Station: \(ticket.stationCode), Vending Machine Number: \(ticket.vendingMachineNumber)"
        case .bus(let bus):
            return "[Bus] Business: \(bus.businessCode), Stop: \(bus.stopCode)"
        case .shopping(let shopping):
            return "[Shopping] \(shopping.hour):\(shopping.minute):\(shopping.second)秒 Payment Machine: \(shopping.paymentDeviceId)"
        @unknown default:
            fatalError()
        }
    }
}

extension Suica.BoardingHistory: CustomStringConvertible {
    public var description: String {
        "\(2000+Int(year))/\(month)/\(day) [\(String(describing: machineType))][\(String(describing: usageType))][\(String(describing: paymentType))][\(String(describing: entranceOrExitType))][\(kind)] \(detail) | Balance: \(balance)"
    }
}
