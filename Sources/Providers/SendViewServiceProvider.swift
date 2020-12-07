//
//  SendServiceProvider.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 10/04/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation

class SendViewServiceProvider: ServiceProvider {

    override func register() {
        container.storyboardInitCompleted(SendViewController.self) { r, c in
            c.applicationRepository = r.resolve(ApplicationRepository.self)
            c.ratesClient = r.resolve(RatesClient.self)
            c.txFactory = r.resolve(WalletTransactionFactory.self)
            c.nfcTxFactory = r.resolve(NFCWalletTransactionFactory.self, argument: c as SendTransactionDelegate)
            c.txTransponder = r.resolve(TxTransponderProtocol.self)
            c.walletClient = r.resolve(WalletClientProtocol.self)
        }
    }

}
