//
//  WalletServiceProvider.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 10/04/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation
import Swinject
import CoreStore
import Logging

class WalletServiceProvider: ServiceProvider {
    override func register() {
        self.registerWalletCredentials()
        self.registerWalletClient()
        self.registerTxTransponder()
        self.registerTransactionRepository()
        self.registerTransactionFactory()
        self.registerTransactionManager()
        self.registerWalletTicker()
        self.registerFiatRateTicker()
        self.registerAddressBookRepository()
        self.registerSweeperHelper()
        self.registerWalletManager()
        self.registerNFCWalletTransactionFactory()
    }

    func registerWalletCredentials() {
        container.register(Credentials.self) { r in
            let appRepo = r.resolve(ApplicationRepository.self)!
            let mnemonic = appRepo.mnemonic ?? []
            let passphrase = appRepo.passphrase ?? ""

            return Credentials(mnemonic: mnemonic, passphrase: passphrase, network: .mainnetXVG)
        }.inObjectScope(.container)
    }

    func registerWalletClient() {
        container.register(WalletClientProtocol.self) { r in
            return WalletClient(
                appRepo: r.resolve(ApplicationRepository.self)!,
                credentials: r.resolve(Credentials.self)!,
                httpSession: r.resolve(HttpSessionProtocol.self)!,
                log: r.resolve(Logger.self)!
            )
        }.inObjectScope(.container)
    }

    func registerTxTransponder() {
        container.register(TxTransponderProtocol.self) { r in
            TxTransponder(walletClient: r.resolve(WalletClientProtocol.self)!)
        }
    }

    func registerTransactionRepository() {
        container.register(TransactionRepository.self) { r in
            TransactionRepository(dataStack: r.resolve(DataStack.self)!, log: r.resolve(Logger.self)!)
        }
    }

    func registerTransactionFactory() {
        container.register(WalletTransactionFactory.self) { r in
            let applicationRepository = r.resolve(ApplicationRepository.self)!
            let ratesClient = r.resolve(RatesClient.self)!

            return WalletTransactionFactory(ratesClient: ratesClient, fiatCurrency: applicationRepository.currency)
        }
    }

    func registerTransactionManager() {
        container.register(TransactionManager.self) { r in
            let walletClient = r.resolve(WalletClientProtocol.self)!
            let transactionRepository = r.resolve(TransactionRepository.self)!

            return TransactionManager(walletClient: walletClient, transactionRepository: transactionRepository)
        }
    }

    func registerWalletTicker() {
        container.register(WalletTicker.self) { r in
            let walletClient = r.resolve(WalletClientProtocol.self)!
            let appRepo = r.resolve(ApplicationRepository.self)!
            let transactionManager = r.resolve(TransactionManager.self)!
            let log = r.resolve(Logger.self)!

            return WalletTicker(
                client: walletClient,
                applicationRepository: appRepo,
                transactionManager: transactionManager,
                log: log
            )
        }.inObjectScope(.container)
    }

    func registerFiatRateTicker() {
        container.register(FiatRateTicker.self) { r in
            let appRepo = r.resolve(ApplicationRepository.self)!
            let ratesClient = r.resolve(RatesClient.self)!
            let log = r.resolve(Logger.self)!

            return FiatRateTicker(applicationRepository: appRepo, statisicsClient: ratesClient, log: log)
        }.inObjectScope(.container)
    }

    func registerAddressBookRepository() {
        container.register(AddressBookRepository.self) { r in
            AddressBookRepository(dataStack: r.resolve(DataStack.self)!, log: r.resolve(Logger.self)!)
        }
    }

    func registerSweeperHelper() {
        container.register(SweeperHelperProtocol.self) { r in
            SweeperHelper(
                bitcoreNodeClient: r.resolve(BitcoreNodeClientProtocol.self)!,
                walletClient: r.resolve(WalletClientProtocol.self)!,
                transactionFactory: r.resolve(TransactionFactoryProtocol.self)!,
                transactionManager: r.resolve(TransactionManager.self)!,
                log: r.resolve(Logger.self)!
            )
        }
    }

    func registerWalletManager() {
        container.register(WalletManagerProtocol.self) { r in
            return WalletManager(
                walletClient: r.resolve(WalletClientProtocol.self)!,
                walletTicker: r.resolve(WalletTicker.self)!,
                applicationRepository: r.resolve(ApplicationRepository.self)!,
                credentials: r.resolve(Credentials.self)!,
                log: r.resolve(Logger.self)!
            )
        }
    }

    func registerNFCWalletTransactionFactory() {
        container.register(NFCWalletTransactionFactory.self) { r, sendTransactionDelegate in
            return NFCWalletTransactionFactory(
                sendTransactionDelegate: sendTransactionDelegate,
                addressValidator: AddressValidator(),
                logger: r.resolve(Logger.self)!
            )
        }
    }
}
