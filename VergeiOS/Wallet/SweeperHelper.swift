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

    public func sweep(unspendTransactions: [Transaction], balance: BNBalance, destinationAddress: String) {
//        let unsignedTx = try? self.transactionFactory.getUnsignedTx(
//            balance: balance,
//            destinationAddress: destinationAddress,
//            outputs: unspendTransactions
//        )
//
//        print(unsignedTx)
//        print(unsignedTx?.tx.serialized().hex)
//
//        let signedTx = try? self.transactionFactory.signTx(unsignedTx: unsignedTx!, keys: [privateKey!])
//        let rawTx = signedTx?.serialized()
//
//        print(rawTx?.hex)
//        self.bitcoreNodeClient.send(rawTx: rawTx!.hex) { error, response in
//            print(response)
//            print(error?.localizedDescription)
//        }
    }

    public func balance(
        byPrivateKeyWIF wif: String,
        completion: @escaping (_ error: Error?, _ balance: BNBalance?) -> Void
    ) {
        let privateKey = try? PrivateKey(wif: wif)
        let publicKey = privateKey?.publicKey()
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
            self.walletClient.createAddress { error, addressInfo, errorResponse in
                guard let addressInfo = addressInfo else {
                    return
                }

                completion(nil, addressInfo.address)
            }
        }
    }
}

protocol SweeperHelperProtocol {
    func balance(
        byPrivateKeyWIF wif: String,
        completion: @escaping (_ error: Error?, _ balance: BNBalance?) -> Void
    )

    func balance(
        byAddress address: String,
        completion: @escaping (_ error: Error?, _ balance: BNBalance?) -> Void
    )

    func recipientAddress(completion: @escaping (_ error: Error?, _ address: String?) -> Void)
}
