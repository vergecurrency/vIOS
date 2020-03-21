//
//  KeyBalance.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 21/03/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import Foundation
import BitcoinKit

public struct KeyBalance {
    let privateKey: PrivateKey
    let balance: BNBalance
}
