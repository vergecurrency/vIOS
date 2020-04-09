//
// Created by Swen van Zanten on 09/04/2020.
// Copyright (c) 2020 Verge Currency. All rights reserved.
//

import Foundation

extension Vws {
    struct WalletBalanceInfo: Decodable {
        let totalAmount: Double
        let lockedAmount: Double
        let totalConfirmedAmount: Double
        let lockedConfirmedAmount: Double
        let availableAmount: Double
        let availableConfirmedAmount: Double
        let byAddress: [AddressBalance]

        var totalAmountValue: NSNumber {
            return NSNumber(value: totalAmount / Constants.satoshiDivider)
        }

        var lockedAmountValue: NSNumber {
            return NSNumber(value: lockedAmount / Constants.satoshiDivider)
        }

        var totalConfirmedAmountValue: NSNumber {
            return NSNumber(value: totalConfirmedAmount / Constants.satoshiDivider)
        }

        var lockedConfirmedAmountValue: NSNumber {
            return NSNumber(value: lockedConfirmedAmount / Constants.satoshiDivider)
        }

        var availableAmountValue: NSNumber {
            return NSNumber(value: availableAmount / Constants.satoshiDivider)
        }

        var availableConfirmedAmountValue: NSNumber {
            return NSNumber(value: availableConfirmedAmount / Constants.satoshiDivider)
        }
    }
}
