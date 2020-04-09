//
// Created by Swen van Zanten on 12/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

extension Vws {
    struct AddressBalance: Decodable {
        let address: String
        let path: String?
        let amount: Double

        var amountValue: NSNumber {
            return NSNumber(value: amount / Constants.satoshiDivider)
        }
    }
}
