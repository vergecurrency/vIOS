//
//  Created by Swen van Zanten on 22/07/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation
import BitcoinKit

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

    func sweep(
        balance: BNBalance,
        destinationAddress: String,
        privateKeyWIF: String,
        completion: @escaping SweepCompletion
    ) throws {
        self.sweep(
            balance: balance,
            destinationAddress: destinationAddress,
            key: try self.wifToPrivateKey(wif: privateKeyWIF)!,
            completion: completion
        )
    }

    public func sweep(
        balance: BNBalance,
        destinationAddress: String,
        key: PrivateKey,
        completion: @escaping SweepCompletion
    ) {
        self.bitcoreNodeClient.unspendTransactions(
            byAddress: key.publicKey().toLegacy().description
        ) { _, transactions in
            do {
                let unsignedTx = try self.transactionFactory.getUnsignedTx(
                    balance: balance,
                    destinationAddress: destinationAddress,
                    outputs: transactions
                )

                let signedTx = try self.transactionFactory.signTx(unsignedTx: unsignedTx, keys: [key])
                let rawTx = signedTx.serialized()

                self.bitcoreNodeClient.send(rawTx: rawTx.hex) { error, response in
                    completion(error, response?.txid)
                }
            } catch TransactionFactory.TransactionFactoryError.addressToScriptError {
                // TODO
                print("addressToScriptError")
            } catch {
                // TODO
                print("Unexpected error: \(error).")
            }
        }
    }

    public func balance(
        byPrivateKeyWIF wif: String,
        completion: @escaping (_ error: Error?, _ balance: BNBalance?) -> Void
    ) throws {
        let publicKey = try self.wifToPrivateKey(wif: wif)?.publicKey()
        guard let address = publicKey?.toLegacy().description else {
            // Couldn't resolve address.
            completion(nil, nil)
            return
        }

        self.balance(byAddress: address, completion: completion)
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

        self.walletClient.getMainAddresses(options: options) { addresses in
            // If the last address isn't used we return that one.
            if let address = addresses.first, self.transactionManager.all(byAddress: address.address).count == 0 {
                return completion(nil, address.address)
            }

            // Otherwise generate a new one.
            self.walletClient.createAddress { _, addressInfo, _ in
                guard let addressInfo = addressInfo else {
                    return
                }

                completion(nil, addressInfo.address)
            }
        }
    }

    private func wifToPrivateKey(wif: String) throws -> PrivateKey? {
        return try PrivateKey(wif: wif)
    }
}
