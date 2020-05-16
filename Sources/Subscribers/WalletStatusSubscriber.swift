//
//  Created by Swen van Zanten on 11/05/2020.
//  Copyright © 2020 Verge Currency. All rights reserved.
//

import Foundation
import Logging
import Promises

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
        Promise<Bool>(on: .global()) { () -> Bool in
            var status = try? await(self.walletManager.getStatus())
            var walletStatus = status?.wallet.status ?? "none"

            self.log.info("wallet status fetched status: \(walletStatus)")

            if walletStatus == "none" || walletStatus != "complete" {
                self.log.info("wallet status not completed")

                status = try await(self.walletManager.getWallet())
                walletStatus = status!.wallet.status
            }

            if status!.wallet.scanStatus != "success" {
                self.log.info("wallet status scan status not succeeded: \(walletStatus)")

                let _ = try await(self.walletManager.scanWallet())
            }

            self.log.info("wallet status final status: \(walletStatus)")

            return true
        }.catch { error in
            self.log.error("wallet status unexpected error thrown while getting wallet status: \(error.localizedDescription)")
        }
    }

    override func getSubscribedEvents() -> [Notification.Name: Selector] {
        return [
            .didBootApplication: #selector(didBootApplication(notification:))
        ]
    }
}
