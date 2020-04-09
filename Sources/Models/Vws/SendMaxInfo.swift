//
// Created by Swen van Zanten on 2019-02-04.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import Foundation

extension Vws {
    struct SendMaxInfo: Decodable {
        let size: UInt64
        let amount: UInt64
        let fee: UInt64
        let feePerKb: UInt64
        let utxosBelowFee: UInt64
        let amountBelowFee: UInt64
        let utxosAboveMaxSize: UInt64
        let amountAboveMaxSize: UInt64
    }
}
