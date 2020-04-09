//
// Created by Swen van Zanten on 12/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

extension Vws {
    struct InputOutput: Decodable {
        let amount: Int
        let address: String
        let isMine: Bool?

        var amountValue: NSNumber {
            return NSNumber(value: Double(amount) / Constants.satoshiDivider)
        }
    }
}
