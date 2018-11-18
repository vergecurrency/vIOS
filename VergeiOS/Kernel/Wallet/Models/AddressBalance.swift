//
// Created by Swen van Zanten on 12/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

public struct AddressBalance: Decodable {
    public let address: String
    public let path: String
    public let amount: Int
}

extension AddressBalance {
    public var amountValue: NSNumber {
        return NSNumber(value: Double(amount) / Config.satoshiDivider)
    }
}
