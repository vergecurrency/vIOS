//
// Created by Swen van Zanten on 2019-04-11.
// Copyright (c) 2019 Verge Currency. All rights reserved.
//

import Foundation

class EventServiceProvider: ServiceProvider {

    private var nc: NotificationCenter!

    override func register() {
        self.nc = NotificationCenter.default

        setupTorListeners()
        setupWalletListeners()
        setupFiatRatingListeners()
    }

    func setupTorListeners() {
        self.nc.addObserver(
            self,
            selector: #selector(didStartTorThread(notification:)),
            name: .didStartTorThread,
            object: nil
        )

        self.nc.addObserver(
            self,
            selector: #selector(didEstablishTorConnection(notification:)),
            name: .didEstablishTorConnection,
            object: nil
        )

        self.nc.addObserver(
            self,
            selector: #selector(didResignTorConnection(notification:)),
            name: .didResignTorConnection,
            object: nil
        )

        self.nc.addObserver(
            self,
            selector: #selector(didTurnOffTor(notification:)),
            name: .didTurnOffTor,
            object: nil
        )

        self.nc.addObserver(
            self,
            selector: #selector(errorDuringTorConnection(notification:)),
            name: .errorDuringTorConnection,
            object: nil
        )
    }

    func setupWalletListeners() {
        self.nc.addObserver(
            self,
            selector: #selector(didSetupWallet(notification:)),
            name: .didSetupWallet,
            object: nil
        )

        self.nc.addObserver(
            self,
            selector: #selector(didBroadcastTx(notification:)),
            name: .didBroadcastTx,
            object: nil
        )
    }

    func setupFiatRatingListeners() {
        self.nc.addObserver(
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

    @objc func didSetupWallet(notification: Notification) {
        self.container.resolve(WalletTicker.self)?.start()
        self.container.resolve(FiatRateTicker.self)?.start()
        self.container.resolve(ShortcutsManager.self)?.updateShortcuts()
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
