//
// Created by Swen van Zanten on 17/10/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

struct ChartInfo: Decodable {

    enum CodingKeys: String, CodingKey {
        case marketCapByAvailableSupply = "market_cap_by_available_supply"
        case priceBtc = "price_btc"
        case priceUsd = "price_usd"
        case volumeUsd = "volume_usd"
    }

    let marketCapByAvailableSupply: [[Double]]
    let priceBtc: [[Double]]
    let priceUsd: [[Double]]
    let volumeUsd: [[Double]]

}
