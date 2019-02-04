//
// Created by Swen van Zanten on 2019-02-04.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import Foundation

public struct SendMaxInfo: Decodable {

    public let size: UInt64
    public let amount: UInt64
    public let fee: UInt64
    public let feePerKb: UInt64
    public let utxosBelowFee: UInt64
    public let amountBelowFee: UInt64
    public let utxosAboveMaxSize: UInt64
    public let amountAboveMaxSize: UInt64

}
