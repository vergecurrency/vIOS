//
// Created by Swen van Zanten on 16/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

extension AppDelegate {
    func setupListeners() {
        setupTorListeners()
        setupWalletListeners()
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

    func setupWalletListeners() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBroadcastTx(notification:)),
            name: .didBroadcastTx,
            object: nil
        )
    }

    @objc func didBroadcastTx(notification: Notification) {
        WalletClient.shared.getBalance { error, info in
            if let info = info {
                ApplicationRepository.default.amount = info.availableAmountValue
            }
        }
    }
}
