//
//  SweeperHelperProtocol.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 07/08/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation
import BitcoinKit
import Promises

protocol SweeperHelperProtocol: class {
    func sweep(keyBalances: [KeyBalance], destinationAddress: String) -> Promise<String>
    func balance(privateKey: PrivateKey) -> Promise<BNBalance>
    func balance(byAddress address: String) -> Promise<BNBalance>
    func recipientAddress() -> Promise<String>
    func wifToPrivateKey(wif: String) throws -> PrivateKey
}
