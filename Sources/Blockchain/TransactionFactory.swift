//
//  TransactionFactory.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 13/07/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation
import BitcoinKit
import Logging

class TransactionFactory: TransactionFactoryProtocol {
    enum TransactionFactoryError: Error {
        case addressToScriptError(address: Address)
    }

    private let log: Logger

    init(log: Logger) {
        self.log = log
    }

    public func getUnsignedTx(
        balance: Bn.Balance,
        destinationAddress: String,
        outputs: [Bn.Transaction]
    ) throws -> UnsignedTransaction {
        let size: Double = Double(44 + (outputs.count * 180))
        let toAddress: Address = try AddressFactory.create(destinationAddress)

        let unspentOutputs = outputs
        let unspentTransactions: [UnspentTransaction] = try unspentOutputs.map { output in
            return try output.asUnspentTransaction()
        }

        let fee = UInt64(ceil(size / 1000) * 100000)
        let amount = UInt64(max(Int(balance.confirmed) - Int(fee), 0))

        guard let lockingScriptTo = Script(address: toAddress) else {
            throw TransactionFactoryError.addressToScriptError(address: toAddress)
        }

        let unsignedInputs: [TransactionInput] = try unspentOutputs.map { output in
            return try output.asInputTransaction()
        }

        let outputs: [TransactionOutput] = [
            TransactionOutput(value: amount, lockingScript: lockingScriptTo.data)
        ]

        let tx = Transaction(
            version: 1,
          //  timestamp: UInt32(NSDate().timeIntervalSince1970),
            inputs: unsignedInputs,
            outputs: outputs,
            lockTime: 0
        )

        return UnsignedTransaction(tx: tx, utxos: unspentTransactions)
    }

    public func signTx(unsignedTx: UnsignedTransaction, keys: [PrivateKey]) throws -> Transaction {
        var inputsToSign = unsignedTx.tx.inputs
        var transactionToSign: Transaction {
            return Transaction(
                version: unsignedTx.tx.version,
              //  timestamp: unsignedTx.tx.timestamp,
                inputs: inputsToSign,
                outputs: unsignedTx.tx.outputs,
                lockTime: unsignedTx.tx.lockTime
            )
        }

        // Signing
        let hashType = SighashType.BTC.ALL
        for (i, utxo) in unsignedTx.utxos.enumerated() {
            let pubkeyHash: Data = Script.getPublicKeyHash(from: utxo.output.lockingScript)

            let keysOfUtxo: [PrivateKey] = keys.filter { $0.publicKey().pubkeyHash == pubkeyHash }
            guard let key = keysOfUtxo.first else {
                continue
            }

            self.log.info("transaction factory value of signing txout: \(utxo.output.value)")

            let sighash: Data = transactionToSign.signatureHash(
                for: utxo.output,
                inputIndex: i,
                hashType: hashType
            )
            let signature: Data = (try? Crypto.sign(sighash, privateKey: key)) ?? Data()
            let txin = inputsToSign[i]
            let pubkey = key.publicKey()

            let unlockingScript = Script.buildPublicKeyUnlockingScript(
                signature: signature,
                pubkey: pubkey,
                hashType: hashType
            )

            inputsToSign[i] = TransactionInput(
                previousOutput: txin.previousOutput,
                signatureScript: unlockingScript,
                sequence: txin.sequence
            )
        }

        self.log.info("transaction factory created signed transaction: \(transactionToSign.serialized().hex)")

        return transactionToSign
    }
}
