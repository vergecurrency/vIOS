//
//  FiatRate.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 07-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation

public struct FiatRate: Decodable {

    public let rank: Int?
    public let price: Double
    public let openday: Double
    public let highday: Double
    public let lowday: Double
    public let open24Hour: Double
    public let high24Hour: Double
    public let low24Hour: Double
    public let change24Hour: Double
    public let changepct24Hour: Double
    public let changeday: Double
    public let changepctday: Double
    public let supply: Double
    public let mktcap: Double
    public let totalvolume24H: Double
    public let totalvolume24Hto: Double

    init(
        rank: Int? = nil,
        price: Double,
        openday: Double,
        highday: Double,
        lowday: Double,
        open24Hour: Double,
        high24Hour: Double,
        low24Hour: Double,
        change24Hour: Double,
        changepct24Hour: Double,
        changeday: Double,
        changepctday: Double,
        supply: Double,
        mktcap: Double,
        totalvolume24H: Double,
        totalvolume24Hto: Double
    ) {
        self.rank = rank
        self.price = price
        self.openday = openday
        self.highday = highday
        self.lowday = lowday
        self.open24Hour = open24Hour
        self.high24Hour = high24Hour
        self.low24Hour = low24Hour
        self.change24Hour = change24Hour
        self.changepct24Hour = changepct24Hour
        self.changeday = changeday
        self.changepctday = changepctday
        self.supply = supply
        self.mktcap = mktcap
        self.totalvolume24H = totalvolume24H
        self.totalvolume24Hto = totalvolume24Hto
    }

}

struct CoinGeckoSimplePriceResponse: Decodable {
    let verge: [String: Double]

    func fiatRate(currency: String) throws -> FiatRate {
        let currencyKey = currency.lowercased()

        guard let price = verge[currencyKey] else {
            throw DecodingError.keyNotFound(
                DynamicCodingKey(stringValue: currencyKey),
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "CoinGecko response did not include \(currency.uppercased()) price for Verge"
                )
            )
        }

        let marketCap = verge["\(currencyKey)_market_cap"] ?? 0
        let volume24Hour = verge["\(currencyKey)_24h_vol"] ?? 0
        let changePct24Hour = verge["\(currencyKey)_24h_change"] ?? 0
        let change24Hour = price * changePct24Hour / 100

        return FiatRate(
            price: price,
            openday: price,
            highday: price,
            lowday: price,
            open24Hour: price - change24Hour,
            high24Hour: price,
            low24Hour: price,
            change24Hour: change24Hour,
            changepct24Hour: changePct24Hour,
            changeday: change24Hour,
            changepctday: changePct24Hour,
            supply: marketCap > 0 ? marketCap / price : 0,
            mktcap: marketCap,
            totalvolume24H: volume24Hour > 0 ? volume24Hour / price : 0,
            totalvolume24Hto: volume24Hour
        )
    }
}

private struct DynamicCodingKey: CodingKey {
    let stringValue: String
    let intValue: Int? = nil

    init(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        return nil
    }
}
