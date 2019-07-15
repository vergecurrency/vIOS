//
//  SweepPaperWalletViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 12/07/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import UIKit
import BitcoinKit

class SweepPaperWalletViewController: UIViewController {
    var bitcoreNodeClient: BitcoreNodeClientProtocol!
    var walletClient: WalletClientProtocol!
    var transactionFactory: TransactionFactoryProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()

        let privateKey = try? PrivateKey(wif: "")
        let publicKey = privateKey?.publicKey()
        guard let address = publicKey?.toLegacy().description else {
            // Couldn't resolve address.
            return
        }

        print(privateKey?.description)
        print(privateKey?.publicKey().description)
        print(privateKey?.publicKey().toLegacy().description)

        // Put in seperate class.
        self.bitcoreNodeClient.balance(byAddress: address) { error, balance in
            print(balance)
            if balance?.confirmed == 0 || balance == nil {
                // No balance
                return
            }

            self.bitcoreNodeClient.unspendTransactions(byAddress: address) { error, transactions in
                print(transactions)
//                self.walletClient.createAddress { error, info, response in
//                    guard let destinationAddress = info?.address else {
//                        return
//                    }
//                }
                let destinationAddress = ""

                let unsignedTx = try? self.transactionFactory.getUnsignedTx(
                    balance: balance!,
                    destinationAddress: destinationAddress,
                    outputs: transactions
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
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
