//
//  Created by Swen van Zanten on 22/07/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation
import BitcoinKit
import Promises
import Logging

private struct SweepCandidate {
    let privateKey: PrivateKey
    let balance: Bn.Balance
    let unspendTransactions: [Bn.Transaction]
}

class SweeperHelper: SweeperHelperProtocol {
    enum Error: Swift.Error {
        case notEnoughBalance
        case noAddressInfo
    }

    let bitcoreNodeClient: BitcoreNodeClientProtocol
    let walletClient: WalletClientProtocol
    let transactionFactory: TransactionFactoryProtocol
    let transactionManager: TransactionManager
    let log: Logger

    init(
        bitcoreNodeClient: BitcoreNodeClientProtocol,
        walletClient: WalletClientProtocol,
        transactionFactory: TransactionFactoryProtocol,
        transactionManager: TransactionManager,
        log: Logger
    ) {
        self.bitcoreNodeClient = bitcoreNodeClient
        self.walletClient = walletClient
        self.transactionFactory = transactionFactory
        self.transactionManager = transactionManager
        self.log = log
    }

    func sweep(keyBalances: [KeyBalance], destinationAddress: String) -> Promise<String> {
        self.log.info("sweeper helper start sweeping \(keyBalances.count) keys")

        let promises = self.unspendTransationsPer(keyBalances: keyBalances)

        return all(promises)
            .then { sweepCandidates in
                let transactions = sweepCandidates.map { $0.unspendTransactions }.flatMap { $0 }
                let privateKeys = sweepCandidates.map { $0.privateKey }
                let zeroBalance = Bn.Balance(confirmed: 0, unconfirmed: 0, balance: 0)
                let balance = sweepCandidates.map { $0.balance }.reduce(zeroBalance) { previous, next in
                    return Bn.Balance(
                        confirmed: previous.confirmed + next.confirmed,
                        unconfirmed: previous.unconfirmed + next.unconfirmed,
                        balance: previous.balance + previous.balance
                    )
                }

                let unsignedTx = try self.transactionFactory.getUnsignedTx(
                    balance: balance,
                    destinationAddress: destinationAddress,
                    outputs: transactions
                )

                let signedTx = try self.transactionFactory.signTx(unsignedTx: unsignedTx, keys: privateKeys)

                self.log.info("sweeper helper created a signedTx: \(signedTx.serialized().hex)")

                return Promise { signedTx.serialized().hex }
            }
            .then(self.sendRawTx)
    }

    func balance(privateKey: PrivateKey) -> Promise<Bn.Balance> {
        return self.balance(byAddress: privateKey.publicKey().toLegacy().description)
    }

    func balance(byAddress address: String) -> Promise<Bn.Balance> {
        return self.bitcoreNodeClient.balance(byAddress: address)
    }

    func recipientAddress() -> Promise<String> {
        var options = Vws.WalletAddressesOptions()
        options.limit = 1
        options.reverse = true

        return Promise { fulfill, reject in
            self.walletClient.getMainAddresses(options: options) { error, addresses in
                if let error = error {
                    return reject(error)
                }

                // If the last address isn't used we return that one.
                if let address = addresses.first, self.transactionManager.all(byAddress: address.address).count == 0 {
                    return fulfill(address.address)
                }

                // Otherwise generate a new one.
                self.walletClient.createAddress { error, addressInfo, responseError in
                    if let error = error {
                        return reject(error)
                    }

                    if let responseError = responseError {
                        return reject(responseError.getError())
                    }

                    guard let addressInfo = addressInfo else {
                        return reject(Error.noAddressInfo)
                    }

                    fulfill(addressInfo.address)
                }
            }
        }
    }

    func wifToPrivateKey(wif: String) throws -> PrivateKey {
        try PrivateKey(wif: wif)
    }

    private func sendRawTx(_ rawTxHex: String) -> Promise<String> {
        return self.bitcoreNodeClient.send(rawTx: rawTxHex).then { response in
            self.log.info("sweeper helper successfully send tx: \(response.txid)")

            return Promise { response.txid }
        }
    }

    private func unspendTransationsPer(keyBalances: [KeyBalance]) -> [Promise<SweepCandidate>] {
        return keyBalances.map { keyBalance in
            let address = keyBalance.privateKey.publicKey().toLegacy().description

            return self.bitcoreNodeClient
                .unspendTransactions(byAddress: address)
                .then { transactions in
                    return Promise {
                        return SweepCandidate(
                            privateKey: keyBalance.privateKey,
                            balance: keyBalance.balance,
                            unspendTransactions: transactions
                        )
                    }
                }
        }
    }
}
