//
// Created by Swen van Zanten on 14/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation
import BitcoinKit

extension Vws {
    struct UnspentOutput: Codable {
        enum UnspentOutputError: Error {
            case invalidScriptPubKeyHex(hex: String)
            case invalidTxIdHex(hex: String)
        }

        let address: String
        let confirmations: Int
        let satoshis: UInt64
        let scriptPubKey: String
        let txID: String
        let vout: UInt32
        let publicKeys: [String]
        let path: String
        let locked: Bool

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

        func asUnspentTransaction() throws -> UnspentTransaction {
            guard let lockingScript = Data(fromHex: self.scriptPubKey) else {
                throw UnspentOutputError.invalidScriptPubKeyHex(hex: self.scriptPubKey)
            }

            guard let txid = Data(fromHex: self.txID) else {
                throw UnspentOutputError.invalidTxIdHex(hex: self.txID)
            }

            let transactionOutput = TransactionOutput(value: self.satoshis, lockingScript: lockingScript)
            let txHash: Data = Data(txid.reversed())
            let transactionOutpoint = TransactionOutPoint(hash: txHash, index: self.vout)

            return UnspentTransaction(output: transactionOutput, outpoint: transactionOutpoint)
        }

        func asInputTransaction() throws -> TransactionInput {
            guard let txid = Data(fromHex: self.txID) else {
                throw UnspentOutputError.invalidTxIdHex(hex: self.txID)
            }

            let txHash: Data = Data(txid.reversed())
            let transactionOutpoint = TransactionOutPoint(hash: txHash, index: self.vout)

            return TransactionInput(previousOutput: transactionOutpoint, signatureScript: Data(), sequence: UInt32.max)
        }
    }
}
