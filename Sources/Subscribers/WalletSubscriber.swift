//
//  WalletSubscriber.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 31/03/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//
import UIKit
import AVFoundation
class WalletSubscriber: Subscriber {
    private let walletTicker: WalletTicker
    private let walletClient: WalletClientProtocol
    private let fiatRateTicker: FiatRateTicker
    private let shortcutsManager: ShortcutsManager
    private let applicationRepository: ApplicationRepository
    private let transactionManager: TransactionManager

    init(
        walletTicker: WalletTicker,
        walletClient: WalletClientProtocol,
        fiatRateTicker: FiatRateTicker,
        shortcutsManager: ShortcutsManager,
        applicationRepository: ApplicationRepository,
        transactionManager: TransactionManager
    ) {
        self.walletTicker = walletTicker
        self.walletClient = walletClient
        self.fiatRateTicker = fiatRateTicker
        self.shortcutsManager = shortcutsManager
        self.applicationRepository = applicationRepository
        self.transactionManager = transactionManager
        super.init()
    }

    @objc func didSetupWallet(notification: Notification) {
        walletTicker.start()
        fiatRateTicker.start()
        shortcutsManager.updateShortcuts()
    }

    @objc func didDisconnectWallet(notification: Notification) {
        ThemeManager.shared.switchTheme(theme: ThemeFactory.shared.featherMode)
        applicationRepository.reset()
        transactionManager.removeAll()
        walletTicker.stop()
        fiatRateTicker.stop()
    }

    @objc func didBroadcastTx(notification: Notification) {
        walletClient.getBalance { _, info in
            if let info = info {
                self.applicationRepository.amount = info.availableAmountValue
            }
        }
    }

    @objc func updateBalance(notification: Notification) {
        walletTicker.tick()
    }

    override func getSubscribedEvents() -> [Notification.Name: Selector] {
        return [
            .didSetupWallet: #selector(didSetupWallet(notification:)),
            .didDisconnectWallet: #selector(didDisconnectWallet(notification:)),
            .didBroadcastTx: #selector(didBroadcastTx(notification:)),
            .didResolveTransactionProposals: #selector(updateBalance(notification:)),
            .didFindTransactionProposals: #selector(updateBalance(notification:)),
            .didAbortTransactionWithError: #selector(updateBalance(notification:))
        ]
    }
}
