//
// Created by Swen van Zanten on 07/04/2020.
// Copyright (c) 2020 Verge Currency. All rights reserved.
//

import Foundation
import Logging

class ConfigurationSubscriber: Subscriber {
    private let applicationRepository: ApplicationRepository
    private let walletClient: WalletClientProtocol
    private let walletManager: WalletManagerProtocol
    private let log: Logger

    init(
        applicationRepository: ApplicationRepository,
        walletClient: WalletClientProtocol,
        walletManager: WalletManagerProtocol,
        log: Logger
    ) {
        self.applicationRepository = applicationRepository
        self.walletClient = walletClient
        self.walletManager = walletManager
        self.log = log
    }

    @objc func bootServerMigration(notification: Notification) {
        // Check if the deprecated VWS endpoints are in the users memory.
        if self.applicationRepository.isWalletServiceUrlSet && !Constants.deprecatedBwsEndpoints.contains(
            self.applicationRepository.walletServiceUrl
        ) {
            return self.log.info(LogMessage.NoDeprecatedVWSEndpointsFound)
        }

        // If so replace them by the replacement VWS endpoint.
        self.applicationRepository.walletServiceUrl = Constants.bwsEndpoint
        self.walletClient.resetServiceUrl(baseUrl: self.applicationRepository.walletServiceUrl)

        // If the wallet is setup we check on the server if there is a wallet present.
        if !self.applicationRepository.setup {
            return
        }

        self.walletManager
            .getWallet()
            .then { walletStatus in
                return self.walletManager.scanWallet()
            }.then { scanningRequested in
                self.log.info("boot server migration finished")
            }.catch { error in
                // TODO: raise user error
                self.log.error("\(error.localizedDescription)")
            }
    }

    override func getSubscribedEvents() -> [Notification.Name: Selector] {
        return [
            .didFinishTorStart: #selector(bootServerMigration(notification:))
        ]
    }
}
