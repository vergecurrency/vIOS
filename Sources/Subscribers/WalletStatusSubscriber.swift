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
        guard self.applicationRepository.setup else {
            return
        }

        Task.detached { [weak self] in
            guard let self = self else { return }

            do {
                let status = try await withCheckedThrowingContinuation { continuation in
                    self.walletManager.getStatus()
                        .then { walletStatus in
                            continuation.resume(returning: walletStatus)
                        }
                        .catch { error in
                            continuation.resume(throwing: error)
                        }
                }
                var walletStatus = status.wallet?.status

                self.log.info("wallet status fetched: \(walletStatus)")

                if walletStatus == "none" || walletStatus != "complete" {
                    self.log.info("wallet status not completed")
                    let walletStatusResult = try await withCheckedThrowingContinuation { continuation in
                        self.walletManager.getWallet()
                            .then { walletStatus in
                                continuation.resume(returning: walletStatus)
                            }
                            .catch { error in
                                continuation.resume(throwing: error)
                            }
                    }
                    walletStatus = walletStatusResult.wallet?.status
                    
                    if walletStatusResult.wallet?.scanStatus != "success" {
                        self.log.info("wallet scan status not succeeded: \(walletStatus)")
                        _ = try await withCheckedThrowingContinuation { continuation in
                            self.walletManager.scanWallet()
                                .then { result in
                                    continuation.resume(returning: result)
                                }
                                .catch { error in
                                    continuation.resume(throwing: error)
                                }
                        }
                    }
                } else {
                    if status.wallet?.scanStatus != "success" {
                        self.log.info("wallet scan status not succeeded: \(walletStatus)")
                        _ = try await withCheckedThrowingContinuation { continuation in
                            self.walletManager.scanWallet()
                                .then { result in
                                    continuation.resume(returning: result)
                                }
                                .catch { error in
                                    continuation.resume(throwing: error)
                                }
                        }
                    }
                }

                self.log.info("wallet status final: \(walletStatus)")
            } catch {
                self.log.error("wallet status unexpected error: \(error.localizedDescription)")
            }
        }
    }


    override func getSubscribedEvents() -> [Notification.Name: Selector] {
        return [
            .didBootApplication: #selector(didBootApplication(notification:))
        ]
    }
}
