//
//  DisconnectWalletViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 23-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class DisconnectWalletViewController: VViewController {

    var applicationRepository: ApplicationRepository!
    var transactionManager: TransactionManager!
    var walletTicker: WalletTicker!
    var fiatRateTicker: FiatRateTicker!
    var torClient: TorClient!

    @IBAction func disconnectWallet(_ sender: Any) {
        let alert = UIAlertController(
            title: "settings.disconnect.alert.title".localized,
            message: "settings.disconnect.alert.message".localized,
            preferredStyle: .alert
        )

        let cancel = UIAlertAction(title: "defaults.cancel".localized, style: .cancel)
        let confirm = UIAlertAction(title: "settings.disconnect.alert.disconnect".localized, style: .destructive) { action in
            // Show unlock view.
            let pinUnlockView = PinUnlockViewController.createFromStoryBoard()
            pinUnlockView.cancelable = true
            pinUnlockView.completion = { authenticated in
                if authenticated {
                    
                    // Reset wallet manager.
                    // @TODO: Move to event.
                    self.transactionManager.removeAll()
                    self.applicationRepository.reset()
                    self.fiatRateTicker.stop()
                    self.walletTicker.stop()
                    self.torClient.resign()
                    ThemeManager.shared.switchMode(isOn: false, appRepo: self.applicationRepository)

                    pinUnlockView.dismiss(animated: true) {
                        self.performSegue(withIdentifier: "disconnectWallet", sender: self)
                    }
                } else {
                    pinUnlockView.dismiss(animated: true)
                }
            }
            
            self.present(pinUnlockView, animated: true)
         }

        alert.addAction(cancel)
        alert.addAction(confirm)

        present(alert, animated: true)
    }

}
