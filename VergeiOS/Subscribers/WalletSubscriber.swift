//
//  WalletSubscriber.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 31/03/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import Foundation

class WalletSubscriber: Subscriber {
    private let walletTicker: WalletTicker
    private let walletClient: WalletClientProtocol
    private let fiatRateTicker: FiatRateTicker
    private let shortcutsManager: ShortcutsManager
    private let applicationRepository: ApplicationRepository
    private let transactionManager: TransactionManager
    private let torClient: TorClient

    init(
        walletTicker: WalletTicker,
        walletClient: WalletClientProtocol,
        fiatRateTicker: FiatRateTicker,
        shortcutsManager: ShortcutsManager,
        applicationRepository: ApplicationRepository,
        transactionManager: TransactionManager,
        torClient: TorClient
    ) {
        self.walletTicker = walletTicker
        self.walletClient = walletClient
        self.fiatRateTicker = fiatRateTicker
        self.shortcutsManager = shortcutsManager
        self.applicationRepository = applicationRepository
        self.transactionManager = transactionManager
        self.torClient = torClient
    }

    @objc func didSetupWallet(notification: Notification) {
        self.walletTicker.start()
        self.fiatRateTicker.start()
        self.shortcutsManager.updateShortcuts()
    }

    @objc func didDisconnectWallet(notification: Notification) {
        ThemeManager.shared.switchTheme(theme: ThemeFactory.shared.featherMode)

        self.applicationRepository.reset()
        self.transactionManager.removeAll()
        self.walletTicker.stop()
        self.fiatRateTicker.stop()
        self.torClient.resign()
    }

    @objc func didBroadcastTx(notification: Notification) {
        self.walletClient.getBalance { _, info in
            if let info = info {
                self.applicationRepository.amount = info.availableAmountValue
            }
        }
    }

    @objc func updateBalance(notification: Notification) {
        self.walletTicker.tick()
    }

    override func getSubscribedEvents() -> [Notification.Name: Selector] {
        [
            .didSetupWallet: #selector(didSetupWallet(notification:)),
            .didDisconnectWallet: #selector(didDisconnectWallet(notification:)),
            .didBroadcastTx: #selector(didBroadcastTx(notification:)),
            .didResolveTransactionProposals: #selector(updateBalance(notification:)),
            .didFindTransactionProposals: #selector(updateBalance(notification:))
        ]
    }
}
