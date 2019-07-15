//
//  BitcoreNodeClientProtocol.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 12/07/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation

protocol BitcoreNodeClientProtocol {
    typealias SendCompletion = (_ error: Error?, _ response: BNSendResponse?) -> Void
    typealias BlockCompletion = (_ error: Error?, _ block: BNBlock?) -> Void
    typealias TransactionCompletion = (_ error: Error?, _ transaction: [BNTransaction]) -> Void
    typealias BalanceCompletion = (_ error: Error?, _ balance: BNBalance?) -> Void
    typealias URLCompletion = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void

    func send(rawTx: String, completion: @escaping SendCompletion)

    func block(byHash hash: String, completion: @escaping BlockCompletion)

    func transactions(byAddress address: String, completion: @escaping TransactionCompletion)
    func unspendTransactions(byAddress address: String, completion: @escaping TransactionCompletion)
    func balance(byAddress address: String, completion: @escaping BalanceCompletion)
}
