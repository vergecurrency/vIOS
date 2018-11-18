//
// Created by Swen van Zanten on 12/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

public struct TxHistory: Decodable {

    public let txid: String
    public let action: String
    public let amount: Int64
    public let fees: Int64
    public let time: Int64
    public let confirmations: Int64
    public let feePerKb: Int64
    public let inputs: [InputOutput]?
    public let outputs: [InputOutput]
    public let savedAddress: String?
    public let createdOn: Int64?

}

extension TxHistory {
    public var amountValue: NSNumber {
        return NSNumber(value: Double(amount) / Config.satoshiDivider)
    }

    public var address: String {
        if let address = savedAddress {
            return address
        }

        if category == .Received {
            return inputs?.first?.address ?? ""
        }

        return outputs.first { output in
            return output.amount == amount
        }?.address ?? ""
    }

    public var category: TxAction {
        switch action {
        case "received":
            return .Received
        case "sent":
            return .Sent
        default:
            return .Moved
        }
    }

    public var timeReceived: Date {
        return Date(timeIntervalSince1970: TimeInterval(time))
    }

    public var timeCreatedOn: Date? {
        return createdOn != nil ? Date(timeIntervalSince1970: TimeInterval(createdOn!)) : nil
    }

    public var memo: String {
        return "Memo bro"
    }

    public var confirmationsCount: String {
        return confirmations > 6 ? "6+" : String(confirmations)
    }

    public func sortBy(txHistory: TxHistory) -> Bool {
        if self.time == txHistory.time {
            return Double(self.txid.data(using: .utf8)!.first!) > Double(txHistory.txid.data(using: .utf8)!.first!)
        }

        return self.time > txHistory.time
    }
}
