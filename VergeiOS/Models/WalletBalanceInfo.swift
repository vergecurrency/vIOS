//
// Created by Swen van Zanten on 09/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

public struct WalletBalanceInfo: Decodable {

    public let totalAmount: Double
    public let lockedAmount: Double
    public let totalConfirmedAmount: Double
    public let lockedConfirmedAmount: Double
    public let availableAmount: Double
    public let availableConfirmedAmount: Double
    public let byAddress: [AddressBalance]

}

extension WalletBalanceInfo {
    public var totalAmountValue: NSNumber {
        return NSNumber(value: totalAmount / Constants.satoshiDivider)
    }

    public var lockedAmountValue: NSNumber {
        return NSNumber(value: lockedAmount / Constants.satoshiDivider)
    }

    public var totalConfirmedAmountValue: NSNumber {
        return NSNumber(value: totalConfirmedAmount / Constants.satoshiDivider)
    }

    public var lockedConfirmedAmountValue: NSNumber {
        return NSNumber(value: lockedConfirmedAmount / Constants.satoshiDivider)
    }

    public var availableAmountValue: NSNumber {
        return NSNumber(value: availableAmount / Constants.satoshiDivider)
    }

    public var availableConfirmedAmountValue: NSNumber {
        return NSNumber(value: availableConfirmedAmount / Constants.satoshiDivider)
    }

}
