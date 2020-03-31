//
//  BNBalance.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 12/07/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation

public struct BNBalance: Decodable {
    public let confirmed: UInt64
    public let unconfirmed: UInt64
    public let balance: UInt64
}
