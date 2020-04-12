//
//  TransactionFactoryProtocol.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 13/07/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation
import BitcoinKit

protocol TransactionFactoryProtocol {
    func getUnsignedTx(
        balance: Bn.Balance,
        destinationAddress: String,
        outputs: [Bn.Transaction]
    ) throws -> UnsignedTransaction

    func signTx(unsignedTx: UnsignedTransaction, keys: [PrivateKey]) throws -> Transaction
}
