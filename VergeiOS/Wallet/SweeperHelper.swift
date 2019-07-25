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

    init(
        bitcoreNodeClient: BitcoreNodeClientProtocol,
        walletClient: WalletClientProtocol,
        transactionFactory: TransactionFactoryProtocol
    ) {
        self.bitcoreNodeClient = bitcoreNodeClient
        self.walletClient = walletClient
        self.transactionFactory = transactionFactory
    }

    public func sweep(unspendTransactions: [Transaction], balance: BNBalance, destinationAddress: String) {
        let unsignedTx = try? self.transactionFactory.getUnsignedTx(
            balance: balance,
            destinationAddress: destinationAddress,
            outputs: unspendTransactions
        )

        print(unsignedTx)
        print(unsignedTx?.tx.serialized().hex)

        let signedTx = try? self.transactionFactory.signTx(unsignedTx: unsignedTx!, keys: [privateKey!])
        let rawTx = signedTx?.serialized()

        print(rawTx?.hex)
        self.bitcoreNodeClient.send(rawTx: rawTx!.hex) { error, response in
            print(response)
            print(error?.localizedDescription)
        }
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
}
