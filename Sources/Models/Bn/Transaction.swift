//
//  Created by Swen van Zanten on 12/07/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation
import BitcoinKit

extension Bn {
    struct Transaction: Decodable {
        enum UnspentOutputError: Error {
            case invalidScriptPubKeyHex(hex: String)
            case invalidTxIdHex(hex: String)
        }

        let chain: String
        let network: String
        let coinbase: Bool
        let mintIndex: UInt32
        let spentTxid: String
        let mintTxid: String
        let mintHeight: UInt64
        let spentHeight: Int64
        let address: String
        let script: String
        let value: UInt64
        let confirmations: Int64

        func asUnspentTransaction() throws -> UnspentTransaction {
            guard let lockingScript = Data(hex: self.script) else {
                throw UnspentOutputError.invalidScriptPubKeyHex(hex: self.script)
            }

            guard let txid = Data(hex: self.mintTxid) else {
                throw UnspentOutputError.invalidTxIdHex(hex: self.mintTxid)
            }

            let transactionOutput = TransactionOutput(value: self.value, lockingScript: lockingScript)
            let txHash: Data = Data(txid.reversed())
            let transactionOutpoint = TransactionOutPoint(hash: txHash, index: self.mintIndex)

            return UnspentTransaction(output: transactionOutput, outpoint: transactionOutpoint)
        }

        func asInputTransaction() throws -> TransactionInput {
            guard let txid = Data(hex: self.mintTxid) else {
                throw UnspentOutputError.invalidTxIdHex(hex: self.mintTxid)
            }

            let txHash: Data = Data(txid.reversed())
            let transactionOutpoint = TransactionOutPoint(hash: txHash, index: self.mintIndex)

            return TransactionInput(previousOutput: transactionOutpoint, signatureScript: Data(), sequence: UInt32.max)
        }
    }
}
