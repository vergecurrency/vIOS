//
// Created by Swen van Zanten on 2019-04-11.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import Foundation

class EventServiceProvider: ServiceProvider {

    override func register() {
        setupTorListeners()
        setupWalletListeners()
        setupFiatRatingListeners()
    }

    func setupTorListeners() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didStartTorThread(notification:)),
            name: .didStartTorThread,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEstablishTorConnection(notification:)),
            name: .didEstablishTorConnection,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didResignTorConnection(notification:)),
            name: .didResignTorConnection,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didTurnOffTor(notification:)),
            name: .didTurnOffTor,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(errorDuringTorConnection(notification:)),
            name: .errorDuringTorConnection,
            object: nil
        )
    }

    func setupWalletListeners() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBroadcastTx(notification:)),
            name: .didBroadcastTx,
            object: nil
        )
    }

    func setupFiatRatingListeners() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didChangeCurrency),
            name: .didChangeCurrency,
            object: nil
        )
    }

    @objc func didStartTorThread(notification: Notification? = nil) {
        TorStatusIndicator.shared.setStatus(.disconnected)
    }

    @objc func didEstablishTorConnection(notification: Notification? = nil) {
        DispatchQueue.main.async {
            TorStatusIndicator.shared.setStatus(.connected)
        }
    }

    @objc func didResignTorConnection(notification: Notification? = nil) {
        TorStatusIndicator.shared.setStatus(.disconnected)
    }

    @objc func didTurnOffTor(notification: Notification? = nil) {
        TorStatusIndicator.shared.setStatus(.turnedOff)
    }

    @objc func errorDuringTorConnection(notification: Notification? = nil) {
        DispatchQueue.main.async {
            TorStatusIndicator.shared.setStatus(.error)
        }
    }

    @objc func didBroadcastTx(notification: Notification) {
        let walletClient = self.container.resolve(WalletClient.self)

        walletClient?.getBalance { error, info in
            let appRepo = self.container.resolve(ApplicationRepository.self)!

            if let info = info {
                appRepo.amount = info.availableAmountValue
            }
        }
    }

    @objc private func didChangeCurrency(_ notification: Notification) {
        DispatchQueue.main.async {
            print("Currency changed 💰")
            self.container.resolve(FiatRateTicker.self)?.fetch()
        }
    }

}
