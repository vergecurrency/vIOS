//
// Created by Swen van Zanten on 12/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

public struct TxHistory: Decodable {

    public let txid: String
    public let action: String
    public let amount: Int
    public let fees: Int
    public let time: Int
    public let confirmations: Int
    public let feePerKb: Int
    public let inputs: [InputOutput]?
    public let outputs: [InputOutput]

}

extension TxHistory {
    public var amountValue: NSNumber {
        return NSNumber(value: Double(amount) / Config.satoshiDivider)
    }

    public var address: String {
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

    public var memo: String {
        return "Memo bro"
    }
}
