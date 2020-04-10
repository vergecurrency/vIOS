//
//  WalletManager.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 26/10/2019.
//  Copyright © 2019 Verge Currency. All rights reserved.
//

import Foundation
import Logging
import Promises

class WalletManager: WalletManagerProtocol {
    private let walletClient: WalletClientProtocol
    private let walletTicker: TickerProtocol
    private let applicationRepository: ApplicationRepository
    private let log: Logger

    private let walletName = "ioswallet"
    private let copayerName = "iosuser"
    private let walletM = 1
    private let walletN = 1

    init(
        walletClient: WalletClientProtocol,
        walletTicker: TickerProtocol,
        applicationRepository: ApplicationRepository,
        log: Logger
    ) {
        self.walletClient = walletClient
        self.walletTicker = walletTicker
        self.applicationRepository = applicationRepository
        self.log = log
    }

    func getWallet() -> Promise<Vws.WalletStatus> {
        self.walletTicker.stop()

        return self.create().then(self.join).then(self.open).then { walletStatus -> Promise<Vws.WalletStatus> in
            self.walletTicker.start()

            return Promise<Vws.WalletStatus> {
                return walletStatus
            }
        }
    }

    func scanWallet() -> Promise<Bool> {
        return Promise<Bool> { fulfill, reject in
            self.walletClient.scanAddresses { error in
                if let error = error {
                    self.log.error(LogMessage.WalletManagerWalletScan(error: error.localizedDescription))

                    return reject(error)
                }

                self.log.info(LogMessage.WalletManagerWalletScanRequested)

                fulfill(true)
            }
        }
    }

    private func create() -> Promise<Vws.WalletID?> {
        return Promise<Vws.WalletID?> { fulfill, reject in
            self.walletClient.createWallet(
                walletName: self.walletName,
                copayerName: self.copayerName,
                m: self.walletM,
                n: self.walletN,
                options: nil
            ) { walletId, errorResponse, error in
                if let walletId = walletId {
                    self.log.info(LogMessage.WalletManagerCreatedWallet, metadata: [
                        "walletId": Logger.MetadataValue(stringLiteral: walletId.identifier)
                    ])

                    return fulfill(walletId)
                }

                if errorResponse?.code == .WalletAlreadyExists {
                    self.log.notice(LogMessage.WalletManagerWalletAlreadyExists)

                    return fulfill(nil)
                }

                let error = errorResponse?.error ?? error ?? NSError("??")
                let errorMessage = errorResponse?.message ?? error.localizedDescription

                self.log.error(LogMessage.WalletManagerCreatingWalletFailedWith(error: errorMessage))
                reject(error)
            }
        }
    }

    private func join(_ walletId: Vws.WalletID?) -> Promise<Vws.WalletJoin?> {
        return Promise<Vws.WalletJoin?> { fulfill, reject in
            guard let walletIdentifier = walletId?.identifier else {
                return fulfill(nil)
            }

            self.walletClient.joinWallet(walletIdentifier: walletIdentifier) { walletJoin, errorResponse, error in
                if let walletJoin = walletJoin {
                    self.log.info(LogMessage.WalletManagerJoinedWallet, metadata: [
                        "copayerId": Logger.MetadataValue(stringLiteral: walletJoin.copayerId),
                        "walletId": Logger.MetadataValue(stringLiteral: walletJoin.wallet.id)
                    ])

                    return fulfill(walletJoin)
                }

                if errorResponse?.code == .CopayerRegistered {
                    self.log.notice(LogMessage.WalletManagerWalletAlreadyExists)

                    return fulfill(nil)
                }

                let error = errorResponse?.error ?? error ?? NSError("??")
                let errorMessage = errorResponse?.message ?? error.localizedDescription

                self.log.error(LogMessage.WalletManagerJoiningWalletFailedWith(error: errorMessage))
                reject(error)
            }
        }
    }

    private func open(_ walletJoin: Vws.WalletJoin?) -> Promise<Vws.WalletStatus> {
        return Promise<Vws.WalletStatus> { fulfill, reject in
            self.walletClient.openWallet { walletStatus, errorResponse, error in
                if let walletStatus = walletStatus {
                    self.log.info(LogMessage.WalletManagerOpenedWallet, metadata: [
                        "walletId": Logger.MetadataValue(stringLiteral: walletStatus.wallet.id)
                    ])

                    return fulfill(walletStatus)
                }

                let error = errorResponse?.error ?? error ?? NSError("??")
                let errorMessage = errorResponse?.message ?? error.localizedDescription

                self.log.error(LogMessage.WalletManagerOpeningWalletFailedWith(error: errorMessage))
                reject(error)
            }
        }
    }
}
