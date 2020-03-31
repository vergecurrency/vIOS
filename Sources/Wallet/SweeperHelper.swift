//
//  Created by Swen van Zanten on 22/07/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation
import BitcoinKit
import Promises

private struct SweepCandidate {
    let privateKey: PrivateKey
    let balance: BNBalance
    let unspendTransactions: [BNTransaction]
}

class SweeperHelper: SweeperHelperProtocol {
    let bitcoreNodeClient: BitcoreNodeClientProtocol!
    let walletClient: WalletClientProtocol!
    let transactionFactory: TransactionFactoryProtocol!
    let transactionManager: TransactionManager!

    init(
        bitcoreNodeClient: BitcoreNodeClientProtocol,
        walletClient: WalletClientProtocol,
        transactionFactory: TransactionFactoryProtocol,
        transactionManager: TransactionManager
    ) {
        self.bitcoreNodeClient = bitcoreNodeClient
        self.walletClient = walletClient
        self.transactionFactory = transactionFactory
        self.transactionManager = transactionManager
    }

    public func sweep(
        keyBalances: [KeyBalance],
        destinationAddress: String,
        completion: @escaping SweepCompletion
    ) throws {
        var promises: [Promise<SweepCandidate>] = []
        for keyBalance in keyBalances {
            let promise = Promise<SweepCandidate> { fulfill, reject in
                let address = keyBalance.privateKey.publicKey().toLegacy().description

                self.bitcoreNodeClient.unspendTransactions(byAddress: address) { error, transactions in
                    guard let error = error else {
                        return fulfill(SweepCandidate(
                            privateKey: keyBalance.privateKey,
                            balance: keyBalance.balance,
                            unspendTransactions: transactions
                        ))
                    }

                    reject(error)
                }
            }

            promises.append(promise)
        }

        all(promises)
            .then { sweepCandidates in
                let transactions = sweepCandidates.map { $0.unspendTransactions }.flatMap { $0 }
                let privateKeys = sweepCandidates.map { $0.privateKey }
                let zeroBalance = BNBalance(confirmed: 0, unconfirmed: 0, balance: 0)
                let balance = sweepCandidates.map { $0.balance }.reduce(zeroBalance) { previous, next in
                    return BNBalance(
                        confirmed: previous.confirmed + next.confirmed,
                        unconfirmed: previous.unconfirmed + next.unconfirmed,
                        balance: previous.balance + previous.balance
                    )
                }

                do {
                    let unsignedTx = try self.transactionFactory.getUnsignedTx(
                        balance: balance,
                        destinationAddress: destinationAddress,
                        outputs: transactions
                    )

                    let signedTx = try self.transactionFactory.signTx(unsignedTx: unsignedTx, keys: privateKeys)
                    let rawTx = signedTx.serialized()

                    self.bitcoreNodeClient.send(rawTx: rawTx.hex) { error, response in
                        completion(error, response?.txid)
                    }
                } catch {
                    completion(error, nil)
                }
            }
            .catch { error in
                completion(error, nil)
            }
    }

    public func balance(
        privateKey: PrivateKey,
        completion: @escaping (_ error: Error?, _ balance: BNBalance?) -> Void
    ) {
        self.balance(byAddress: privateKey.publicKey().toLegacy().description, completion: completion)
    }

    public func balance(
        byAddress address: String,
        completion: @escaping (_ error: Error?, _ balance: BNBalance?) -> Void
    ) {
        self.bitcoreNodeClient.balance(byAddress: address, completion: completion)
    }

    public func recipientAddress(completion: @escaping (Error?, String?) -> Void) {
        var options = WalletAddressesOptions()
        options.limit = 1
        options.reverse = true

        self.walletClient.getMainAddresses(options: options) { error, addresses in
            if let error = error {
                return completion(error, nil)
            }

            // If the last address isn't used we return that one.
            if let address = addresses.first, self.transactionManager.all(byAddress: address.address).count == 0 {
                return completion(nil, address.address)
            }

            // Otherwise generate a new one.
            self.walletClient.createAddress { error, addressInfo, responseError in
                if let error = error {
                    return completion(error, nil)
                }

                if let responseError = responseError {
                    return completion(responseError.getError(), nil)
                }

                guard let addressInfo = addressInfo else {
                    return
                }

                completion(nil, addressInfo.address)
            }
        }
    }

    public func wifToPrivateKey(wif: String) throws -> PrivateKey {
        try PrivateKey(wif: wif)
    }
}
