//
// Created by Swen van Zanten on 12/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

extension Vws {
    struct TxHistory: Decodable {
        let txid: String
        let action: String
        let amount: Int64
        let fees: Int64?
        let time: Int64
        let confirmations: Int64
        let blockheight: Int64?
        let feePerKb: Int64?
        let inputs: [InputOutput]?
        let outputs: [InputOutput]?
        let savedAddress: String?
        let createdOn: Int64?
        var message: String?
        var addressTo: String?

        var amountValue: NSNumber {
            return NSNumber(value: Double(self.amount) / Constants.satoshiDivider)
        }

        var address: String {
            if let address = self.savedAddress {
                return address
            }

            if self.category == .Received {
                if let address = self.inputs?.first?.address {
                    return address
                }
            }

            if self.category == .Moved {
                return ""
            }

            return self.outputs?.first { output in
                return output.amount == self.amount
            }?.address ?? (self.addressTo ?? "")
        }

        var category: TxAction {
            switch self.action {
            case "received":
                return .Received
            case "sent":
                return .Sent
            default:
                return .Moved
            }
        }

        var timeReceived: Date {
            return Date(timeIntervalSince1970: TimeInterval(self.time))
        }

        var timeCreatedOn: Date? {
            guard let createdOn = self.createdOn else {
                return nil
            }

            return Date(timeIntervalSince1970: TimeInterval(createdOn))
        }

        var memo: String? {
            return self.message
        }

        var confirmationsCount: String {
            return self.confirmations > 6 ? "6+" : String(self.confirmations < 0 ? 0 : self.confirmations)
        }

        var confirmed: Bool {
            return self.confirmations >= Constants.confirmationsNeeded
        }

        func sortBy(txHistory: TxHistory) -> Bool {
            if self.time == txHistory.time {
                return Double(self.txid.data(using: .utf8)!.first!) > Double(txHistory.txid.data(using: .utf8)!.first!)
            }

            return self.time > txHistory.time
        }
    }
}
