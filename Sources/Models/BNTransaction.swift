//
//  Transaction.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 12/07/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation
import BitcoinKit

struct BNTransaction: Decodable {
    enum UnspentOutputError: Error {
        case invalidScriptPubKeyHex(hex: String)
        case invalidTxIdHex(hex: String)
    }

    public let chain: String
    public let network: String
    public let coinbase: Bool
    public let mintIndex: UInt32
    public let spentTxid: String
    public let mintTxid: String
    public let mintHeight: UInt64
    public let spentHeight: Int64
    public let address: String
    public let script: String
    public let value: UInt64
    public let confirmations: Int64
}

extension BNTransaction {
    public func asUnspentTransaction() throws -> UnspentTransaction {
        guard let lockingScript = Data(fromHex: self.script) else {
            throw UnspentOutputError.invalidScriptPubKeyHex(hex: self.script)
        }

        guard let txid = Data(fromHex: self.mintTxid) else {
            throw UnspentOutputError.invalidTxIdHex(hex: self.mintTxid)
        }

        let transactionOutput = TransactionOutput(value: self.value, lockingScript: lockingScript)
        let txHash: Data = Data(txid.reversed())
        let transactionOutpoint = TransactionOutPoint(hash: txHash, index: self.mintIndex)

        return UnspentTransaction(output: transactionOutput, outpoint: transactionOutpoint)
    }

    public func asInputTransaction() throws -> TransactionInput {
        guard let txid = Data(fromHex: self.mintTxid) else {
            throw UnspentOutputError.invalidTxIdHex(hex: self.mintTxid)
        }

        let txHash: Data = Data(txid.reversed())
        let transactionOutpoint = TransactionOutPoint(hash: txHash, index: self.mintIndex)

        return TransactionInput(previousOutput: transactionOutpoint, signatureScript: Data(), sequence: UInt32.max)
    }
}
