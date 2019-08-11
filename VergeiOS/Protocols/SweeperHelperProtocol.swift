//
//  SweeperHelperProtocol.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 07/08/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation
import BitcoinKit

protocol SweeperHelperProtocol: class {
    typealias SweepCompletion = (_ error: Error?, _ txid: String?) -> Void

    func sweep(
        balance: BNBalance,
        destinationAddress: String,
        privateKeyWIF: String,
        completion: @escaping SweepCompletion
    ) throws

    func sweep(
        balance: BNBalance,
        destinationAddress: String,
        key: PrivateKey,
        completion: @escaping SweepCompletion
    )

    func balance(
        byPrivateKeyWIF wif: String,
        completion: @escaping (_ error: Error?, _ balance: BNBalance?) -> Void
    ) throws

    func balance(
        byAddress address: String,
        completion: @escaping (_ error: Error?, _ balance: BNBalance?) -> Void
    )

    func recipientAddress(completion: @escaping (_ error: Error?, _ address: String?) -> Void)
}
