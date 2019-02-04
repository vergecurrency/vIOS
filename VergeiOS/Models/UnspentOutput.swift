//
// Created by Swen van Zanten on 14/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation
import BitcoinKit

public struct UnspentOutput: Codable {

    enum UnspentOutputError: Error {
        case invalidScriptPubKeyHex(hex: String)
        case invalidTxIdHex(hex: String)
    }

    public let address: String
    public let confirmations: Int
    public let satoshis: UInt64
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
    public func asUnspentTransaction() throws -> UnspentTransaction {
        guard let lockingScript = Data(fromHex: scriptPubKey) else {
            throw UnspentOutputError.invalidScriptPubKeyHex(hex: scriptPubKey)
        }

        guard let txid = Data(fromHex: txID) else {
            throw UnspentOutputError.invalidTxIdHex(hex: txID)
        }
        
        let transactionOutput = TransactionOutput(value: satoshis, lockingScript: lockingScript)
        let txHash: Data = Data(txid.reversed())
        let transactionOutpoint = TransactionOutPoint(hash: txHash, index: vout)

        return UnspentTransaction(output: transactionOutput, outpoint: transactionOutpoint)
    }

    public func asInputTransaction() throws -> TransactionInput {
        guard let txid = Data(fromHex: txID) else {
            throw UnspentOutputError.invalidTxIdHex(hex: txID)
        }

        let txHash: Data = Data(txid.reversed())
        let transactionOutpoint = TransactionOutPoint(hash: txHash, index: vout)

        return TransactionInput(previousOutput: transactionOutpoint, signatureScript: Data(), sequence: UInt32.max)
    }
}
