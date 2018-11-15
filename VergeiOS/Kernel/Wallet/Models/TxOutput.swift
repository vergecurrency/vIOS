//
// Created by Swen van Zanten on 14/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

public struct TxOutput: Decodable {

    public let amount: Int64
    public let message: String?
    public let encryptedMessage: String?
    public let toAddress: String

}

extension TxOutput {
    public var amountValue: NSNumber {
        return NSNumber(value: Double(amount) / Config.satoshiDivider)
    }
}
