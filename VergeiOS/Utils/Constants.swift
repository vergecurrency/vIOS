//
//  Constants.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 20/10/2018.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation

public struct Constants {

    public static let fetchWalletTimeout: Double = 30
    public static let fetchPriceTimeout: Double = 150
    public static let satoshiDivider: Double = 1000000.0
    public static let confirmationsNeeded: Int = 1

    public static let website: String = "https://vergecurrency.com/"
    public static let iOSRepo: String = "https://github.com/vergecurrency/vIOS"
    public static let blockchainExlorer: String = "https://verge-blockchain.info/"
    public static let bwsEndpoint: String = "https://vws2.swenvanzanten.com/vws/api/"
    public static let priceDataEndpoint: String = "https://usxvglw.vergecoreteam.com/price/api/v1/price/"

    // TODO use other endpoints.
    public static let chartDataEndpoint: String = "https://graphs2.coinmarketcap.com/currencies/"
    public static let ipCheckEndpoint: String = "http://api.ipstack.com/check?access_key=a9e03264eab585d224212a5edcac8fcf&format=1"

    public static let donationXvgAddress: String = "DHe3mTNQztY1wWokdtMprdeCKNoMxyThoV"

}
