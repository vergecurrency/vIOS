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
        super.init()
    }

    @objc func bootServerMigration(notification: Notification) {
        // Check if the deprecated VWS endpoints are in the user's memory.
        if self.applicationRepository.isWalletServiceUrlSet &&
            !Constants.deprecatedBwsEndpoints.contains(self.applicationRepository.walletServiceUrl) {
            return self.log.info("no deprecated VWS endpoints found")
        }

        // Replace with the new endpoint
        self.applicationRepository.walletServiceUrl = Constants.bwsEndpoint
        self.walletClient.resetServiceUrl(baseUrl: self.applicationRepository.walletServiceUrl)

        // If wallet isn't set up, skip migration check
        guard self.applicationRepository.setup else {
            return
        }

        // Perform async wallet migration check
        Task {
            do {
                let walletStatus = try await self.walletManager.getWallet()
                let scanningRequested = try await self.walletManager.scanWallet()
                self.log.info("boot server migration finished")
            } catch {
                self.log.error("Server migration failed: \(error.localizedDescription)")
                // TODO: raise user error (e.g., show alert on main thread)
            }
        }
    }

    override func getSubscribedEvents() -> [Notification.Name: Selector] {
        return [
            .didFinishTorStart: #selector(bootServerMigration(notification:))
        ]
    }
}
