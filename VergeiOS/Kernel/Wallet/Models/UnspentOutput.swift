//
// Created by Swen van Zanten on 14/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation
import BitcoinKit

public struct UnspentOutput: Codable {

    public let address: String
    public let confirmations: Int
    public let satoshis: Int64
    public let scriptPubKey: String
    public let txID: String
    public let vout: UInt32
    public let publicKeys: [String]
    public let path: String
    public let locked: Bool

    enum CodingKeys: String, CodingKey {
        case address
        case confirmations
        case satoshis
        case scriptPubKey
        case txID = "txid"
        case vout
        case publicKeys
        case path
        case locked
    }
}

extension UnspentOutput {
    public func asUnspentTransaction() -> UnspentTransaction {
        let transactionOutput = TransactionOutput(value: satoshis, lockingScript: Data(hex: scriptPubKey)!)
        let txid: Data = Data(hex: String(txID))!
        let txHash: Data = Data(txid.reversed())
        let transactionOutpoint = TransactionOutPoint(hash: txHash, index: vout)

        return UnspentTransaction(output: transactionOutput, outpoint: transactionOutpoint)
    }

    public func asInputTransaction() -> TransactionInput {
        let txid: Data = Data(hex: String(txID))!
        let txHash: Data = Data(txid.reversed())
        let transactionOutpoint = TransactionOutPoint(hash: txHash, index: vout)

        return TransactionInput(previousOutput: transactionOutpoint, signatureScript: Data(), sequence: UInt32.max)
    }
}
