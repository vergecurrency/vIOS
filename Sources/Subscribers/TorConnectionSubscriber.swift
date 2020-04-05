//
//  TorConnectionSubscriber.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 31/03/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import Foundation
import UIKit

class TorConnectionSubscriber: Subscriber {
    private let fiatRateTicker: FiatRateTicker
    private let applicationRepository: ApplicationRepository
    private let walletTicker: WalletTicker

    init(
        fiatRateTicker: FiatRateTicker,
        applicationRepository: ApplicationRepository,
        walletTicker: WalletTicker
    ) {
        self.fiatRateTicker = fiatRateTicker
        self.applicationRepository = applicationRepository
        self.walletTicker = walletTicker
    }

    @objc func didFinishTorStart(notification: Notification) {
        // Start the price ticker.
        self.fiatRateTicker.start()

        if !self.applicationRepository.setup {
            return
        }

        // Start the wallet ticker.
        self.walletTicker.start()

        if #available(iOS 12.0, *) {
            IntentsManager.donateIntents()
        }
    }

    @objc func didStartTorThread(notification: Notification) {
        TorStatusIndicator.shared.setStatus(.disconnected)
    }

    @objc func didEstablishTorConnection(notification: Notification) {
        TorStatusIndicator.shared.setStatus(.connected)
    }

    @objc func didResignTorConnection(notification: Notification) {
        TorStatusIndicator.shared.setStatus(.disconnected)
    }

    @objc func didTurnOffTor(notification: Notification) {
        TorStatusIndicator.shared.setStatus(.turnedOff)
    }

    @objc func errorDuringTorConnection(notification: Notification) {
        TorStatusIndicator.shared.setStatus(.error)

        TorFixer.shared.present()
    }

    @objc func didNotGetHiddenHttpSession(notification: Notification) {
        TorFixer.shared.present()
    }

    override func getSubscribedEvents() -> [Notification.Name: Selector] {
        [
            .didFinishTorStart: #selector(didFinishTorStart(notification:)),
            .didStartTorThread: #selector(didStartTorThread(notification:)),
            .didEstablishTorConnection: #selector(didEstablishTorConnection(notification:)),
            .didResignTorConnection: #selector(didResignTorConnection(notification:)),
            .didTurnOffTor: #selector(didTurnOffTor(notification:)),
            .errorDuringTorConnection: #selector(errorDuringTorConnection(notification:)),
            .didNotGetHiddenHttpSession: #selector(didNotGetHiddenHttpSession(notification:))
        ]
    }
}
