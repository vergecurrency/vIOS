//
//  WalletServiceProvider.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 10/04/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation
import Swinject

class WalletServiceProvider: ServiceProvider {
    
    override func register() -> Void {
        registerWalletCredentials()
        registerWalletClient()
        registerTxTransponder()
        registerTransactionRepository()
        registerTransactionFactory()
        registerTransactionManager()
        registerWalletTicker()
        registerFiatRateTicker()
        registerAddressBookRepository()
    }
    
    func registerWalletCredentials() {
        container.register(Credentials.self) { r in
            let appRepo = r.resolve(ApplicationRepository.self)!

            return Credentials(mnemonic: appRepo.mnemonic!, passphrase: appRepo.passphrase!, network: .mainnetXVG)
        }
    }
    
    func registerWalletClient() {
        container.register(WalletClient.self) { r in
            let appRepo = r.resolve(ApplicationRepository.self)!
            let credentials = r.resolve(Credentials.self)!
            let torClient = r.resolve(TorClient.self)!

            return WalletClient(appRepo: appRepo, credentials: credentials, torClient: torClient)
        }
    }

    func registerTxTransponder() {
        container.register(TxTransponder.self) { r in
            return TxTransponder(walletClient: r.resolve(WalletClient.self)!)
        }
    }

    func registerTransactionRepository() {
        container.register(TransactionRepository.self) { r in
            return TransactionRepository()
        }
    }

    func registerTransactionFactory() {
        container.register(TransactionFactory.self) { r in
            let fiatRateTracker = r.resolve(FiatRateTicker.self)!

            return TransactionFactory(fiatRateTracker: fiatRateTracker)
        }
    }

    func registerTransactionManager() {
        container.register(TransactionManager.self) { r in
            let walletClient = r.resolve(WalletClient.self)!
            let transactionRepository = r.resolve(TransactionRepository.self)!

            return TransactionManager(walletClient: walletClient, transactionRepository: transactionRepository)
        }.inObjectScope(.container)
    }

    func registerWalletTicker() {
        container.register(WalletTicker.self) { r in
            let walletClient = r.resolve(WalletClient.self)!
            let appRepo = r.resolve(ApplicationRepository.self)!
            let transactionManager = r.resolve(TransactionManager.self)!

            return WalletTicker(
                client: walletClient,
                applicationRepository: appRepo,
                transactionManager: transactionManager
            )
        }.inObjectScope(.container)
    }

    func registerFiatRateTicker() {
        container.register(FiatRateTicker.self) { r in
            let appRepo = r.resolve(ApplicationRepository.self)!
            let ratesClient = r.resolve(RatesClient.self)!

            return FiatRateTicker(applicationRepository: appRepo, statisicsClient: ratesClient)
        }.inObjectScope(.container)
    }

    func registerAddressBookRepository() {
        container.register(AddressBookRepository.self) { r in
            return AddressBookRepository()
        }
    }
    
}
