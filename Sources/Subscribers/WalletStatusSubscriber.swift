//
//  Created by Swen van Zanten on 11/05/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import Foundation
import Logging

class WalletStatusSubscriber: Subscriber {
    
    enum WalletStatusError: Error {
        case statusNotComplete(status: Vws.WalletStatus)
    }
    
    let applicationRepository: ApplicationRepository
    let walletManager: WalletManagerProtocol
    let log: Logger
    
    init(applicationRepository: ApplicationRepository, walletManager: WalletManagerProtocol, log: Logger) {
        self.applicationRepository = applicationRepository
        self.walletManager = walletManager
        self.log = log
    }
    
    @objc func didBootApplication(notification: Notification) {
        if !self.applicationRepository.setup {
            return
        }

        // Check if wallet is setup correctly on every app boot.
        // If not we try to fix an users connection to the configured server.
        // If the connection isn't valid and can't be fixed we raise an error.
        self.walletManager.getStatus().then { status in
            if status.wallet.status != "complete" {
                throw WalletStatusError.statusNotComplete(status: status)
            }

            if status.wallet.scanStatus != "success" {
                let _ = self.walletManager.scanWallet()
            }
        }.catch { error in
            switch error {
            case WalletStatusError.statusNotComplete:
                let _ = self.walletManager.getWallet()
            default:
                print("Handle unhandled error")
            }
        }
    }

    override func getSubscribedEvents() -> [Notification.Name: Selector] {
        return [
            .didBootApplication: #selector(didBootApplication(notification:))
        ]
    }
}
