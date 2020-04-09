//
// Created by Swen van Zanten on 14/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

extension Vws {
    struct TxOutput: Decodable {
        let amount: Int64
        let message: String?
        let encryptedMessage: String?
        let toAddress: String
        let ephemeralPrivKey: String?
        let stealth: Bool?

        var amountValue: NSNumber {
            return NSNumber(value: Double(amount) / Constants.satoshiDivider)
        }
    }
}
