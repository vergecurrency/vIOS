//
// Created by Swen van Zanten on 12/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

public struct InputOutput: Decodable {
    public let amount: Int
    public let address: String
    public let isMine: Bool?
}

extension InputOutput {
    public var amountValue: NSNumber {
        return NSNumber(value: Double(amount) / Constants.satoshiDivider)
    }
}
