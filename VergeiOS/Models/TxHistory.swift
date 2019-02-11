//
// Created by Swen van Zanten on 12/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

public struct TxHistory: Decodable {

    public let txid: String
    public let action: String
    public let amount: Int64
    public let fees: Int64?
    public let time: Int64
    public let confirmations: Int64
    public let blockheight: Int64?
    public let feePerKb: Int64?
    public let inputs: [InputOutput]?
    public let outputs: [InputOutput]?
    public let savedAddress: String?
    public let createdOn: Int64?
    public var message: String?
    public var addressTo: String?

}

extension TxHistory {
    public var amountValue: NSNumber {
        return NSNumber(value: Double(amount) / Constants.satoshiDivider)
    }

    public var address: String {
        if let address = savedAddress {
            return address
        }

        if category == .Received {
            if let address = inputs?.first?.address {
                return address
            }
        }
        
        if category == .Moved {
            return ""
        }

        return outputs?.first { output in
            return output.amount == amount
        }?.address ?? (addressTo ?? "")
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

    public var memo: String? {
        return message
    }

    public var confirmationsCount: String {
        return confirmations > 6 ? "6+" : String(confirmations < 0 ? 0 : confirmations)
    }
    
    public var confirmed: Bool {
        return confirmations >= Constants.confirmationsNeeded
    }

    public func sortBy(txHistory: TxHistory) -> Bool {
        if self.time == txHistory.time {
            return Double(self.txid.data(using: .utf8)!.first!) > Double(txHistory.txid.data(using: .utf8)!.first!)
        }

        return self.time > txHistory.time
    }
}
