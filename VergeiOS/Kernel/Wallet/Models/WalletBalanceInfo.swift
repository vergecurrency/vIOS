//
// Created by Swen van Zanten on 09/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

public struct WalletBalanceInfo: Decodable {

    public let totalAmount: Int
    public let lockedAmount: Int
    public let totalConfirmedAmount: Int
    public let lockedConfirmedAmount: Int
    public let availableAmount: Int
    public let availableConfirmedAmount: Int
    public let byAddress: [AddressBalance]

}

extension WalletBalanceInfo {
    public var totalAmountValue: NSNumber {
        return NSNumber(value: Double(totalAmount) / Config.satoshiDivider)
    }

    public var lockedAmountValue: NSNumber {
        return NSNumber(value: Double(lockedAmount) / Config.satoshiDivider)
    }

    public var totalConfirmedAmountValue: NSNumber {
        return NSNumber(value: Double(totalConfirmedAmount) / Config.satoshiDivider)
    }

    public var lockedConfirmedAmountValue: NSNumber {
        return NSNumber(value: Double(lockedConfirmedAmount) / Config.satoshiDivider)
    }

    public var availableAmountValue: NSNumber {
        return NSNumber(value: Double(availableAmount) / Config.satoshiDivider)
    }

    public var availableConfirmedAmountValue: NSNumber {
        return NSNumber(value: Double(availableConfirmedAmount) / Config.satoshiDivider)
    }

}
