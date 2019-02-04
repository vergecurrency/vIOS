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
    
}
