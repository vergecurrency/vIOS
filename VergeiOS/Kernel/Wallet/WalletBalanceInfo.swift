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
//    public let byAddress: Int[]

}
