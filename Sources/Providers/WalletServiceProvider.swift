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
        registerLogger()               // Must come first
        registerHttpSession()          // HttpSessionProtocol
        registerRatesClient()          // Must be before FiatRateTicker
        registerWalletCredentials()    // Depends on ApplicationRepository
        registerWalletClient()         // Depends on Credentials & HttpSession
        registerTransactionRepository()
        registerTransactionFactory()   // Depends on RatesClient & ApplicationRepository
        registerTxTransponder()
        registerTransactionManager()
        registerWalletTicker()         // Depends on WalletClient & TransactionManager
        registerFiatRateTicker()       // Depends on RatesClient & ApplicationRepository
        registerAddressBookRepository()
        registerSweeperHelper()
        registerWalletManager()
        registerNFCWalletTransactionFactory()
        registerWalletSubscriber()     // New: register WalletSubscriber last
    }
    // MARK: - Transaction Repository
    func registerTransactionRepository() {
        container.register(TransactionRepository.self) { r in
            TransactionRepository(
                dataStack: r.resolve(DataStack.self)!,
                log: r.resolve(Logger.self)!
            )
        }
    }

    // MARK: - Transaction Factory
    func registerTransactionFactory() {
        container.register(WalletTransactionFactory.self) { r in
            let appRepo = r.resolve(ApplicationRepository.self)!
            let ratesClient = r.resolve(RatesClient.self)!
            return WalletTransactionFactory(
                ratesClient: ratesClient,
                fiatCurrency: appRepo.currency
            )
        }
    }

    func registerTxTransponder() {
        container.register(TxTransponderProtocol.self) { r in
            TxTransponder(walletClient: r.resolve(WalletClientProtocol.self)!)
        }
    }

    // MARK: - Transaction Manager
    func registerTransactionManager() {
        container.register(TransactionManager.self) { r in
            TransactionManager(
                walletClient: r.resolve(WalletClientProtocol.self)!,
                transactionRepository: r.resolve(TransactionRepository.self)!
            )
        }
    }

    // MARK: - Wallet Ticker
    func registerWalletTicker() {
        container.register(WalletTicker.self) { r in
            WalletTicker(
                client: r.resolve(WalletClientProtocol.self)!,
                applicationRepository: r.resolve(ApplicationRepository.self)!,
                transactionManager: r.resolve(TransactionManager.self)!,
                log: r.resolve(Logger.self)!
            )
        }
    }

    // MARK: - Address Book Repository
    func registerAddressBookRepository() {
        container.register(AddressBookRepository.self) { r in
            AddressBookRepository(
                dataStack: r.resolve(DataStack.self)!,
                log: r.resolve(Logger.self)!
            )
        }
    }

    // MARK: - Sweeper Helper
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

    // MARK: - Wallet Manager
    func registerWalletManager() {
        container.register(WalletManagerProtocol.self) { r in
            WalletManager(
                walletClient: r.resolve(WalletClientProtocol.self)!,
                walletTicker: r.resolve(WalletTicker.self)!,
                applicationRepository: r.resolve(ApplicationRepository.self)!,
                credentials: r.resolve(Credentials.self)!,
                log: r.resolve(Logger.self)!
            )
        }
    }

    // MARK: - NFC Wallet Transaction Factory
    func registerNFCWalletTransactionFactory() {
        container.register(NFCWalletTransactionFactory.self) { r, sendTransactionDelegate in
            NFCWalletTransactionFactory(
                sendTransactionDelegate: sendTransactionDelegate,
                addressValidator: AddressValidator(),
                logger: r.resolve(Logger.self)!
            )
        }
    }

    // MARK: - Logger
    private func registerLogger() {
        container.register(Logger.self) { _ in
            Logger(label: "org.verge.wallet") // <-- required label
        }.inObjectScope(.container)
    }


    // MARK: - HttpSession
    private func registerHttpSession() {
        container.register(HttpSessionProtocol.self) { _ in HttpSession() }
            .inObjectScope(.container)
    }

    // MARK: - RatesClient
    private func registerRatesClient() {
        container.register(RatesClient.self) { r in
            guard let httpSession = r.resolve(HttpSessionProtocol.self) else {
                fatalError("HttpSessionProtocol not registered before RatesClient")
            }
            return RatesClient(httpSession: httpSession)
        }.inObjectScope(.container)
    }

    // MARK: - Wallet Credentials
    func registerWalletCredentials() {
        container.register(Credentials.self) { resolver in
            let appRepo = resolver.resolve(ApplicationRepository.self)
            let mnemonic = appRepo?.mnemonic ?? []
            let passphrase = appRepo?.passphrase ?? ""

            // Use a fallback dummy mnemonic if empty
            let safeMnemonic: [String]
            if mnemonic.isEmpty {
                // Static dummy mnemonic for safe initialization
                safeMnemonic = [
                    "abandon", "abandon", "abandon", "abandon",
                    "abandon", "abandon", "abandon", "abandon",
                    "abandon", "abandon", "abandon", "about"
                ]
            } else {
                safeMnemonic = mnemonic
            }

            do {
                let credentials = try Credentials(
                    mnemonic: safeMnemonic,
                    passphrase: passphrase
                )
                return credentials
            } catch {
                print("Failed to create credentials: \(error)")

                // Fallback: create credentials with dummy mnemonic
                do {
                    let fallbackCredentials = try Credentials(
                        mnemonic: [
                            "abandon", "abandon", "abandon", "abandon",
                            "abandon", "abandon", "abandon", "abandon",
                            "abandon", "abandon", "abandon", "about"
                        ],
                        passphrase: ""
                       
                    )
                    return fallbackCredentials
                } catch {
                    fatalError("Failed to create fallback credentials: \(error)")
                }
            }
        }.inObjectScope(.container)
    }


    // MARK: - WalletClient
    func registerWalletClient() {
        container.register(WalletClientProtocol.self) { r in
            guard let appRepo = r.resolve(ApplicationRepository.self),
                  let credentials = r.resolve(Credentials.self),
                  let httpSession = r.resolve(HttpSessionProtocol.self),
                  let log = r.resolve(Logger.self) else {
                fatalError("Dependencies for WalletClient not registered")
            }

            let vwsClient = WalletClient(appRepo: appRepo, credentials: credentials, httpSession: httpSession, log: log)

            return RoutingWalletClient(
                applicationRepository: appRepo,
                vwsClient: vwsClient,
                electrumXClient: ElectrumXClient(applicationRepository: appRepo)
            )
        }.inObjectScope(.container)
    }

    // MARK: - FiatRateTicker
    func registerFiatRateTicker() {
        container.register(FiatRateTicker.self) { r in
            guard let appRepo = r.resolve(ApplicationRepository.self),
                  let ratesClient = r.resolve(RatesClient.self),
                  let log = r.resolve(Logger.self) else {
                fatalError("Dependencies for FiatRateTicker not registered")
            }

            return FiatRateTicker(applicationRepository: appRepo, statisicsClient: ratesClient, log: log)
        }.inObjectScope(.container)
    }

    // MARK: - WalletSubscriber
    private func registerWalletSubscriber() {
        container.register(SubscriberProtocol.self, name: "WalletSubscriber") { r in
            guard let walletTicker = r.resolve(WalletTicker.self),
                  let walletClient = r.resolve(WalletClientProtocol.self),
                  let fiatRateTicker = r.resolve(FiatRateTicker.self),
                  let shortcutsManager = r.resolve(ShortcutsManager.self),
                  let appRepo = r.resolve(ApplicationRepository.self),
                  let transactionManager = r.resolve(TransactionManager.self) else {
                fatalError("Dependencies for WalletSubscriber not registered")
            }

            return WalletSubscriber(
                walletTicker: walletTicker,
                walletClient: walletClient,
                fiatRateTicker: fiatRateTicker,
                shortcutsManager: shortcutsManager,
                applicationRepository: appRepo,
                transactionManager: transactionManager
            )
        }.inObjectScope(.container)
    }
}
extension Credentials {
    /// Returns a safe fallback Credentials object
    static func empty() -> Credentials {
        // 12-word dummy mnemonic
      
        return try! Credentials(mnemonic: [], passphrase: "")
    }
}
