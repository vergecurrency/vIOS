//
//  XvgInfo.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 07-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation

public struct XvgInfo: Decodable {
    public let raw: XvgInfoRaw
    public let display: XvgInfoDisplay
}

public struct XvgInfoRaw: Decodable {
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
    
    enum CodingKeys: String, CodingKey {
        case price = "PRICE"
        case openday = "OPENDAY"
        case highday = "HIGHDAY"
        case lowday = "LOWDAY"
        case open24Hour = "OPEN24HOUR"
        case high24Hour = "HIGH24HOUR"
        case low24Hour = "LOW24HOUR"
        case change24Hour = "CHANGE24HOUR"
        case changepct24Hour = "CHANGEPCT24HOUR"
        case changeday = "CHANGEDAY"
        case changepctday = "CHANGEPCTDAY"
        case supply = "SUPPLY"
        case mktcap = "MKTCAP"
        case totalvolume24H = "TOTALVOLUME24H"
        case totalvolume24Hto = "TOTALVOLUME24HTO"
    }
}

public struct XvgInfoDisplay: Decodable {
    public let price: String
    public let openday: String
    public let highday: String
    public let lowday: String
    public let open24Hour: String
    public let high24Hour: String
    public let low24Hour: String
    public let change24Hour: String
    public let changepct24Hour: String
    public let changeday: String
    public let changepctday: String
    public let supply: String
    public let mktcap: String
    public let totalvolume24H: String
    public let totalvolume24Hto: String
    
    enum CodingKeys: String, CodingKey {
        case price = "PRICE"
        case openday = "OPENDAY"
        case highday = "HIGHDAY"
        case lowday = "LOWDAY"
        case open24Hour = "OPEN24HOUR"
        case high24Hour = "HIGH24HOUR"
        case low24Hour = "LOW24HOUR"
        case change24Hour = "CHANGE24HOUR"
        case changepct24Hour = "CHANGEPCT24HOUR"
        case changeday = "CHANGEDAY"
        case changepctday = "CHANGEPCTDAY"
        case supply = "SUPPLY"
        case mktcap = "MKTCAP"
        case totalvolume24H = "TOTALVOLUME24H"
        case totalvolume24Hto = "TOTALVOLUME24HTO"
    }
}
