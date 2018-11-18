//
//  Config.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 20/10/2018.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation

struct Config {

    static let fetchWalletTimeout: Double = 30
    static let fetchPriceTimeout: Double = 150
    static let satoshiDivider: Double = 1000000.0

    static let website: String = "https://vergecurrency.com/"
    static let iOSRepo: String = "https://github.com/vergecurrency/vIOS"
    static let blockchainExlorer: String = "https://verge-blockchain.info/"
    static let bwsEndpoint: String = "https://load.vergecoreteam.com/bws/api/"
    static let priceDataEndpoint: String = "https://usxvglw.vergecoreteam.com/price/api/v1/price/"
    static let chartDataEndpoint: String = "https://graphs2.coinmarketcap.com/currencies/"
    static let ipCheckEndpoint: String = "http://api.ipstack.com/check?access_key=e95ebddbee9137302b3cf50b39a33362&format=1"

    static let donationXvgAddress: String = "DHe3mTNQztY1wWokdtMprdeCKNoMxyThoV"

}
